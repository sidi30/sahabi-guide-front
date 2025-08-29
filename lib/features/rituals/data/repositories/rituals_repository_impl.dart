import 'dart:developer' as developer;
import '../../../../shared/models/ritual_model.dart';
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
    try {
      if (remoteDataSource != null) {
        // Try to fetch from remote first
        final remoteData = await remoteDataSource!.getRituals();
        return remoteData.map((data) => RitualModel.fromMap(data)).toList();
      }
    } catch (e) {
      // Fallback to local data if remote fails
      developer.log('Failed to fetch rituals from remote: $e', name: 'RitualsRepository');
    }
    return await localDataSource.getRituals();
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
  Future<List<RitualModel>> getDuas() async {
    try {
      if (remoteDataSource != null) {
        // Try to fetch from remote first
        final remoteData = await remoteDataSource!.getDuas();
        return remoteData.map((data) => RitualModel.fromMap(data)).toList();
      } else {
        developer.log('Remote data source is null, fetching duas from local', name: 'RitualsRepository');
      }
    } catch (e) {
      // Fallback to local data if remote fails
      developer.log('Failed to fetch duas from remote: $e', name: 'RitualsRepository');
    }
    return await localDataSource.getDuas();
  }

  @override
  Future<List<RitualModel>> getRitualsByType(RitualType type) async {
    return await localDataSource.getRitualsByType(type);
  }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    await localDataSource.markAsCompleted(ritualId);
  }
  
  @override
  Future<List<RitualModel>> getTodayRituals() {
    return localDataSource.getTodayRituals();
  }

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