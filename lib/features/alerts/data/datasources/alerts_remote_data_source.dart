import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/types/types.dart';

class AlertsRemoteDataSource {
  final DioClient _dioClient;
  final StorageService _storageService;

  AlertsRemoteDataSource(this._dioClient, this._storageService);

  Future<List<MapKV>> getAlerts({String? status, String? pilgrimId}) async {
    try {
      final token = await _storageService.getSecurely('auth_token');
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/alerts',
        queryParameters: {
          if (status != null) 'status': status,
          if (pilgrimId != null) 'pilgrimId': pilgrimId,
        },
        options: options,
      );

      if (response.statusCode == 200) {
        return List<MapKV>.from(response.data);
      } else {
        throw Exception('Failed to fetch alerts');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  Future<MapKV> createAlert(MapKV alertData) async {
    try {
      final token = await _storageService.getSecurely('auth_token');
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.post(
        '/api/v1/alerts',
        data: alertData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MapKV.from(response.data);
      } else {
        throw Exception('Failed to create alert');
      }
    } catch (e) {
      throw Exception('Error creating alert: $e');
    }
  }

  Future<List<MapKV>> getUserAlerts(String userId) async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/auth/users/$userId/alerts',
        options: options,
      );

      if (response.statusCode == 200) {
        return List<MapKV>.from(response.data);
      } else {
        throw Exception('Failed to fetch user alerts');
      }
    } catch (e) {
      throw Exception('Error fetching user alerts: $e');
    }
  }
}