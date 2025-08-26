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

  @override
  Future<List<RitualModel>> getDuas() async {
    try {
      if (remoteDataSource != null) {
        // Try to fetch from remote first
        final remoteData = await remoteDataSource!.getDuas();
        return remoteData.map((data) => RitualModel.fromMap(data)).toList();
      }
    } catch (e) {
      // Fallback to local data if remote fails
      developer.log('Failed to fetch duas from remote: $e', name: 'RitualsRepository');
    }
    return await localDataSource.getDuas();
  }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    return await localDataSource.getRitualById(id);
  }

  @override
  Future<void> markRitualAsCompleted(String id) async {
    await localDataSource.markRitualAsCompleted(id);
  }

  @override
  Future<void> updateRitual(RitualModel ritual) async {
    await localDataSource.updateRitual(ritual);
  }
}
