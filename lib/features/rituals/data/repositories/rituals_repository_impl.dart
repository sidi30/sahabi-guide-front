import '../../../../shared/models/ritual_model.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../datasources/rituals_local_data_source.dart';

class RitualsRepositoryImpl implements RitualsRepository {
  final RitualsLocalDataSource localDataSource;

  RitualsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<RitualModel>> getRituals() async {
    return await localDataSource.getRituals();
  }

  @override
  Future<List<RitualModel>> getDuas() async {
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
