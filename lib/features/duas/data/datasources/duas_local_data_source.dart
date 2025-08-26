import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../shared/models/dua_model.dart';

abstract class DuasLocalDataSource {
  Future<List<DuaModel>> getDuas();
  Future<List<DuaModel>> getFavoriteDuas();
  Future<void> toggleFavorite(String duaId);
  Future<List<DuaModel>> searchDuas(String query);
}

class DuasLocalDataSourceImpl implements DuasLocalDataSource {
  static const String _duasAssetPath = 'assets/data/duas.json';
  final Set<String> _favoriteDuaIds = {};
  List<DuaModel>? _cachedDuas;

  @override
  Future<List<DuaModel>> getDuas() async {
    if (_cachedDuas != null) {
      return _cachedDuas!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_duasAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> duasList = jsonData['duas'] ?? [];
      
      _cachedDuas = duasList.map((duaJson) => DuaModel.fromMap(duaJson)).toList();
      return _cachedDuas!;
    } catch (e) {
      throw Exception('Failed to load duas: $e');
    }
  }

  @override
  Future<List<DuaModel>> getFavoriteDuas() async {
    final allDuas = await getDuas();
    return allDuas.where((dua) => _favoriteDuaIds.contains(dua.id)).toList();
  }

  @override
  Future<void> toggleFavorite(String duaId) async {
    if (_favoriteDuaIds.contains(duaId)) {
      _favoriteDuaIds.remove(duaId);
    } else {
      _favoriteDuaIds.add(duaId);
    }
  }

  @override
  Future<List<DuaModel>> searchDuas(String query) async {
    final allDuas = await getDuas();
    final lowerQuery = query.toLowerCase();
    
    return allDuas.where((dua) {
      return dua.title.toLowerCase().contains(lowerQuery) ||
          dua.description.toLowerCase().contains(lowerQuery) ||
          dua.arabicText.contains(query) ||
          dua.transliteration.toLowerCase().contains(lowerQuery) ||
          dua.translation.toLowerCase().contains(lowerQuery) ||
          dua.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
