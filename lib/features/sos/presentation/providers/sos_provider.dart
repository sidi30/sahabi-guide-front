import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/services/user_location_service.dart';
import '../../data/sos_api.dart';
import '../../data/sos_location_resolver.dart';
import '../../data/sos_queue_store.dart';
import '../../domain/sos_request.dart';

/// Fournit la position à joindre au SOS. Injectable pour les tests.
typedef SosFixProvider = Future<SosFix?> Function();

class SosQueueState {
  const SosQueueState({this.requests = const []});

  /// SOS connus, du plus ancien au plus récent. Un SOS n'en sort que confirmé
  /// et acquitté par le pèlerin, ou explicitement abandonné par lui.
  final List<SosRequest> requests;

  /// Le SOS à mettre en avant : le plus récent encore à l'écran.
  SosRequest? get current => requests.isEmpty ? null : requests.last;

  bool get hasInFlight => requests.any((r) => r.isInFlight);
}

/// Orchestration d'un appel au secours : persister, situer, envoyer, réessayer.
///
/// Règle non négociable : l'état affiché suit l'état réel. Un SOS n'est
/// [SosDeliveryStatus.sent] qu'après une réponse du serveur, et il reste
/// visible tant qu'il n'est pas confirmé.
class SosQueueNotifier extends StateNotifier<SosQueueState> {
  SosQueueNotifier({
    required SosQueueStore store,
    required SosApi api,
    required SosFixProvider fixProvider,
    Stream<bool>? connectivityChanges,
    Future<void> Function(Duration) delay = _wait,
    String Function() idGenerator = _uuid,
    this.maxAutomaticAttempts = 8,
  })  : _store = store,
        _api = api,
        _fixProvider = fixProvider,
        _delay = delay,
        _newId = idGenerator,
        super(const SosQueueState()) {
    _connectivitySubscription = connectivityChanges?.listen((online) {
      if (online) unawaited(rearmAll());
    });
  }

  static Future<void> _wait(Duration d) => Future.delayed(d);
  static String _uuid() => const Uuid().v4();

  /// Deux appuis rapprochés = un seul appel au secours. Le serveur déduplique
  /// déjà sur cette fenêtre ; on évite en plus d'empiler des entrées locales.
  static const Duration duplicateWindow = Duration(minutes: 2);

  final SosQueueStore _store;
  final SosApi _api;
  final SosFixProvider _fixProvider;
  final Future<void> Function(Duration) _delay;
  final String Function() _newId;
  StreamSubscription<bool>? _connectivitySubscription;

  /// Nombre de tentatives automatiques avant de rendre la main au pèlerin.
  /// Au-delà, le SOS n'est PAS abandonné : il reste en file, réarmé au retour
  /// du réseau ou par un réessai manuel.
  final int maxAutomaticAttempts;

  /// Tentatives depuis le dernier réarmement (le compteur persisté, lui, est
  /// cumulatif et sert à informer le pèlerin).
  final Map<String, int> _attemptsSinceRearm = {};

  Future<void>? _pumpFuture;

  /// Reprend la file au démarrage de l'app.
  Future<void> restore() async {
    final stored = await _store.readAll();
    if (stored.isEmpty) return;

    final restored = <SosRequest>[];
    for (final request in stored) {
      // « sending » interrompu par la fermeture de l'app : on ignore si le
      // serveur l'a reçu. Le renvoyer est sans risque (idempotence sur
      // clientAlertId), le perdre ne l'est pas.
      final revived = request.status == SosDeliveryStatus.sending
          ? request.copyWith(status: SosDeliveryStatus.pending)
          : request;
      if (revived.status == SosDeliveryStatus.failed) {
        // Réarmé : le contexte a changé (nouvelle session, peut-être du réseau).
        restored.add(revived.copyWith(status: SosDeliveryStatus.pending));
      } else {
        restored.add(revived);
      }
      _attemptsSinceRearm[revived.clientAlertId] = 0;
    }

    for (final request in restored) {
      await _persist(request);
    }
    state = SosQueueState(requests: restored);
    unawaited(flush());
  }

  /// Déclenche un SOS : persisté d'abord, situé ensuite, envoyé enfin.
  ///
  /// L'ordre compte : si l'app meurt entre-temps, l'appel au secours est déjà
  /// sur le disque et repartira au prochain démarrage.
  Future<SosRequest> trigger({String? message}) async {
    final existing = _recentInFlight();
    if (existing != null) {
      AppLogger.debug('[SOS] appel déjà en cours (${existing.clientAlertId})');
      unawaited(flush());
      return existing;
    }

    final request = SosRequest(
      clientAlertId: _newId(),
      createdAt: DateTime.now(),
      status: SosDeliveryStatus.pending,
      message: message,
    );
    await _persist(request);
    _attemptsSinceRearm[request.clientAlertId] = 0;
    state = SosQueueState(requests: [...state.requests, request]);

    final located = await _attachPosition(request);
    unawaited(flush());
    return located;
  }

  /// Réessai demandé par le pèlerin.
  Future<void> retry(String clientAlertId) async {
    final request = _find(clientAlertId);
    if (request == null || request.status == SosDeliveryStatus.sent) return;
    _attemptsSinceRearm[clientAlertId] = 0;
    await _update(request.copyWith(
      status: SosDeliveryStatus.pending,
      clearLastError: true,
    ));
    await flush();
  }

  /// Le pèlerin a pris connaissance de l'issue : l'entrée quitte l'écran.
  /// Un SOS encore en vol ne peut pas être acquitté — il doit rester visible.
  Future<void> acknowledge(String clientAlertId) async {
    final request = _find(clientAlertId);
    if (request == null || request.isInFlight) return;
    try {
      await _store.remove(clientAlertId);
    } catch (e) {
      // Pire cas : l'entrée réapparaît au prochain démarrage. Elle est
      // confirmée, donc elle ne sera pas renvoyée.
      AppLogger.error('[SOS] retrait de la file impossible', error: e);
    }
    _attemptsSinceRearm.remove(clientAlertId);
    state = SosQueueState(
      requests:
          state.requests.where((r) => r.clientAlertId != clientAlertId).toList(),
    );
  }

  /// Traite la file jusqu'à ce que plus rien ne soit en attente. Réentrant :
  /// un appel pendant qu'une passe tourne renvoie la passe en cours.
  Future<void> flush() {
    final running = _pumpFuture;
    if (running != null) return running;
    final future = _pump();
    _pumpFuture = future;
    return future.whenComplete(() {
      if (identical(_pumpFuture, future)) _pumpFuture = null;
    });
  }

  Future<void> _pump() async {
    while (true) {
      final next = _nextPending();
      if (next == null) return;

      final sending = await _update(next.copyWith(status: SosDeliveryStatus.sending));
      try {
        final ack = await _api.send(sending);
        await _update(sending.copyWith(
          status: SosDeliveryStatus.sent,
          attempts: sending.attempts + 1,
          serverAlertId: ack.alertId,
          confirmedAt: ack.createdAt ?? DateTime.now(),
          clearLastError: true,
        ));
        AppLogger.debug('[SOS] confirmé par le serveur : ${ack.alertId}');
      } on SosSendException catch (e) {
        final attempts = sending.attempts + 1;
        final sinceRearm = (_attemptsSinceRearm[sending.clientAlertId] ?? 0) + 1;
        _attemptsSinceRearm[sending.clientAlertId] = sinceRearm;
        final keepTrying = e.retryable && sinceRearm < maxAutomaticAttempts;

        await _update(sending.copyWith(
          status: keepTrying
              ? SosDeliveryStatus.pending
              : SosDeliveryStatus.failed,
          attempts: attempts,
          lastError: e.message,
          requiresLogin: e.authRequired,
        ));
        AppLogger.warning(
          '[SOS] tentative $attempts échouée (${e.message})'
          '${keepTrying ? ' — nouvel essai programmé' : ' — en attente d\'une action'}',
        );

        // Un SOS bloqué ne bloque pas les suivants : il n'est plus « pending »,
        // la passe continue avec le reste de la file.
        if (!keepTrying) continue;
        await _delay(backoffFor(sinceRearm));
      }
    }
  }

  /// Progression volontairement lente : le réseau des lieux saints sature aux
  /// moments de foule, marteler la requête n'aide personne.
  static Duration backoffFor(int attempt) {
    const steps = [2, 5, 15, 30, 60, 120];
    final index = (attempt - 1).clamp(0, steps.length - 1);
    return Duration(seconds: steps[index]);
  }

  Future<SosRequest> _attachPosition(SosRequest request) async {
    SosFix? fix;
    try {
      fix = await _fixProvider();
    } catch (e) {
      AppLogger.warning('[SOS] résolution de position en échec', error: e);
      fix = null;
    }
    if (fix == null) return request;

    return _update(request.copyWith(
      latitude: fix.latitude,
      longitude: fix.longitude,
      accuracyMeters: fix.accuracyMeters,
      capturedAt: fix.capturedAt,
      locationOrigin: fix.origin,
    ));
  }

  /// Remet en file tous les SOS bloqués et relance une passe.
  ///
  /// À appeler quand le contexte a changé en faveur d'un envoi : retour du
  /// réseau, ou reconnexion du pèlerin après une session expirée (un SOS
  /// refusé en 401 doit repartir sans que le pèlerin ait à y penser).
  Future<void> rearmAll() async {
    var rearmed = false;
    for (final request in state.requests) {
      if (request.status != SosDeliveryStatus.failed) continue;
      _attemptsSinceRearm[request.clientAlertId] = 0;
      await _update(request.copyWith(
        status: SosDeliveryStatus.pending,
        clearLastError: true,
      ));
      rearmed = true;
    }
    if (rearmed || state.requests.any((r) => r.isInFlight)) {
      await flush();
    }
  }

  Future<void> _persist(SosRequest request) async {
    try {
      await _store.save(request);
    } catch (e) {
      // La persistance est un filet, pas une porte : si le disque refuse
      // l'écriture, le SOS part quand même avec l'état en mémoire. Le perdre
      // ici serait le pire des comportements.
      AppLogger.error('[SOS] écriture de la file impossible', error: e);
    }
  }

  SosRequest? _recentInFlight() {
    final now = DateTime.now();
    for (final request in state.requests.reversed) {
      if (!request.isInFlight) continue;
      if (now.difference(request.createdAt) <= duplicateWindow) return request;
    }
    return null;
  }

  SosRequest? _nextPending() {
    for (final request in state.requests) {
      if (request.status == SosDeliveryStatus.pending) return request;
    }
    return null;
  }

  SosRequest? _find(String clientAlertId) {
    for (final request in state.requests) {
      if (request.clientAlertId == clientAlertId) return request;
    }
    return null;
  }

  Future<SosRequest> _update(SosRequest request) async {
    await _persist(request);
    state = SosQueueState(
      requests: state.requests
          .map((r) => r.clientAlertId == request.clientAlertId ? request : r)
          .toList(),
    );
    return request;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

final sosQueueProvider =
    StateNotifierProvider<SosQueueNotifier, SosQueueState>((ref) {
  final resolver = SosLocationResolver(sl<UserLocationService>());
  final notifier = SosQueueNotifier(
    store: HiveSosQueueStore(),
    api: SosApiImpl(sl<DioClient>()),
    fixProvider: resolver.resolve,
    connectivityChanges: sl<ConnectivityService>().onConnectivityChanged,
  );
  // Un SOS non confirmé lors de la dernière session repart tout seul.
  unawaited(notifier.restore());
  return notifier;
});
