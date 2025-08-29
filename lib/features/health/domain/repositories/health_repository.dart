
import '../../../../shared/models/medical_profile_model.dart';

abstract class HealthRepository {
  Future<MedicalProfileModel?> getMedicalProfile({bool forceRefresh});
  Future<MedicalProfileModel> saveMedicalProfile(MedicalProfileModel profile);
}
