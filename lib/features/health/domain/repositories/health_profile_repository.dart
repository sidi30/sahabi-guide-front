import '../../data/models/health_profile_model.dart';

abstract class HealthProfileRepository {
  Future<HealthProfileModel> getHealthProfile();
  Future<HealthProfileModel> updateHealthProfile(HealthProfileModel profile);
  Future<void> clearLocalCache();
}




