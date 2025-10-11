import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/storage_service.dart';

class RitualsRemoteDataSource {
  final DioClient _dioClient;
  final StorageService _storageService;

  RitualsRemoteDataSource(this._dioClient, this._storageService);

  Future<List<Map<String, dynamic>>> getRituals() async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/rituals',
        options: options,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch rituals');
      }
    } catch (e) {
      throw Exception('Error fetching rituals: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDuas({String? tag}) async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      // Build query parameters
      Map<String, dynamic>? queryParameters;
      if (tag != null && tag.isNotEmpty) {
        queryParameters = {'tag': tag};
      }

      final response = await _dioClient.get(
        '/api/v1/duas',
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch duas');
      }
    } catch (e) {
      throw Exception('Error fetching duas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRitualProgress(String userId) async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/users/$userId/rituals/progress',
        options: options,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch ritual progress');
      }
    } catch (e) {
      throw Exception('Error fetching ritual progress: $e');
    }
  }

  Future<Map<String, dynamic>> updateRitualProgress(
    String userId,
    String ritualId,
    String status,
  ) async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final data = {'status': status};

      final response = await _dioClient.dio.patch(
        '/api/v1/users/$userId/rituals/$ritualId',
        data: data,
        options: options,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to update ritual progress');
      }
    } catch (e) {
      throw Exception('Error updating ritual progress: $e');
    }
  }
}
