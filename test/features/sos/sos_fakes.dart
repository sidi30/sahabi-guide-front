// Doublures partagées par les tests SOS : file en mémoire, API pilotable,
// API à réponse manuelle.
import 'dart:async';

import 'package:sahabi_guide/features/sos/data/sos_api.dart';
import 'package:sahabi_guide/features/sos/data/sos_location_resolver.dart';
import 'package:sahabi_guide/features/sos/data/sos_queue_store.dart';
import 'package:sahabi_guide/features/sos/domain/sos_request.dart';
import 'package:sahabi_guide/features/sos/presentation/providers/sos_provider.dart';

/// Store en mémoire : même contrat que la persistance Hive (vérifiée, elle,
/// dans sos_queue_store_test.dart).
class FakeSosQueueStore implements SosQueueStore {
  FakeSosQueueStore([Map<String, SosRequest>? initial])
      : _entries = {...?initial};

  final Map<String, SosRequest> _entries;

  List<SosRequest> get entries => _entries.values.toList();

  @override
  Future<List<SosRequest>> readAll() async {
    return _entries.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> save(SosRequest request) async {
    _entries[request.clientAlertId] = request;
  }

  @override
  Future<void> remove(String clientAlertId) async {
    _entries.remove(clientAlertId);
  }
}

/// Store dont l'écriture échoue toujours : simule un disque plein ou une box
/// Hive corrompue.
class BrokenSosQueueStore implements SosQueueStore {
  int saveAttempts = 0;

  @override
  Future<List<SosRequest>> readAll() async =>
      throw StateError('file illisible');

  @override
  Future<void> save(SosRequest request) async {
    saveAttempts++;
    throw StateError('écriture impossible');
  }

  @override
  Future<void> remove(String clientAlertId) async =>
      throw StateError('suppression impossible');
}

/// API pilotable : chaque envoi est enregistré, et l'on choisit combien
/// d'appels échouent avant l'éventuel succès.
class FakeSosApi implements SosApi {
  FakeSosApi({
    this.failures = 0,
    this.retryable = true,
    this.alwaysFail = false,
    this.authRequired = false,
  });

  int failures;
  bool alwaysFail;
  final bool retryable;
  final bool authRequired;

  final List<SosRequest> sent = [];

  Set<String> get sentIds => sent.map((r) => r.clientAlertId).toSet();

  @override
  Future<SosAcknowledgement> send(SosRequest request) async {
    sent.add(request);
    if (alwaysFail || failures > 0) {
      failures--;
      throw SosSendException(
        authRequired ? 'Non autorisé' : 'réseau indisponible',
        retryable: retryable,
        authRequired: authRequired,
      );
    }
    return SosAcknowledgement(
      alertId: 'server-alert-1',
      positionRecorded: request.hasPosition,
      createdAt: DateTime(2026, 7, 29, 12),
    );
  }
}

/// API dont la réponse est déclenchée à la main : sert à observer l'état
/// pendant qu'une requête est réellement en vol.
class ManualSosApi implements SosApi {
  final List<SosRequest> sent = [];
  Completer<SosAcknowledgement>? _pending;

  @override
  Future<SosAcknowledgement> send(SosRequest request) {
    sent.add(request);
    return (_pending = Completer<SosAcknowledgement>()).future;
  }

  void respond() {
    _pending?.complete(const SosAcknowledgement(
      alertId: 'server-alert-1',
      positionRecorded: false,
    ));
  }
}

SosQueueNotifier buildNotifier({
  required SosQueueStore store,
  required SosApi api,
  SosFix? fix,
  Future<SosFix?> Function()? fixProvider,
  Stream<bool>? connectivity,
  int maxAutomaticAttempts = 8,
}) {
  var counter = 0;
  return SosQueueNotifier(
    store: store,
    api: api,
    fixProvider: fixProvider ?? () async => fix,
    connectivityChanges: connectivity,
    // Les délais de backoff sont neutralisés : on teste la logique de
    // réessai, pas la patience de l'horloge.
    delay: (_) async {},
    idGenerator: () => 'client-${++counter}',
    maxAutomaticAttempts: maxAutomaticAttempts,
  );
}

