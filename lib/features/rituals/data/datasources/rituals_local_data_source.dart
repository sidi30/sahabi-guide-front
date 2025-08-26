import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../shared/models/ritual_model.dart';

abstract class RitualsLocalDataSource {
  Future<List<RitualModel>> getRituals();
  Future<List<RitualModel>> getTodayRituals();
  Future<void> markAsCompleted(String ritualId);
  Future<List<RitualModel>> getRitualsByType(RitualType type);
}

class RitualsLocalDataSourceImpl implements RitualsLocalDataSource {
  static const String _ritualsAssetPath = 'assets/data/rituals.json';
  final Set<String> _completedRitualIds = {};
  List<RitualModel>? _cachedRituals;

  @override
  Future<List<RitualModel>> getRituals() async {
    if (_cachedRituals != null) {
      return _cachedRituals!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_ritualsAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> ritualsList = jsonData['rituals'] ?? [];
      
      _cachedRituals = ritualsList.map((ritualJson) {
        final ritual = RitualModel.fromMap(ritualJson);
        return ritual.copyWith(
          isCompleted: _completedRitualIds.contains(ritual.id),
        );
      }).toList();
      
      return _cachedRituals!;
    } catch (e) {
      throw Exception('Failed to load rituals: $e');
    }
  }

  @override
  Future<List<RitualModel>> getTodayRituals() async {
    final allRituals = await getRituals();
    final now = DateTime.now();
    
    return allRituals.where((ritual) {
      // Filter daily rituals and weekly rituals for today
      if (ritual.frequency == RitualFrequency.daily) {
        return true;
      }
      if (ritual.frequency == RitualFrequency.weekly && 
          ritual.title.toLowerCase().contains('friday') && 
          now.weekday == DateTime.friday) {
        return true;
      }
      return false;
    }).toList()..sort((a, b) => b.priority.compareTo(a.priority));
  }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    if (_completedRitualIds.contains(ritualId)) {
      _completedRitualIds.remove(ritualId);
    } else {
      _completedRitualIds.add(ritualId);
    }
    
    // Update cache
    if (_cachedRituals != null) {
      _cachedRituals = _cachedRituals!.map((ritual) {
        if (ritual.id == ritualId) {
          return ritual.copyWith(
            isCompleted: _completedRitualIds.contains(ritualId),
          );
        }
        return ritual;
      }).toList();
    }
  }

  @override
  Future<List<RitualModel>> getRitualsByType(RitualType type) async {
    final allRituals = await getRituals();
    return allRituals.where((ritual) => ritual.type == type).toList();
  }
}
