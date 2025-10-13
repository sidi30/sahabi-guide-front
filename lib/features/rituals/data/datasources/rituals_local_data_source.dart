import 'dart:convert';
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/cache/cache_service.dart';

abstract class RitualsLocalDataSource {
  Future<List<RitualModel>> getRituals();
  Future<void> saveRituals(List<RitualModel> rituals, {int? contentVersion});
  Future<void> markAsCompleted(String ritualId);
  Future<List<DuaModel>> getDuas();
  Future<void> saveDuas(List<DuaModel> duas);
  Future<void> clearCache();
}

class RitualsLocalDataSourceImpl implements RitualsLocalDataSource {
  static const String _ritualsKey = 'rituals_list';
  static const String _duasKey = 'duas_list';
  
  final CacheService _cacheService;

  RitualsLocalDataSourceImpl(this._cacheService);

  @override
  Future<List<RitualModel>> getRituals() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_ritualsKey);
      
      if (cached == null) {
        return []; // Retourner liste vide si pas de cache
      }

      final rituals = cached.data
          .map((json) => RitualModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return rituals;
    } catch (e) {
      throw Exception('Failed to load cached rituals: $e');
    }
  }

  @override
  Future<void> saveRituals(List<RitualModel> rituals, {int? contentVersion}) async {
    try {
      final ritualsJson = rituals.map((r) => r.toJson()).toList();
      await _cacheService.set(
        key: _ritualsKey,
        data: ritualsJson,
        contentVersion: contentVersion,
      );
    } catch (e) {
      throw Exception('Failed to save rituals to cache: $e');
    }
  }

  @override
  Future<List<DuaModel>> getDuas() async {
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


  // @override
  // Future<List<RitualModel>> getTodayRituals() async {
  //   final allRituals = await getRituals();
  //   final now = DateTime.now();
    
  //   return allRituals.where((ritual) {
  //     // Filter daily rituals and weekly rituals for today
  //     if (ritual.frequency == RitualFrequency.daily) {
  //       return true;
  //     }
  //     if (ritual.frequency == RitualFrequency.weekly && 
  //         ritual.title.toLowerCase().contains('friday') && 
  //         now.weekday == DateTime.friday) {
  //       return true;
  //     }
  //     return false;
  //   }).toList()..sort((a, b) => b.priority.compareTo(a.priority));
  // }

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
}
