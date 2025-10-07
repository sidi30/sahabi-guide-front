import '../../../../shared/models/alert_model.dart';
import '../repositories/health_repository.dart';

class GetHealthProfileUseCase {
  final HealthRepository repository;

  GetHealthProfileUseCase(this.repository);

  Future<HealthProfileModel> call(String pilgrimId) async {
    return await repository.getHealthProfile(pilgrimId);
  }
}

class UpdateHealthProfileUseCase {
  final HealthRepository repository;

  UpdateHealthProfileUseCase(this.repository);

  Future<HealthProfileModel> call(String pilgrimId, HealthProfileModel profile) async {
    return await repository.updateHealthProfile(pilgrimId, profile);
  }
}
