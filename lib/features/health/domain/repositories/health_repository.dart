
abstract class HealthRepository {
  Future<MedicalProfileModel?> getMedicalProfile({bool forceRefresh});
  Future<MedicalProfileModel> saveMedicalProfile(MedicalProfileModel profile);
}
