import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/utils/constants.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardData();
  Future<List<Map<String, dynamic>>> getPrayerTimes();
  Future<Map<String, dynamic>> getUserStats();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;
  final StorageService _storageService;

  HomeRemoteDataSourceImpl(this._dioClient, this._storageService);

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely(AppConstants.authTokenKey);

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      // Note: /api/v1/dashboard n'existe pas côté backend
      // Construction manuelle des données dashboard depuis les endpoints existants
      final Map<String, dynamic> dashboardData = {
        'message': 'Bienvenue sur SahabiGuide',
        'timestamp': DateTime.now().toIso8601String(),
      };

      return dashboardData;
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPrayerTimes() async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely(AppConstants.authTokenKey);

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/auth/users/prayer-times',
        options: options,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch prayer times');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely(AppConstants.authTokenKey);

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      // TODO: Get current user ID from token or storage
      const userId = 'current-user-id'; // Temporary - should be retrieved from auth
      final response = await _dioClient.get(
        '/api/v1/auth/users/$userId/stats',
        options: options,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to fetch user stats');
      }
    } catch (e) {
      throw Exception('Error fetching user stats: $e');
    }
  }
}
