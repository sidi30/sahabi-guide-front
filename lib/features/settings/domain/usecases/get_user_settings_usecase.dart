import '../../data/models/user_settings_model.dart';
import '../repositories/user_settings_repository.dart';

class GetUserSettingsUseCase {
  final UserSettingsRepository repository;

  GetUserSettingsUseCase(this.repository);

  Future<UserSettingsModel> call() async {
    return await repository.getUserSettings();
  }
}

