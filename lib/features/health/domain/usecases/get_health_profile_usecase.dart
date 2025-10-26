import '../../data/models/health_profile_model.dart';
import '../repositories/health_profile_repository.dart';

class GetHealthProfileUseCase {
  final HealthProfileRepository repository;

  GetHealthProfileUseCase(this.repository);

  Future<HealthProfileModel> call() async {
    return await repository.getHealthProfile();
  }
}
