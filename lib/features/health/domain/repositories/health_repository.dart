import '../../../../shared/models/health_profile_model.dart';

abstract class HealthRepository {
  Future<HealthProfileModel> getHealthProfile(String pilgrimId);
  Future<HealthProfileModel> updateHealthProfile(String pilgrimId, HealthProfileModel profile);
}
