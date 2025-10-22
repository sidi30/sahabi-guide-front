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

  /// Sauvegarde une liste de rituels dans le cache
  Future<void> saveRituals(List<RitualModel> rituals, {int? contentVersion}) async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Effacer les rituels existants
      await _ritualsBox!.clear();
      
      // Sauvegarder les nouveaux rituels
      for (final ritual in rituals) {
        await _ritualsBox!.put(ritual.id, ritual);
      }
      
      // Sauvegarder les métadonnées
      await _saveMetadata(
        key: 'rituals',
        contentVersion: contentVersion,
        itemCount: rituals.length,
      );
      
      developer.log(
        'Saved ${rituals.length} rituals to cache (version: $contentVersion)',
        name: 'HiveCacheService',
      );
    } catch (e) {
      developer.log('Error saving rituals: $e', name: 'HiveCacheService');
      rethrow;
    }
  }

  /// Récupère tous les rituels du cache
  Future<List<RitualModel>> getRituals() async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Vérifier si le cache est encore valide
      final isValid = await _isCacheValid('rituals');
      
      if (!isValid) {
        developer.log('Rituals cache expired', name: 'HiveCacheService');
        return [];
      }
      
      final rituals = _ritualsBox!.values.toList();
      developer.log('Loaded ${rituals.length} rituals from cache', name: 'HiveCacheService');
      
      return rituals;
    } catch (e) {
      developer.log('Error loading rituals: $e', name: 'HiveCacheService');
      return [];
    }
  }

  /// Récupère un rituel par son ID
  Future<RitualModel?> getRitualById(String id) async {
    if (!isInitialized) return null;
    
    try {
      return _ritualsBox!.get(id);
    } catch (e) {
      developer.log('Error loading ritual $id: $e', name: 'HiveCacheService');
      return null;
    }
  }

  /// Met à jour le statut d'un rituel
  Future<void> updateRitualStatus(String ritualId, RitualStatus status, {DateTime? completedAt}) async {
    if (!isInitialized) return;
    
    try {
      final ritual = await getRitualById(ritualId);
      if (ritual != null) {
        final updatedRitual = ritual.copyWith(
          status: status,
          completedAt: completedAt,
        );
        await _ritualsBox!.put(ritualId, updatedRitual);
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

  /// Récupère toutes les duas du cache
  Future<List<DuaModel>> getDuas() async {
    if (!isInitialized) {
      throw StateError('HiveCacheService not initialized. Call initialize() first.');
    }

    try {
      // Vérifier si le cache est encore valide
      final isValid = await _isCacheValid('duas');
      
      if (!isValid) {
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

