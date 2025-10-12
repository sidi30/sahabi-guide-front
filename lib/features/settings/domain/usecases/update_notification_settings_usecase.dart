import '../../data/models/user_settings_model.dart';
import '../repositories/user_settings_repository.dart';

class UpdateNotificationSettingsUseCase {
  final UserSettingsRepository repository;

  UpdateNotificationSettingsUseCase(this.repository);

  Future<UserSettingsModel> call(UserSettingsModel settings) async {
    return await repository.updateNotificationSettings(settings);
  }
}

