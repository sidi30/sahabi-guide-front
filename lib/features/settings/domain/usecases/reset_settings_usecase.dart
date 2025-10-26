import '../../data/models/user_settings_model.dart';
import '../repositories/user_settings_repository.dart';

class ResetSettingsUseCase {
  final UserSettingsRepository repository;

  ResetSettingsUseCase(this.repository);

  Future<UserSettingsModel> call() async {
    return await repository.resetToDefaults();
  }
}




