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
      return await _hiveCacheService.getRituals();
    } catch (e) {
      throw Exception('Failed to load cached rituals: $e');
    }
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
      return await _hiveCacheService.getRitualById(id);
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

