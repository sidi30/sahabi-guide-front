import '../../../../shared/models/health_profile_model.dart';
import '../repositories/health_repository.dart';

class GetHealthProfileUseCase {
  final HealthRepository repository;

  GetHealthProfileUseCase(this.repository);

  Future<HealthProfileModel> call(String pilgrimId) async {
    return await repository.getHealthProfile(pilgrimId);
  }
}