import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/cache/hive_cache_service.dart';
import 'rituals_local_data_source.dart';

/// Implémentation de RitualsLocalDataSource utilisant Hive
class RitualsLocalDataSourceHive implements RitualsLocalDataSource {
  final HiveCacheService _hiveCacheService;

  RitualsLocalDataSourceHive(this._hiveCacheService);

  @override
  Future<List<RitualModel>> getRituals(
      {String? cacheKey, bool allowStale = false}) async {
    try {
      final cached = await _hiveCacheService.getRituals(
          cacheKey: cacheKey, allowStale: allowStale);
      // Fallback asset : cache Hive vide → premier lancement ou API offline.
      // Sans seed, écran rituels vide. IMPORTANT : on NE persiste PAS le seed en
      // cache (sinon il se ferait passer pour un cache valide 7 jours et masquerait
      // le contenu réel du serveur, genre/type-neutre). getRitualById() a son propre
      // fallback seed. Le seed est NEUTRE : servi uniquement pour la clé legacy —
      // pour une clé ciblée (genre/type/lang), il montrerait le mauvais contenu.
      if (cached.isEmpty && cacheKey == null) {
        return await _loadSeedFromAsset();
      }
      return cached;
    } catch (e) {
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
      await _hiveCacheService.saveRituals(rituals,
          contentVersion: contentVersion, cacheKey: cacheKey);
    } catch (e) {
      throw Exception('Failed to save rituals to cache: $e');
    }
  }

  @override
  Future<List<DuaModel>> getDuas({bool allowStale = false}) async {
    try {
      return await _hiveCacheService.getDuas(allowStale: allowStale);
    } catch (e) {
      throw Exception('Failed to load cached duas: $e');
    }
  }

  @override
  Future<void> saveDuas(List<DuaModel> duas) async {
    try {
      await _hiveCacheService.saveDuas(duas);
    } catch (e) {
      throw Exception('Failed to save duas to cache: $e');
    }
  }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    try {
      await _hiveCacheService.updateRitualStatus(
        ritualId,
        RitualStatus.completed,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to mark ritual as completed: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _hiveCacheService.clearAll();
  }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    try {
      final hit = await _hiveCacheService.getRitualById(id);
      if (hit != null) return hit;
      // Cache vide ou pas le bon id : fallback seed asset. Indispensable pour
      // que le bouton « Voir le rituel » du bot trouve l'UUID quand l'API
      // n'a pas encore alimenté Hive.
      final seed = await _loadSeedFromAsset();
      for (final r in seed) {
        if (r.id == id) return r;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load ritual by id: $e');
    }
  }

  @override
  Future<bool> ritualsNeedUpdate(int? serverContentVersion) async {
    try {
      return await _hiveCacheService.ritualsNeedUpdate(serverContentVersion);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveLastRitualsQuery(Map<String, String?> params) async {
    await _hiveCacheService.saveLastRitualsQuery(params);
  }

  @override
  Future<Map<String, String?>?> getLastRitualsQuery() async {
    return await _hiveCacheService.getLastRitualsQuery();
  }
}

