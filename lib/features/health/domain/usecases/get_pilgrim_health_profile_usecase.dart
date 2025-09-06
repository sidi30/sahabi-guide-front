import '../../../../shared/models/health_profile_model.dart';
import '../repositories/health_repository.dart';

class GetPilgrimHealthProfileUseCase {
  final HealthRepository repository;

  GetPilgrimHealthProfileUseCase(this.repository);

  Future<HealthProfileModel> call(String pilgrimId) async {
    return await repository.getPilgrimHealthProfile(pilgrimId);
  }
}