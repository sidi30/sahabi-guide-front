
import '../../../../shared/models/health_profile_model.dart';
import '../../../../shared/models/medical_profile_model.dart';

abstract class HealthRepository {
  Future<MedicalProfileModel?> getMedicalProfile({bool forceRefresh});
  Future<MedicalProfileModel> saveMedicalProfile(MedicalProfileModel profile);
  Future<HealthProfileModel> getPilgrimHealthProfile(String pilgrimId);
}
