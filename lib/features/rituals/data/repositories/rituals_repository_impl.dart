import 'dart:developer' as developer;
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../datasources/rituals_local_data_source.dart';
import '../datasources/rituals_remote_data_source.dart';

class RitualsRepositoryImpl implements RitualsRepository {
  final RitualsLocalDataSource localDataSource;
  final RitualsRemoteDataSource? remoteDataSource;

  RitualsRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<List<RitualModel>> getRituals() async {
    // Strategy: Offline-first with API sync
    // 1. Load from cache immediately (fast UI)
    // 2. Try to fetch from API (latest data)
    // 3. Update cache if API succeeds
    // 4. Fallback to cache if API fails
    
    List<RitualModel> cachedRituals = [];
    
    try {
      // Step 1: Load from local cache first
      cachedRituals = await localDataSource.getRituals();
      developer.log('Loaded ${cachedRituals.length} rituals from cache', name: 'RitualsRepository');
    } catch (e) {
      developer.log('Failed to load rituals from cache: $e', name: 'RitualsRepository');
    }
    
    // Step 2: Try to fetch fresh data from API
    if (remoteDataSource != null) {
      try {
        final remoteData = await remoteDataSource!.getRituals();
        final rituals = remoteData.map((data) => RitualModel.fromJson(data)).toList();
        
        // Déterminer la version de contenu maximale (pour cache)
        int? maxContentVersion;
        if (rituals.isNotEmpty && rituals.first.contentVersion != null) {
          maxContentVersion = rituals
              .map((r) => r.contentVersion ?? 0)
              .reduce((a, b) => a > b ? a : b);
        }
        
        // Step 3: Save to cache
        await localDataSource.saveRituals(rituals, contentVersion: maxContentVersion);
        developer.log('Saved ${rituals.length} rituals to cache (version: $maxContentVersion)', name: 'RitualsRepository');
        
        return rituals;
      } catch (e) {
        developer.log('Failed to fetch rituals from API: $e', name: 'RitualsRepository');
        // Step 4: Fallback to cache if API fails
        if (cachedRituals.isNotEmpty) {
          developer.log('Using cached rituals as fallback', name: 'RitualsRepository');
          return cachedRituals;
        }
        rethrow; // Si pas de cache et API KO, propager l'erreur
      }
    }
    
    // Si pas de remote data source configuré, utiliser le cache
    return cachedRituals;
  }

  // @override
  // Future<List<RitualModel>> getTodayRituals() async {
  //   try {
  //     if (remoteDataSource != null) {
  //       // Try to fetch from remote first
  //       final remoteData = await remoteDataSource!.getTodayRituals();
  //       return remoteData.map((data) => RitualModel.fromMap(data)).toList();
  //     }
  //   } catch (e) {
  //     // Fallback to local data if remote fails
  //     developer.log('Failed to fetch today rituals from remote: $e', name: 'RitualsRepository');
  //   }
  //   return await localDataSource.getTodayRituals();
  // }

  // get duas
  @override
  Future<List<DuaModel>> getDuas() async {
    // Strategy similaire: Offline-first
    List<DuaModel> cachedDuas = [];
    
    try {
      cachedDuas = await localDataSource.getDuas();
      developer.log('Loaded ${cachedDuas.length} duas from cache', name: 'RitualsRepository');
    } catch (e) {
      developer.log('Failed to load duas from cache: $e', name: 'RitualsRepository');
    }
    
    if (remoteDataSource != null) {
      try {
        final remoteData = await remoteDataSource!.getDuas();
        final duas = remoteData.map((data) => DuaModel.fromJson(data)).toList();
        
        // Save to cache
        await localDataSource.saveDuas(duas);
        developer.log('Saved ${duas.length} duas to cache', name: 'RitualsRepository');
        
        return duas;
      } catch (e) {
        developer.log('Failed to fetch duas from API: $e', name: 'RitualsRepository');
        if (cachedDuas.isNotEmpty) {
          developer.log('Using cached duas as fallback', name: 'RitualsRepository');
          return cachedDuas;
        }
        rethrow;
      }
    }
    
    return cachedDuas;
  }

  // @override
  // Future<List<RitualModel>> getRitualsByType(RitualType type) async {
  //   return await localDataSource.getRitualsByType(type);
  // }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    await localDataSource.markAsCompleted(ritualId);
  }
  
  // @override
  // Future<List<RitualModel>> getTodayRituals() {
  //   return localDataSource.getTodayRituals();
  // }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    final rituals = await localDataSource.getRituals();
    try {
      return rituals.firstWhere((ritual) => ritual.id == id);
    } catch (e) {
      developer.log('Ritual with id $id not found: $e', name: 'RitualsRepository');
      return null;
    }
  }
}