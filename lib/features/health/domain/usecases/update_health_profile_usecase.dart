import '../../data/models/health_profile_model.dart';
import '../repositories/health_profile_repository.dart';

class UpdateHealthProfileUseCase {
  final HealthProfileRepository repository;

  UpdateHealthProfileUseCase(this.repository);

  Future<HealthProfileModel> call(HealthProfileModel profile) async {
    return await repository.updateHealthProfile(profile);
  }
}




