import '../../data/models/user_settings_model.dart';
import '../repositories/user_settings_repository.dart';

class UpdateUserSettingsUseCase {
  final UserSettingsRepository repository;

  UpdateUserSettingsUseCase(this.repository);

  Future<UserSettingsModel> call(UserSettingsModel settings) async {
    return await repository.updateUserSettings(settings);
  }
}

