import '../../../../shared/models/medical_profile_model.dart';
import '../repositories/health_repository.dart';

class GetHealthProfileUseCase {
  final HealthRepository repository;

  GetHealthProfileUseCase(this.repository);

  Future<MedicalProfileModel?> call() async {
    return  await repository.getMedicalProfile(forceRefresh: true);
  }
}