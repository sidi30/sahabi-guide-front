import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/cache/cache_service.dart';

abstract class RitualsLocalDataSource {
  /// [cacheKey] : clé composite (gender/type/lang/states) — null = cache
  /// neutre legacy. [allowStale] : servir le cache même expiré (hors-ligne).
  Future<List<RitualModel>> getRituals({String? cacheKey, bool allowStale = false});
  Future<void> saveRituals(List<RitualModel> rituals,
      {int? contentVersion, String? cacheKey});
  Future<void> markAsCompleted(String ritualId);
  Future<List<DuaModel>> getDuas({bool allowStale = false});
  Future<void> saveDuas(List<DuaModel> duas);
  Future<void> clearCache();
  Future<RitualModel?> getRitualById(String id);
  Future<bool> ritualsNeedUpdate(int? serverContentVersion);

  /// Paramètres de la dernière requête rituels (pour resynchroniser le contenu
  /// réellement affiché au retour du réseau).
  Future<void> saveLastRitualsQuery(Map<String, String?> params);
  Future<Map<String, String?>?> getLastRitualsQuery();
}

class RitualsLocalDataSourceImpl implements RitualsLocalDataSource {
  static const String _ritualsKey = 'rituals_list';
  static const String _duasKey = 'duas_list';
  static const String _lastQueryKey = 'rituals_last_query';

  final CacheService _cacheService;

  RitualsLocalDataSourceImpl(this._cacheService);

  /// Clé de stockage pour une clé composite (null = clé legacy inchangée).
  String _ritualsStorageKey(String? cacheKey) =>
      cacheKey == null ? _ritualsKey : '$_ritualsKey::$cacheKey';

  @override
  Future<List<RitualModel>> getRituals(
      {String? cacheKey, bool allowStale = false}) async {
    // NB: CacheService (SharedPreferences) purge lui-même les entrées expirées
    // à la lecture — allowStale n'est donc effectif que sur l'implémentation
    // Hive (celle branchée en DI). Implémentation conservée pour les tests.
    try {
      final cached =
          await _cacheService.get<List<dynamic>>(_ritualsStorageKey(cacheKey));

      // Fallback asset : si pas de cache (ex. premier lancement, API offline)
      // on charge le seed bundle pour avoir des rituels avec UUIDs réels et
      // URLs vidéo YouTube. Sinon l'écran rituels serait vide.
      // Seed NEUTRE uniquement pour la clé legacy : pour une clé ciblée
      // (genre/type/lang), il montrerait le mauvais contenu.
      if (cached == null) {
        return cacheKey == null ? await _loadSeedFromAsset() : <RitualModel>[];
      }

      final rituals = cached.data
          .map((json) => RitualModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (rituals.isEmpty && cacheKey == null) {
        return await _loadSeedFromAsset();
      }

      return rituals;
    } catch (e) {
      // Cache corrompu → on tente le seed asset plutôt que de tout casser.
      if (cacheKey != null) {
        throw Exception('Failed to load cached rituals: $e');
      }
      try {
        return await _loadSeedFromAsset();
      } catch (_) {
        throw Exception('Failed to load cached rituals: $e');
      }
    }
  }

  Future<List<RitualModel>> _loadSeedFromAsset() async {
    final raw = await rootBundle.loadString('assets/data/rituals_seed.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final list = decoded['rituals'] as List<dynamic>;
    return list
        .map((e) => RitualModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRituals(List<RitualModel> rituals,
      {int? contentVersion, String? cacheKey}) async {
    try {
      final ritualsJson = rituals.map((r) => r.toJson()).toList();
      await _cacheService.set(
        key: _ritualsStorageKey(cacheKey),
        data: ritualsJson,
        contentVersion: contentVersion,
      );
    } catch (e) {
      throw Exception('Failed to save rituals to cache: $e');
    }
  }

  @override
  Future<List<DuaModel>> getDuas({bool allowStale = false}) async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_duasKey);
      
      if (cached == null) {
        return []; // Retourner liste vide si pas de cache
      }

      final duas = cached.data
          .map((json) => DuaModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return duas;
    } catch (e) {
      throw Exception('Failed to load cached duas: $e');
    }
  }

  @override
  Future<void> saveDuas(List<DuaModel> duas) async {
    try {
      final duasJson = duas.map((d) => d.toJson()).toList();
      await _cacheService.set(
        key: _duasKey,
        data: duasJson,
      );
    } catch (e) {
      throw Exception('Failed to save duas to cache: $e');
    }
  }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    try {
      // Charger les rituels actuels
      final rituals = await getRituals();
      
      // Mettre à jour le statut
      final updatedRituals = rituals.map((ritual) {
        if (ritual.id == ritualId) {
          return ritual.copyWith(
            status: RitualStatus.completed,
            completedAt: DateTime.now(),
          );
        }
        return ritual;
      }).toList();
      
      // Sauvegarder les rituels mis à jour
      await saveRituals(updatedRituals);
    } catch (e) {
      throw Exception('Failed to mark ritual as completed: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearAll();
  }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    try {
      final rituals = await getRituals();
      return rituals.firstWhere(
        (ritual) => ritual.id == id,
        orElse: () => throw Exception('Ritual not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> ritualsNeedUpdate(int? serverContentVersion) async {
    if (serverContentVersion == null) return false;

    try {
      final cached = await _cacheService.get<List<dynamic>>(_ritualsKey);
      if (cached == null) return true;

      final cachedVersion = cached.contentVersion ?? 0;
      return serverContentVersion > cachedVersion;
    } catch (e) {
      return true;
    }
  }

  @override
  Future<void> saveLastRitualsQuery(Map<String, String?> params) async {
    await _cacheService.set(key: _lastQueryKey, data: params);
  }

  @override
  Future<Map<String, String?>?> getLastRitualsQuery() async {
    try {
      final cached = await _cacheService.get<Map<String, dynamic>>(_lastQueryKey);
      if (cached == null) return null;
      return cached.data.map((k, v) => MapEntry(k, v as String?));
    } catch (e) {
      return null;
    }
  }
}
