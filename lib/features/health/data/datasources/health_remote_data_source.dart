import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/alert_model.dart';

abstract class HealthRemoteDataSource {
  Future<HealthProfileModel> getHealthProfile(String pilgrimId);
  Future<HealthProfileModel> updateHealthProfile(String pilgrimId, HealthProfileModel profile);
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final DioClient dioClient;

  HealthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<HealthProfileModel> getHealthProfile(String pilgrimId) async {
    try {
      final response = await dioClient.get('/api/v1/pilgrims/$pilgrimId/health-profile');
      return HealthProfileModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil de santé: $e');
    }
  }

  @override
  Future<HealthProfileModel> updateHealthProfile(String pilgrimId, HealthProfileModel profile) async {
    try {
      final response = await dioClient.put(
        '/api/v1/pilgrims/$pilgrimId/health-profile',
        data: profile.toJson(),
      );
      return HealthProfileModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil de santé: $e');
    }
  }
}
