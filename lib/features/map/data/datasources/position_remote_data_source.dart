import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/types/types.dart';

class PositionRemoteDataSource {
  final DioClient _dioClient;
  final StorageService _storageService;

  PositionRemoteDataSource(this._dioClient, this._storageService);

  Future<MapKV> getLatestPilgrimPosition(String pilgrimId) async {
    try {
      // Get auth token if available
      final token = await _storageService.getSecurely('auth_token');

      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dioClient.get(
        '/api/v1/pilgrims/$pilgrimId/position/latest',
        options: options,
      );

      if (response.statusCode == 200) {
        return MapKV.from(response.data);
      } else {
        throw Exception('Failed to fetch pilgrim position');
      }
    } catch (e) {
      throw Exception('Error fetching pilgrim position: $e');
    }
  }
}