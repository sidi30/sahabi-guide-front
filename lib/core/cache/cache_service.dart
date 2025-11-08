import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de cache local utilisant SharedPreferences
/// Pour une solution plus robuste en production, considérer Hive ou SQLite
class CacheService {
  static const String _prefix = 'sahabi_cache_';
  static const Duration _defaultTTL = Duration(days: 7);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Sauvegarde des données dans le cache avec métadonnées
  Future<void> set<T>({
    required String key,
    required T data,
    int? contentVersion,
    Duration ttl = _defaultTTL,
  }) async {
    final cacheKey = _prefix + key;
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'contentVersion': contentVersion,
      'expiresAt': DateTime.now().add(ttl).toIso8601String(),
    };

    final jsonString = json.encode(cacheData);
    await _prefs.setString(cacheKey, jsonString);
  }

  /// Récupère les données du cache
  Future<CacheEntry<T>?> get<T>(String key) async {
    final cacheKey = _prefix + key;
    final jsonString = _prefs.getString(cacheKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final cacheData = json.decode(jsonString) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(cacheData['expiresAt'] as String);

      // Vérifier si le cache est expiré
      if (DateTime.now().isAfter(expiresAt)) {
        await clear(key); // Nettoyer le cache expiré
        return null;
      }

      return CacheEntry<T>(
        data: cacheData['data'] as T,
        timestamp: DateTime.parse(cacheData['timestamp'] as String),
        contentVersion: cacheData['contentVersion'] as int?,
        expiresAt: expiresAt,
      );
    } catch (e) {
      // En cas d'erreur de parsing, nettoyer le cache corrompu
      await clear(key);
      return null;
    }
  }

  /// Vérifie si une donnée mise en cache nécessite une mise à jour
  /// en fonction de la version du contenu serveur
  Future<bool> needsUpdate(String key, int? serverContentVersion) async {
    if (serverContentVersion == null) {
      return false; // Pas de versionning serveur
    }

    final cached = await get(key);
    if (cached == null) {
      return true; // Pas de cache
    }

    final cachedVersion = cached.contentVersion;
    if (cachedVersion == null) {
      return true; // Cache sans version
    }

    return serverContentVersion > cachedVersion;
  }

  /// Supprime une entrée du cache
  Future<void> clear(String key) async {
    final cacheKey = _prefix + key;
    await _prefs.remove(cacheKey);
  }

  /// Supprime tout le cache
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Obtient la taille approximative du cache (nombre d'entrées)
  int getCacheSize() {
    return _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;
  }
}

/// Classe représentant une entrée de cache avec métadonnées
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final int? contentVersion;
  final DateTime expiresAt;

  CacheEntry({
    required this.data,
    required this.timestamp,
    this.contentVersion,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get age => DateTime.now().difference(timestamp);
}















