import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/types/types.dart';

class AlertsRemoteDataSource {
  final DioClient _dioClient;
  final StorageService _storageService;

  AlertsRemoteDataSource(this._dioClient, this._storageService);

  Future<List<MapKV>> getPilgrimAlerts(String pilgrimId) async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/pilgrims/$pilgrimId/alerts',
        options: options,
      );

      if (response.statusCode == 200) {
        return List<MapKV>.from(response.data);
      } else {
        throw Exception('Failed to fetch pilgrim alerts');
      }
    } catch (e) {
      throw Exception('Error fetching pilgrim alerts: $e');
    }
  }
}