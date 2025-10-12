import '../../data/models/user_settings_model.dart';

abstract class UserSettingsRepository {
  Future<UserSettingsModel> getUserSettings();
  Future<UserSettingsModel> updateUserSettings(UserSettingsModel settings);
  Future<UserSettingsModel> updateNotificationSettings(UserSettingsModel settings);
  Future<UserSettingsModel> resetToDefaults();
  Future<void> clearLocalCache();
}

