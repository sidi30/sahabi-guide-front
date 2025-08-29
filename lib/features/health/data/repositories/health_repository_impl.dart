import 'dart:developer' as developer;

import '../../../../shared/models/health_profile_model.dart';
import '../../../../shared/models/medical_profile_model.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<MedicalProfileModel?> getMedicalProfile({bool forceRefresh = false}) async {
    try {
      if (remoteDataSource != null) {
        // Try to fetch from remote first
        final remoteData = await remoteDataSource.getMedicalProfile();
        return remoteData;
      }
    } catch (e) {
      // Fallback to local data if remote fails
      developer.log('Failed to fetch medical profile from remote: $e', name: 'HealthRepository');
    }
  }
  
  @override
  Future<MedicalProfileModel> saveMedicalProfile(MedicalProfileModel profile) {
    return remoteDataSource.saveMedicalProfile(profile);
  }
}