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
  Future<List<RitualModel>> getTodayRituals() async {
    try {
      if (remoteDataSource != null) {
        // Try to fetch from remote first
        final remoteData = await remoteDataSource!.getTodayRituals();
        return remoteData.map((data) => RitualModel.fromMap(data)).toList();
      }
    } catch (e) {
      // Fallback to local data if remote fails
      developer.log('Failed to fetch today rituals from remote: $e', name: 'RitualsRepository');
    }
    return await localDataSource.getTodayRituals();
  }

  @override
  Future<List<RitualModel>> getRitualsByType(RitualType type) async {
    return await localDataSource.getRitualsByType(type);
  }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    await localDataSource.markAsCompleted(ritualId);
  }
}
