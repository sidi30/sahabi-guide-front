import '../../domain/repositories/user_settings_repository.dart';
import '../datasources/user_settings_local_data_source.dart';
import '../datasources/user_settings_remote_data_source.dart';
import '../models/user_settings_model.dart';
import '../../../auth/data/datasources/passport_auth_local_data_source.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final UserSettingsRemoteDataSource remoteDataSource;
  final UserSettingsLocalDataSource localDataSource;
  final PassportAuthLocalDataSource authLocalDataSource;

  UserSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  Future<String> _getToken() async {
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }
    return token;
  }

  @override
  Future<UserSettingsModel> getUserSettings() async {
    try {
      // Essayer d'abord le cache local
      final cachedSettings = await localDataSource.getCachedSettings();
      if (cachedSettings != null) {
        // Récupérer depuis le serveur en arrière-plan pour la prochaine fois
        _refreshSettings();
        return cachedSettings;
      }

      // Si pas de cache, récupérer depuis le serveur
      final token = await _getToken();
      final settings = await remoteDataSource.getUserSettings(token);
      
      // Mettre en cache
      await localDataSource.cacheSettings(settings);
      
      return settings;
    } catch (e) {
      // Si erreur réseau, retourner le cache si disponible
      final cachedSettings = await localDataSource.getCachedSettings();
      if (cachedSettings != null) {
        return cachedSettings;
      }
      throw Exception('Erreur de récupération des paramètres: $e');
    }
  }

  Future<void> _refreshSettings() async {
    try {
      final token = await _getToken();
      final settings = await remoteDataSource.getUserSettings(token);
      await localDataSource.cacheSettings(settings);
    } catch (e) {
      print('Erreur lors du rafraîchissement des paramètres: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateUserSettings(UserSettingsModel settings) async {
    try {
      final token = await _getToken();
      final updatedSettings = await remoteDataSource.updateUserSettings(token, settings);
      
      // Mettre à jour le cache
      await localDataSource.cacheSettings(updatedSettings);
      
      return updatedSettings;
    } catch (e) {
      throw Exception('Erreur de mise à jour des paramètres: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateNotificationSettings(UserSettingsModel settings) async {
    try {
      final token = await _getToken();
      final updatedSettings = await remoteDataSource.updateNotificationSettings(token, settings);
      
      // Mettre à jour le cache
      await localDataSource.cacheSettings(updatedSettings);
      
      return updatedSettings;
    } catch (e) {
      throw Exception('Erreur de mise à jour des notifications: $e');
    }
  }

  @override
  Future<UserSettingsModel> resetToDefaults() async {
    try {
      final token = await _getToken();
      final defaultSettings = await remoteDataSource.resetToDefaults(token);
      
      // Mettre à jour le cache
      await localDataSource.cacheSettings(defaultSettings);
      
      return defaultSettings;
    } catch (e) {
      throw Exception('Erreur de réinitialisation des paramètres: $e');
    }
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }
}


