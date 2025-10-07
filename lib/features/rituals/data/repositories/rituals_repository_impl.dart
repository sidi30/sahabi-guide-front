import '../../../../shared/models/ritual_model.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../datasources/rituals_local_data_source.dart';
import '../datasources/rituals_remote_data_source.dart';

class RitualsRepositoryImpl implements RitualsRepository {
  final RitualsLocalDataSource localDataSource;
  final RitualsRemoteDataSource remoteDataSource;

  RitualsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<RitualModel>> getRituals() async {
    try {
      final rituals = await remoteDataSource.getRituals();
      // Cache locally for offline access
      for (final ritual in rituals) {
        await localDataSource.updateRitual(ritual);
      }
      return rituals;
    } catch (e) {
      // Fallback to local data if network fails
      return await localDataSource.getRituals();
    }
  }

  @override
  Future<List<DuaModel>> getDuas({String? tag}) async {
    try {
      return await remoteDataSource.getDuas(tag: tag);
    } catch (e) {
      // Fallback to local data if network fails
      return await localDataSource.getDuas();
    }
  }

  @override
  Future<List<RitualProgressModel>> getRitualProgress(String pilgrimId) async {
    try {
      return await remoteDataSource.getRitualProgress(pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du progrès: $e');
    }
  }

  @override
  Future<void> updateRitualProgress(String pilgrimId, String ritualId, RitualStatus status) async {
    try {
      await remoteDataSource.updateRitualProgress(pilgrimId, ritualId, status);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du progrès: $e');
    }
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
