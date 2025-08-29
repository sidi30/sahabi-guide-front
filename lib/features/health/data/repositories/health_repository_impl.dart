import '../../../../shared/models/health_profile_model.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<HealthProfileModel> getHealthProfile(String pilgrimId) async {
    final data = await remoteDataSource.getHealthProfile(pilgrimId);
    return HealthProfileModel.fromMap(data);
  }
}