import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../core/utils/app_logger.dart';
import '../domain/sos_request.dart';

/// Persistance de la file de SOS.
///
/// La file doit survivre à la fermeture (ou au crash) de l'app : un appel au
/// secours non confirmé est repris au redémarrage, pas perdu.
abstract class SosQueueStore {
  Future<List<SosRequest>> readAll();

  Future<void> save(SosRequest request);

  Future<void> remove(String clientAlertId);
}

/// Implémentation Hive. Les entrées sont stockées en JSON (une String par
/// SOS) : pas de TypeAdapter à générer, et un format lisible qui tolère
/// l'ajout de champs par une version ultérieure de l'app.
class HiveSosQueueStore implements SosQueueStore {
  HiveSosQueueStore({String boxName = defaultBoxName}) : _boxName = boxName;

  static const String defaultBoxName = 'sos_queue';

  final String _boxName;
  Future<Box<String>>? _boxFuture;

  Future<Box<String>> _box() {
    if (Hive.isBoxOpen(_boxName)) {
      return Future.value(Hive.box<String>(_boxName));
    }
    final cached = _boxFuture;
    if (cached != null) return cached;

    // Une ouverture ratée ne doit PAS rester en cache : sinon toute la file
    // resterait morte pour la durée de vie de l'app, y compris après la
    // disparition de la cause (disque saturé, box verrouillée).
    return _boxFuture = Hive.openBox<String>(_boxName).then(
      (box) => box,
      onError: (Object error, StackTrace stackTrace) {
        _boxFuture = null;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }

  @override
  Future<List<SosRequest>> readAll() async {
    final box = await _box();
    final requests = <SosRequest>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final parsed = SosRequest.tryParse(raw);
      if (parsed == null) {
        // Entrée illisible : on la signale mais on ne bloque pas la reprise
        // des autres SOS.
        AppLogger.error('[SOS] entrée de file illisible, ignorée (clé $key)');
        continue;
      }
      requests.add(parsed);
    }
    requests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return requests;
  }

  @override
  Future<void> save(SosRequest request) async {
    final box = await _box();
    await box.put(request.clientAlertId, jsonEncode(request.toJson()));
  }

  @override
  Future<void> remove(String clientAlertId) async {
    final box = await _box();
    await box.delete(clientAlertId);
  }
}
