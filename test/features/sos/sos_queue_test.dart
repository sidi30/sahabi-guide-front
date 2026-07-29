// Le SOS est une fonction de sécurité des personnes : ces tests vérifient
// qu'on ne peut PAS afficher un succès sans réponse du serveur, qu'un envoi
// raté reste en file et repart avec le même identifiant d'idempotence, et
// qu'un SOS sans position part quand même.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/features/sos/data/sos_location_resolver.dart';
import 'package:sahabi_guide/features/sos/domain/sos_request.dart';
import 'package:sahabi_guide/features/sos/presentation/providers/sos_provider.dart';

import 'sos_fakes.dart';

SosFix _fix(SosLocationOrigin origin) => SosFix(
      latitude: 21.4225,
      longitude: 39.8262,
      origin: origin,
      capturedAt: DateTime(2026, 7, 29, 11, 59),
    );

void main() {
  group('Déclenchement', () {
    test('le SOS est persisté AVANT toute tentative d\'envoi', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi();
      // Au moment où l'on cherche la position (donc avant l'envoi), l'appel au
      // secours est déjà sur le disque : un crash ici ne le perd pas.
      final notifier = buildNotifier(
        store: store,
        api: api,
        fixProvider: () async {
          expect(store.entries, hasLength(1));
          expect(api.sent, isEmpty);
          return null;
        },
      );

      await notifier.trigger();
      await notifier.flush();

      expect(api.sent, hasLength(1));
    });

    test('un SOS sans position est envoyé quand même', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api, fix: null);

      await notifier.trigger();
      await notifier.flush();

      expect(api.sent, hasLength(1));
      expect(api.sent.single.hasPosition, isFalse);
      expect(api.sent.single.locationOrigin, SosLocationOrigin.none);
      expect(api.sent.single.toRequestBody().containsKey('latitude'), isFalse);
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });

    test('la position fraîche est jointe et son origine conservée', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi();
      final notifier = buildNotifier(
        store: store,
        api: api,
        fix: _fix(SosLocationOrigin.freshGps),
      );

      await notifier.trigger();
      await notifier.flush();

      final sent = api.sent.single;
      expect(sent.latitude, closeTo(21.4225, 0.0001));
      expect(sent.locationOrigin, SosLocationOrigin.freshGps);
      expect(sent.toRequestBody()['capturedAt'], isNotNull);
    });

    test('une résolution de position en échec ne bloque pas l\'envoi',
        () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi();
      final notifier = buildNotifier(
        store: store,
        api: api,
        fixProvider: () async => throw Exception('GPS indisponible'),
      );

      await notifier.trigger();
      await notifier.flush();

      expect(api.sent, hasLength(1));
      expect(api.sent.single.hasPosition, isFalse);
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });

    test('un second appui pendant qu\'un SOS est en vol ne crée pas de doublon',
        () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true);
      final notifier = buildNotifier(store: store, api: api);

      final first = await notifier.trigger();
      final second = await notifier.trigger();

      expect(second.clientAlertId, first.clientAlertId);
      expect(store.entries, hasLength(1));
    });

    test('un nouvel appui après un échec définitif crée un nouvel appel',
        () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true);
      final notifier =
          buildNotifier(store: store, api: api, maxAutomaticAttempts: 1);

      final first = await notifier.trigger();
      await notifier.flush();
      final second = await notifier.trigger();

      expect(second.clientAlertId, isNot(first.clientAlertId));
    });
  });

  group('La persistance est un filet, pas une porte', () {
    test('un disque qui refuse l\'écriture n\'empêche pas l\'envoi', () async {
      final store = BrokenSosQueueStore();
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api);

      await notifier.trigger();
      await notifier.flush();

      expect(store.saveAttempts, greaterThan(0), reason: 'on a bien essayé');
      expect(api.sent, hasLength(1),
          reason: 'perdre le SOS parce que Hive est cassé serait le pire cas');
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });

    test('un acquittement non persisté retire quand même l\'entrée de l\'écran',
        () async {
      final store = BrokenSosQueueStore();
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api);

      final request = await notifier.trigger();
      await notifier.flush();
      await notifier.acknowledge(request.clientAlertId);

      expect(notifier.state.current, isNull);
    });
  });

  group('Aucun faux succès', () {
    test('le succès n\'est affiché qu\'après la réponse du serveur', () async {
      final store = FakeSosQueueStore();
      final api = ManualSosApi();
      final notifier = buildNotifier(store: store, api: api);

      await notifier.trigger();
      final pump = notifier.flush();
      await pumpEventQueue();

      // Requête en vol : l'état dit « envoi en cours », jamais « reçu ».
      expect(api.sent, hasLength(1));
      expect(notifier.state.current!.status, SosDeliveryStatus.sending);
      expect(notifier.state.current!.serverAlertId, isNull);
      expect(notifier.state.current!.confirmedAt, isNull);

      api.respond();
      await pump;

      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
      expect(notifier.state.current!.serverAlertId, 'server-alert-1');
    });

    test('un refus définitif du serveur rend la main au pèlerin', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true, retryable: false);
      final notifier = buildNotifier(store: store, api: api);

      await notifier.trigger();
      await notifier.flush();

      expect(api.sent, hasLength(1), reason: 'inutile de marteler un refus');
      expect(notifier.state.current!.status, SosDeliveryStatus.failed);
      expect(notifier.state.current!.lastError, isNotNull);
      expect(notifier.state.current!.serverAlertId, isNull);
    });

    test('un SOS en vol ne peut pas être acquitté (il reste à l\'écran)',
        () async {
      final store = FakeSosQueueStore();
      final api = ManualSosApi();
      final notifier = buildNotifier(store: store, api: api);

      final request = await notifier.trigger();
      final pump = notifier.flush();
      await pumpEventQueue();

      await notifier.acknowledge(request.clientAlertId);
      expect(notifier.state.current, isNotNull);
      expect(store.entries, hasLength(1));

      api.respond();
      await pump;

      await notifier.acknowledge(request.clientAlertId);
      expect(notifier.state.current, isNull);
      expect(store.entries, isEmpty);
    });
  });

  group('File d\'attente et réessai', () {
    test(
        'un envoi qui échoue reste en file et repart avec le MÊME clientAlertId',
        () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(failures: 3);
      final notifier = buildNotifier(store: store, api: api);

      await notifier.trigger();
      await notifier.flush();

      expect(api.sent, hasLength(4), reason: '3 échecs puis 1 succès');
      expect(api.sentIds, hasLength(1),
          reason: 'idempotence : le serveur doit reconnaître le même envoi');
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
      expect(notifier.state.current!.attempts, 4);
    });

    test('pendant les réessais, l\'état reste « en attente », jamais « reçu »',
        () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(failures: 2);
      final states = <SosDeliveryStatus>[];
      final notifier = buildNotifier(store: store, api: api);
      notifier.addListener((s) {
        if (s.current != null) states.add(s.current!.status);
      });

      await notifier.trigger();
      await notifier.flush();

      expect(states.contains(SosDeliveryStatus.pending), isTrue);
      expect(states.indexOf(SosDeliveryStatus.sent), states.length - 1,
          reason: 'le succès n\'apparaît qu\'une fois, à la toute fin');
    });

    test('après épuisement des tentatives automatiques, le SOS reste en file',
        () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true);
      final notifier =
          buildNotifier(store: store, api: api, maxAutomaticAttempts: 3);

      await notifier.trigger();
      await notifier.flush();

      expect(api.sent, hasLength(3));
      expect(notifier.state.current!.status, SosDeliveryStatus.failed);
      expect(store.entries, hasLength(1),
          reason: 'un appel au secours non confirmé ne disparaît jamais');
    });

    test('un SOS bloqué n\'empêche pas le suivant de partir', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true, retryable: false);
      final notifier = buildNotifier(store: store, api: api);

      final blocked = await notifier.trigger();
      await notifier.flush();
      expect(notifier.state.current!.status, SosDeliveryStatus.failed);

      api.alwaysFail = false;
      final second = await notifier.trigger();
      await notifier.flush();

      expect(second.clientAlertId, isNot(blocked.clientAlertId));
      expect(notifier.state.requests.map((r) => r.status), [
        SosDeliveryStatus.failed,
        SosDeliveryStatus.sent,
      ]);
    });

    test('le réessai manuel repart du même clientAlertId', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true);
      final notifier =
          buildNotifier(store: store, api: api, maxAutomaticAttempts: 1);

      final request = await notifier.trigger();
      await notifier.flush();
      expect(notifier.state.current!.status, SosDeliveryStatus.failed);

      api.alwaysFail = false;
      await notifier.retry(request.clientAlertId);

      expect(api.sentIds, {request.clientAlertId});
      expect(api.sent, hasLength(2));
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });

    test('le retour du réseau relance un SOS en échec', () async {
      final store = FakeSosQueueStore();
      final api = FakeSosApi(alwaysFail: true);
      final connectivity = StreamController<bool>.broadcast();
      addTearDown(connectivity.close);

      final notifier = buildNotifier(
        store: store,
        api: api,
        connectivity: connectivity.stream,
        maxAutomaticAttempts: 1,
      );

      final request = await notifier.trigger();
      await notifier.flush();
      expect(api.sent, hasLength(1));
      expect(notifier.state.current!.status, SosDeliveryStatus.failed);

      api.alwaysFail = false;
      connectivity.add(true);
      await pumpEventQueue();

      expect(api.sent, hasLength(2));
      expect(api.sentIds, {request.clientAlertId});
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });
  });

  group('Reprise au redémarrage', () {
    test('un SOS non confirmé est repris et renvoyé', () async {
      final pending = SosRequest(
        clientAlertId: 'client-persiste',
        createdAt: DateTime(2026, 7, 29, 10),
        status: SosDeliveryStatus.pending,
        attempts: 2,
      );
      final store = FakeSosQueueStore({pending.clientAlertId: pending});
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api);

      await notifier.restore();
      await notifier.flush();

      expect(api.sent.single.clientAlertId, 'client-persiste');
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });

    test('un envoi interrompu en plein vol est rejoué (idempotence serveur)',
        () async {
      final interrupted = SosRequest(
        clientAlertId: 'client-interrompu',
        createdAt: DateTime(2026, 7, 29, 10),
        status: SosDeliveryStatus.sending,
      );
      final store = FakeSosQueueStore({interrupted.clientAlertId: interrupted});
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api);

      await notifier.restore();
      await notifier.flush();

      expect(api.sent.single.clientAlertId, 'client-interrompu');
    });

    test('un SOS en échec est réarmé au démarrage suivant', () async {
      final failed = SosRequest(
        clientAlertId: 'client-echoue',
        createdAt: DateTime(2026, 7, 29, 10),
        status: SosDeliveryStatus.failed,
        attempts: 8,
        lastError: 'réseau indisponible',
      );
      final store = FakeSosQueueStore({failed.clientAlertId: failed});
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api);

      await notifier.restore();
      await notifier.flush();

      expect(api.sent.single.clientAlertId, 'client-echoue');
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });

    test('un SOS déjà confirmé n\'est pas renvoyé', () async {
      final sent = SosRequest(
        clientAlertId: 'client-ok',
        createdAt: DateTime(2026, 7, 29, 10),
        status: SosDeliveryStatus.sent,
        serverAlertId: 'server-1',
      );
      final store = FakeSosQueueStore({sent.clientAlertId: sent});
      final api = FakeSosApi();
      final notifier = buildNotifier(store: store, api: api);

      await notifier.restore();
      await notifier.flush();

      expect(api.sent, isEmpty);
      expect(notifier.state.current!.status, SosDeliveryStatus.sent);
    });
  });

  group('Backoff', () {
    test('progresse puis plafonne', () {
      expect(SosQueueNotifier.backoffFor(1), const Duration(seconds: 2));
      expect(SosQueueNotifier.backoffFor(2), const Duration(seconds: 5));
      expect(SosQueueNotifier.backoffFor(99), const Duration(seconds: 120));
    });
  });
}
