import 'package:dio/dio.dart';
import '../models/health_profile_model.dart';

abstract class HealthProfileRemoteDataSource {
  Future<HealthProfileModel> getHealthProfile(String userId, String token);
  Future<HealthProfileModel> updateHealthProfile(String userId, HealthProfileModel profile, String token);
}

class HealthProfileRemoteDataSourceImpl implements HealthProfileRemoteDataSource {
  final Dio dioClient;

  HealthProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<HealthProfileModel> getHealthProfile(String userId, String token) async {
    try {
      final response = await dioClient.get(
        '/api/v1/auth/users/$userId/health',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return HealthProfileModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la récupération du profil santé');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Profil santé non trouvé, retourner un profil vide
        return HealthProfileModel(userId: userId);
      }
      throw Exception('Erreur de récupération du profil santé: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de récupération du profil santé: $e');
    }
  }

  @override
  Future<HealthProfileModel> updateHealthProfile(
      String userId, HealthProfileModel profile, String token) async {
    try {
      final response = await dioClient.put(
        '/api/v1/auth/users/$userId/health',
        data: profile.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return HealthProfileModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour du profil santé');
      }
    } catch (e) {
      throw Exception('Erreur de mise à jour du profil santé: $e');
    }
  }
}

