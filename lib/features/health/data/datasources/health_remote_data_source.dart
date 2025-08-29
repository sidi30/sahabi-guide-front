import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../../../../shared/models/medical_profile_model.dart';
import '../../../../shared/services/storage_service.dart';

abstract class HealthRemoteDataSource {
  Future<MedicalProfileModel> getMedicalProfile();
  Future<MedicalProfileModel> saveMedicalProfile(MedicalProfileModel profile);
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final DioClient _dioClient;
  final StorageService _storageService;

  HealthRemoteDataSourceImpl(this._dioClient, this._storageService);

  Options _buildAuthOptions(String? token) {
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return Options(headers: headers);
  }

  @override
  Future<MedicalProfileModel> getMedicalProfile() async {
    try {
      final token = await _storageService.getSecurely(AppConstants.authTokenKey);
      final response = await _dioClient.get(
        '/api/v1/health/profile',
        options: _buildAuthOptions(token),
      );
      if (response.statusCode == 200) {
        return MedicalProfileModel.fromMap(Map<String, dynamic>.from(response.data));
      }
      throw Exception('Failed to fetch medical profile');
    } catch (e) {
      throw Exception('Error fetching medical profile: $e');
    }
  }

  @override
  Future<MedicalProfileModel> saveMedicalProfile(MedicalProfileModel profile) async {
    try {
      final token = await _storageService.getSecurely(AppConstants.authTokenKey);
      final response = await _dioClient.put(
        '/api/v1/health/profile',
        data: profile.toMap(),
        options: _buildAuthOptions(token),
      );
      if (response.statusCode == 200) {
        return MedicalProfileModel.fromMap(Map<String, dynamic>.from(response.data));
      }
      throw Exception('Failed to save medical profile');
    } catch (e) {
      throw Exception('Error saving medical profile: $e');
    }
  }
}
