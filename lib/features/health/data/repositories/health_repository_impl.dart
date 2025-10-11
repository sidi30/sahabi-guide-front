import '../../../../shared/models/alert_model.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HealthProfileModel> getHealthProfile(String pilgrimId) async {
    try {
      return await remoteDataSource.getHealthProfile(pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil de santé: $e');
    }
  }

  @override
  Future<HealthProfileModel> updateHealthProfile(String pilgrimId, HealthProfileModel profile) async {
    try {
      return await remoteDataSource.updateHealthProfile(pilgrimId, profile);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil de santé: $e');
    }
  }
}
