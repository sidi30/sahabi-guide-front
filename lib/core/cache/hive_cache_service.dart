import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/models/ritual_model.dart';
import '../../shared/models/dua_model.dart';
import 'dart:developer' as developer;

/// Service de cache local utilisant Hive pour une meilleure performance
/// et une gestion hors-ligne optimale
class HiveCacheService {
  // Noms des boxes Hive
  static const String _ritualsBoxName = 'rituals';
  static const String _duasBoxName = 'duas';
  static const String _metadataBoxName = 'cache_metadata';

  // Durée de validité du cache par défaut
  static const Duration _defaultCacheDuration = Duration(days: 7);

  // Boxes Hive
  Box<RitualModel>? _ritualsBox;
  Box<DuaModel>? _duasBox;
  Box<dynamic>? _metadataBox;

  /// Initialise les boxes Hive
  Future<void> initialize() async {
    try {
      // Ouvrir les boxes
      _ritualsBox = await Hive.openBox<RitualModel>(_ritualsBoxName);
      _duasBox = await Hive.openBox<DuaModel>(_duasBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);
      
      developer.log('Hive boxes initialized successfully', name: 'HiveCacheService');
    } catch (e) {
      developer.log('Error initializing Hive boxes: $e', name: 'HiveCacheService');
      rethrow;
    }
  }

  /// Vérifie si les boxes sont initialisées
  bool get isInitialized => 
      _ritualsBox != null && 
      _duasBox != null && 
      _metadataBox != null;

  // ==================== RITUALS ====================

  /// Préfixe d'entrée dans la box rituels pour une clé composite
  /// (gender/type/lang/states). `cacheKey == null` = clé legacy : entrées non
  /// préfixées, telles qu'écrites par les anciennes versions (migration douce).
  String _ritualEntryPrefix(String? cacheKey) =>
      cacheKey == null ? '' : '$cacheKey::';

  /// Clé de métadonnées associée à une clé composite (legacy = 'rituals').
  String _ritualsMetaKey(String? cacheKey) =>
      cacheKey == null ? 'rituals' : 'rituals::$cacheKey';

  bool _entryMatchesKey(String entryKey, String? cacheKey) => cacheKey == null
      ? !entryKey.contains('::')
      : entryKey.startsWith(_ritualEntryPrefix(cacheKey));

  /// Sauvegarde une liste de rituels dans le cache, sous la clé composite
  /// [cacheKey] (null = entrée legacy neutre). Chaque clé a son propre lot
  /// d'entrées : sauvegarder une clé n'écrase pas le cache des autres.
  Future<void> saveRituals(List<RitualModel> rituals,
      {int? contentVersion, String? cacheKey}) async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Effacer uniquement les rituels existants de CETTE clé
      final stale = _ritualsBox!.keys
          .where((k) => _entryMatchesKey(k.toString(), cacheKey))
          .toList();
      await _ritualsBox!.deleteAll(stale);

      // Sauvegarder les nouveaux rituels
      final prefix = _ritualEntryPrefix(cacheKey);
      for (final ritual in rituals) {
        await _ritualsBox!.put('$prefix${ritual.id}', ritual);
      }

      // Sauvegarder les métadonnées
      await _saveMetadata(
        key: _ritualsMetaKey(cacheKey),
        contentVersion: contentVersion,
        itemCount: rituals.length,
      );

      developer.log(
        'Saved ${rituals.length} rituals to cache (key: $cacheKey, version: $contentVersion)',
        name: 'HiveCacheService',
      );
    } catch (e) {
      developer.log('Error saving rituals: $e', name: 'HiveCacheService');
      rethrow;
    }
  }

  /// Récupère les rituels du cache pour la clé composite [cacheKey]
  /// (null = entrées legacy). [allowStale] : servir le cache même expiré
  /// (hors-ligne, mieux vaut du stale que rien) — le TTL reste utilisé pour
  /// déclencher un refresh au retour du réseau.
  Future<List<RitualModel>> getRituals(
      {String? cacheKey, bool allowStale = false}) async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Vérifier si le cache est encore valide
      final isValid = await _isCacheValid(_ritualsMetaKey(cacheKey));

      if (!isValid && !allowStale) {
        developer.log('Rituals cache expired (key: $cacheKey)', name: 'HiveCacheService');
        return [];
      }

      final rituals = _ritualsBox!.keys
          .where((k) => _entryMatchesKey(k.toString(), cacheKey))
          .map((k) => _ritualsBox!.get(k))
          .whereType<RitualModel>()
          .toList();
      developer.log(
          'Loaded ${rituals.length} rituals from cache (key: $cacheKey, stale: ${!isValid})',
          name: 'HiveCacheService');

      return rituals;
    } catch (e) {
      developer.log('Error loading rituals: $e', name: 'HiveCacheService');
      return [];
    }
  }

  /// Récupère un rituel par son ID (toutes clés composites confondues)
  Future<RitualModel?> getRitualById(String id) async {
    if (!isInitialized) return null;

    try {
      final direct = _ritualsBox!.get(id);
      if (direct != null) return direct;
      // Entrées indexées par clé composite : chercher un suffixe '::id'.
      final suffix = '::$id';
      for (final k in _ritualsBox!.keys) {
        if (k.toString().endsWith(suffix)) return _ritualsBox!.get(k);
      }
      return null;
    } catch (e) {
      developer.log('Error loading ritual $id: $e', name: 'HiveCacheService');
      return null;
    }
  }

  /// Met à jour le statut d'un rituel
  Future<void> updateRitualStatus(String ritualId, RitualStatus status, {DateTime? completedAt}) async {
    if (!isInitialized) return;
    
    try {
      // Mettre à jour toutes les entrées de ce rite (legacy + clés composites),
      // sous leur clé de stockage réelle — pas de duplicat sous l'id nu.
      final suffix = '::$ritualId';
      final matching = _ritualsBox!.keys
          .where((k) => k == ritualId || k.toString().endsWith(suffix))
          .toList();
      for (final key in matching) {
        final ritual = _ritualsBox!.get(key);
        if (ritual != null) {
          await _ritualsBox!.put(
            key,
            ritual.copyWith(status: status, completedAt: completedAt),
          );
        }
      }
      if (matching.isNotEmpty) {
        developer.log('Updated ritual $ritualId status to $status', name: 'HiveCacheService');
      }
    } catch (e) {
      developer.log('Error updating ritual status: $e', name: 'HiveCacheService');
    }
  }

  /// Vérifie si le cache des rituels nécessite une mise à jour
  Future<bool> ritualsNeedUpdate(int? serverContentVersion) async {
    if (!isInitialized || serverContentVersion == null) return false;
    
    final metadata = await _getMetadata('rituals');
    if (metadata == null) return true;
    
    final cachedVersion = metadata['contentVersion'] as int?;
    if (cachedVersion == null) return true;
    
    return serverContentVersion > cachedVersion;
  }

  // ==================== DUAS ====================

  /// Sauvegarde une liste de duas dans le cache
  Future<void> saveDuas(List<DuaModel> duas) async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Effacer les duas existantes
      await _duasBox!.clear();
      
      // Sauvegarder les nouvelles duas
      for (final dua in duas) {
        await _duasBox!.put(dua.id, dua);
      }
      
      // Sauvegarder les métadonnées
      await _saveMetadata(
        key: 'duas',
        itemCount: duas.length,
      );
      
      developer.log('Saved ${duas.length} duas to cache', name: 'HiveCacheService');
    } catch (e) {
      developer.log('Error saving duas: $e', name: 'HiveCacheService');
      rethrow;
    }
  }

  /// Récupère toutes les duas du cache. [allowStale] : servir le cache même
  /// expiré (hors-ligne) plutôt que rien ; le TTL garde son rôle de
  /// déclencheur de refresh au retour du réseau.
  Future<List<DuaModel>> getDuas({bool allowStale = false}) async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Vérifier si le cache est encore valide
      final isValid = await _isCacheValid('duas');

      if (!isValid && !allowStale) {
        developer.log('Duas cache expired', name: 'HiveCacheService');
        return [];
      }

      final duas = _duasBox!.values.toList();
      developer.log('Loaded ${duas.length} duas from cache', name: 'HiveCacheService');
      
      return duas;
    } catch (e) {
      developer.log('Error loading duas: $e', name: 'HiveCacheService');
      return [];
    }
  }

  /// Récupère une dua par son ID
  Future<DuaModel?> getDuaById(String id) async {
    if (!isInitialized) return null;
    
    try {
      return _duasBox!.get(id);
    } catch (e) {
      developer.log('Error loading dua $id: $e', name: 'HiveCacheService');
      return null;
    }
  }

  /// Récupère les duas filtrées par tag
  Future<List<DuaModel>> getDuasByTag(String tag) async {
    if (!isInitialized) return [];
    
    try {
      final allDuas = await getDuas();
      return allDuas.where((dua) => dua.tags.contains(tag)).toList();
    } catch (e) {
      developer.log('Error loading duas by tag: $e', name: 'HiveCacheService');
      return [];
    }
  }

  /// Récupère les duas associées à un rituel
  Future<List<DuaModel>> getDuasByRitual(String ritualId) async {
    if (!isInitialized) return [];
    
    try {
      final allDuas = await getDuas();
      return allDuas.where((dua) => dua.ritualId == ritualId).toList();
    } catch (e) {
      developer.log('Error loading duas by ritual: $e', name: 'HiveCacheService');
      return [];
    }
  }

  /// Met à jour une dua (par exemple pour la marquer comme favorite)
  Future<void> updateDua(DuaModel dua) async {
    if (!isInitialized) return;
    
    try {
      await _duasBox!.put(dua.id, dua);
      developer.log('Updated dua ${dua.id}', name: 'HiveCacheService');
    } catch (e) {
      developer.log('Error updating dua: $e', name: 'HiveCacheService');
    }
  }

  // ==================== LAST QUERY ====================

  static const String _lastRitualsQueryKey = 'rituals_last_query';

  /// Persiste les paramètres (gender/type/lang/states/userId) de la dernière
  /// requête rituels, pour que l'auto-sync au retour du réseau resynchronise
  /// le contenu réellement affiché et non une requête neutre.
  Future<void> saveLastRitualsQuery(Map<String, String?> params) async {
    if (_metadataBox == null) return;
    await _metadataBox!.put(_lastRitualsQueryKey, params);
  }

  /// Paramètres de la dernière requête rituels (null si jamais enregistrés).
  Future<Map<String, String?>?> getLastRitualsQuery() async {
    if (_metadataBox == null) return null;
    try {
      final data = _metadataBox!.get(_lastRitualsQueryKey);
      if (data is Map) {
        return data.map((k, v) => MapEntry(k.toString(), v as String?));
      }
      return null;
    } catch (e) {
      developer.log('Error loading last rituals query: $e', name: 'HiveCacheService');
      return null;
    }
  }

  // ==================== METADATA ====================

  /// Sauvegarde les métadonnées du cache
  Future<void> _saveMetadata({
    required String key,
    int? contentVersion,
    int? itemCount,
  }) async {
    if (_metadataBox == null) return;
    
    final metadata = {
      'timestamp': DateTime.now().toIso8601String(),
      'contentVersion': contentVersion,
      'itemCount': itemCount,
      'expiresAt': DateTime.now().add(_defaultCacheDuration).toIso8601String(),
    };
    
    await _metadataBox!.put(key, metadata);
  }

  /// Récupère les métadonnées du cache
  Future<Map<String, dynamic>?> _getMetadata(String key) async {
    if (_metadataBox == null) return null;
    
    try {
      final data = _metadataBox!.get(key);
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      developer.log('Error loading metadata for $key: $e', name: 'HiveCacheService');
      return null;
    }
  }

  /// Vérifie si le cache est encore valide (non expiré)
  Future<bool> _isCacheValid(String key) async {
    final metadata = await _getMetadata(key);
    if (metadata == null) return false;
    
    final expiresAtStr = metadata['expiresAt'] as String?;
    if (expiresAtStr == null) return false;
    
    try {
      final expiresAt = DateTime.parse(expiresAtStr);
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  /// Récupère la date de dernière mise à jour du cache
  Future<DateTime?> getLastUpdateTime(String key) async {
    final metadata = await _getMetadata(key);
    if (metadata == null) return null;
    
    final timestampStr = metadata['timestamp'] as String?;
    if (timestampStr == null) return null;
    
    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Efface tout le cache
  Future<void> clearAll() async {
    if (!isInitialized) return;
    
    try {
      await _ritualsBox!.clear();
      await _duasBox!.clear();
      await _metadataBox!.clear();
      
      developer.log('Cleared all cache', name: 'HiveCacheService');
    } catch (e) {
      developer.log('Error clearing cache: $e', name: 'HiveCacheService');
    }
  }

  /// Efface le cache expiré
  Future<void> clearExpiredCache() async {
    if (!isInitialized) return;
    
    try {
      // Vérifier et effacer les rituels expirés
      if (!await _isCacheValid('rituals')) {
        await _ritualsBox!.clear();
        await _metadataBox!.delete('rituals');
        developer.log('Cleared expired rituals cache', name: 'HiveCacheService');
      }
      
      // Vérifier et effacer les duas expirées
      if (!await _isCacheValid('duas')) {
        await _duasBox!.clear();
        await _metadataBox!.delete('duas');
        developer.log('Cleared expired duas cache', name: 'HiveCacheService');
      }
    } catch (e) {
      developer.log('Error clearing expired cache: $e', name: 'HiveCacheService');
    }
  }

  /// Obtient des statistiques sur le cache
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!isInitialized) return {};
    
    try {
      final ritualsMetadata = await _getMetadata('rituals');
      final duasMetadata = await _getMetadata('duas');
      
      return {
        'rituals': {
          'count': _ritualsBox!.length,
          'lastUpdate': ritualsMetadata?['timestamp'],
          'contentVersion': ritualsMetadata?['contentVersion'],
          'isValid': await _isCacheValid('rituals'),
        },
        'duas': {
          'count': _duasBox!.length,
          'lastUpdate': duasMetadata?['timestamp'],
          'isValid': await _isCacheValid('duas'),
        },
      };
    } catch (e) {
      developer.log('Error getting cache stats: $e', name: 'HiveCacheService');
      return {};
    }
  }

  /// Ferme toutes les boxes (à appeler à la fermeture de l'app)
  Future<void> dispose() async {
    try {
      await _ritualsBox?.close();
      await _duasBox?.close();
      await _metadataBox?.close();
      
      developer.log('Closed all Hive boxes', name: 'HiveCacheService');
    } catch (e) {
      developer.log('Error closing Hive boxes: $e', name: 'HiveCacheService');
    }
  }
}

