import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_settings_model.dart';

abstract class UserSettingsLocalDataSource {
  Future<UserSettingsModel?> getCachedSettings();
  Future<void> cacheSettings(UserSettingsModel settings);
  Future<void> clearCache();
}

class UserSettingsLocalDataSourceImpl implements UserSettingsLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _settingsKey = 'user_settings';

  UserSettingsLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<UserSettingsModel?> getCachedSettings() async {
    try {
      final settingsJson = await secureStorage.read(key: _settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        return UserSettingsModel.fromJson(settingsMap);
      }
      return null;
    } catch (e) {
      AppLogger.error('Erreur lors de la lecture des paramètres en cache', error: e);
      return null;
    }
  }

  @override
  Future<void> cacheSettings(UserSettingsModel settings) async {
    try {
      final settingsJson = json.encode(settings.toJson());
      await secureStorage.write(key: _settingsKey, value: settingsJson);
    } catch (e) {
      AppLogger.error('Erreur lors de la mise en cache des paramètres', error: e);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: _settingsKey);
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du cache des paramètres', error: e);
    }
  }
}




