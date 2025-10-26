import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/dua_model.dart';

abstract class DuasLocalDataSource {
  Future<List<DuaModel>> getCachedDuas();
  Future<void> cacheDuas(List<DuaModel> duasToCache);
  Future<List<DuaModel>> getLocalDuas();
  Future<List<DuaModel>> getFavoriteDuas();
  Future<void> toggleFavorite(String duaId);
  Future<List<DuaModel>> searchDuas(String query);
}

class DuasLocalDataSourceImpl implements DuasLocalDataSource {
  static const String _duasAssetPath = 'assets/data/duas.json';
  static const String CACHED_DUAS_KEY = 'CACHED_DUAS';
  final Set<String> _favoriteDuaIds = {};
  final SharedPreferences sharedPreferences;

  DuasLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<DuaModel>> getCachedDuas() async {
    final jsonString = sharedPreferences.getString(CACHED_DUAS_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(
        jsonList.map((item) => DuaModel.fromJson(item)).toList(),
      );
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDuas(List<DuaModel> duasToCache) {
    return sharedPreferences.setString(
      CACHED_DUAS_KEY,
      json.encode(duasToCache.map((dua) => dua.toJson()).toList()),
    );
  }

  @override
  Future<List<DuaModel>> getLocalDuas() async {
    try {
      final String jsonString = await rootBundle.loadString(_duasAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => DuaModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<DuaModel>> getFavoriteDuas() async {
    final allDuas = await getLocalDuas();
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
    final allDuas = await getLocalDuas();
    final lowerQuery = query.toLowerCase();

    return allDuas.where((dua) {
      return dua.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          dua.arabicText.toLowerCase().contains(lowerQuery) ||
          dua.translation.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
