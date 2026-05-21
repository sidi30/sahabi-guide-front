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
  Future<List<RitualModel>> getRituals() async {
    try {
      final cached = await _hiveCacheService.getRituals();
      // Fallback asset : cache Hive vide → premier lancement ou API offline.
      // Sans seed, écran rituels vide → pas de vidéo, pas de bot, rien.
      if (cached.isEmpty) {
        final seed = await _loadSeedFromAsset();
        // Persiste le seed en cache pour que getRitualById() le voie aussi.
        if (seed.isNotEmpty) {
          try {
            await _hiveCacheService.saveRituals(seed);
          } catch (_) {
            // Si l'écriture échoue, on retourne quand même les données.
          }
        }
        return seed;
      }
      return cached;
    } catch (e) {
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
  Future<void> saveRituals(List<RitualModel> rituals, {int? contentVersion}) async {
    try {
      await _hiveCacheService.saveRituals(rituals, contentVersion: contentVersion);
    } catch (e) {
      throw Exception('Failed to save rituals to cache: $e');
    }
  }

  @override
  Future<List<DuaModel>> getDuas() async {
    try {
      return await _hiveCacheService.getDuas();
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
}

