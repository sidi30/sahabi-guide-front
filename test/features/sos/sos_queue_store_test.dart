// La file de SOS doit survivre à la fermeture de l'app : un appel au secours
// non confirmé se retrouve intact au redémarrage, prêt à repartir.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sahabi_guide/features/sos/data/sos_queue_store.dart';
import 'package:sahabi_guide/features/sos/domain/sos_request.dart';

void main() {
  late Directory tempDir;
  const boxName = 'sos_queue_test';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sahabi_sos_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  SosRequest pendingRequest() => SosRequest(
        clientAlertId: 'client-42',
        createdAt: DateTime(2026, 7, 29, 10, 30),
        status: SosDeliveryStatus.pending,
        latitude: 21.4133,
        longitude: 39.8933,
        capturedAt: DateTime(2026, 7, 29, 10, 29),
        locationOrigin: SosLocationOrigin.freshGps,
        attempts: 3,
        lastError: 'réseau indisponible',
      );

  test('un SOS en attente survit à un redémarrage de l\'app', () async {
    final request = pendingRequest();
    await HiveSosQueueStore(boxName: boxName).save(request);

    // Fermeture complète de Hive = fin de l'app. La nouvelle instance relit
    // le disque, comme au prochain lancement.
    await Hive.close();
    Hive.init(tempDir.path);

    final restored = await HiveSosQueueStore(boxName: boxName).readAll();

    expect(restored, hasLength(1));
    final stored = restored.single;
    expect(stored.clientAlertId, 'client-42',
        reason: 'c\'est cet identifiant qui rend le réessai idempotent');
    expect(stored.status, SosDeliveryStatus.pending);
    expect(stored.attempts, 3);
    expect(stored.latitude, closeTo(21.4133, 0.0001));
    expect(stored.locationOrigin, SosLocationOrigin.freshGps);
    expect(stored.capturedAt, DateTime(2026, 7, 29, 10, 29));
    expect(stored.lastError, 'réseau indisponible');
  });

  test('sauvegarder le même SOS le met à jour au lieu de le dupliquer',
      () async {
    final store = HiveSosQueueStore(boxName: boxName);
    final request = pendingRequest();
    await store.save(request);
    await store.save(request.copyWith(
      status: SosDeliveryStatus.sent,
      serverAlertId: 'server-7',
    ));

    final restored = await store.readAll();

    expect(restored, hasLength(1));
    expect(restored.single.status, SosDeliveryStatus.sent);
    expect(restored.single.serverAlertId, 'server-7');
  });

  test('un SOS acquitté est retiré de la file', () async {
    final store = HiveSosQueueStore(boxName: boxName);
    await store.save(pendingRequest());

    await store.remove('client-42');

    expect(await store.readAll(), isEmpty);
  });

  test('une entrée illisible est ignorée sans faire perdre les autres',
      () async {
    final store = HiveSosQueueStore(boxName: boxName);
    await store.save(pendingRequest());

    final box = Hive.box<String>(boxName);
    await box.put('corrompu', 'ceci n\'est pas du JSON');

    final restored = await store.readAll();

    expect(restored, hasLength(1));
    expect(restored.single.clientAlertId, 'client-42');
  });

  test('les SOS sont relus du plus ancien au plus récent', () async {
    final store = HiveSosQueueStore(boxName: boxName);
    await store.save(SosRequest(
      clientAlertId: 'recent',
      createdAt: DateTime(2026, 7, 29, 12),
      status: SosDeliveryStatus.pending,
    ));
    await store.save(SosRequest(
      clientAlertId: 'ancien',
      createdAt: DateTime(2026, 7, 29, 8),
      status: SosDeliveryStatus.pending,
    ));

    final restored = await store.readAll();

    expect(restored.map((r) => r.clientAlertId), ['ancien', 'recent']);
  });
}
