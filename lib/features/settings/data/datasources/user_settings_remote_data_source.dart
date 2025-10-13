import 'package:dio/dio.dart';
import '../models/user_settings_model.dart';

abstract class UserSettingsRemoteDataSource {
  Future<UserSettingsModel> getUserSettings(String token);
  Future<UserSettingsModel> updateUserSettings(String token, UserSettingsModel settings);
  Future<UserSettingsModel> updateNotificationSettings(String token, UserSettingsModel settings);
  Future<UserSettingsModel> resetToDefaults(String token);
}

class UserSettingsRemoteDataSourceImpl implements UserSettingsRemoteDataSource {
  final Dio dioClient;

  UserSettingsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserSettingsModel> getUserSettings(String token) async {
    try {
      final response = await dioClient.get(
        '/api/settings',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserSettingsModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la récupération des paramètres');
      }
    } catch (e) {
      throw Exception('Erreur de récupération des paramètres: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateUserSettings(String token, UserSettingsModel settings) async {
    try {
      final response = await dioClient.put(
        '/api/settings',
        data: settings.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserSettingsModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour des paramètres');
      }
    } catch (e) {
      throw Exception('Erreur de mise à jour des paramètres: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateNotificationSettings(String token, UserSettingsModel settings) async {
    try {
      final response = await dioClient.patch(
        '/api/settings/notifications',
        data: settings.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserSettingsModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour des notifications');
      }
    } catch (e) {
      throw Exception('Erreur de mise à jour des notifications: $e');
    }
  }

  @override
  Future<UserSettingsModel> resetToDefaults(String token) async {
    try {
      final response = await dioClient.post(
        '/api/settings/reset',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserSettingsModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la réinitialisation des paramètres');
      }
    } catch (e) {
      throw Exception('Erreur de réinitialisation des paramètres: $e');
    }
  }
}


