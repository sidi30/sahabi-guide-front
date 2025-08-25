import 'dart:convert';

import '../../../../core/utils/constants.dart';
import '../../../../shared/models/medical_profile_model.dart';
import '../../../../shared/services/storage_service.dart';

abstract class HealthLocalDataSource {
  Future<MedicalProfileModel?> getMedicalProfile();
  Future<void> cacheMedicalProfile(MedicalProfileModel profile);
}

class HealthLocalDataSourceImpl implements HealthLocalDataSource {
  final StorageService _storageService;

  HealthLocalDataSourceImpl(this._storageService);

  @override
  Future<MedicalProfileModel?> getMedicalProfile() async {
    final jsonStr = await _storageService.getSecurely(AppConstants.medicalProfileKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return MedicalProfileModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheMedicalProfile(MedicalProfileModel profile) async {
    await _storageService.storeSecurely(
      AppConstants.medicalProfileKey,
      json.encode(profile.toMap()),
    );
  }
}
