import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/alert_model.dart';

abstract class GeoRemoteDataSource {
  Future<List<Map<String, dynamic>>> getPois({String? agencyId, String? type});
  Future<List<Map<String, dynamic>>> getHotels({String? agencyId});
  Future<Map<String, dynamic>?> getPilgrimHotel(String pilgrimId);
  Future<Map<String, dynamic>> getPilgrimMap(String pilgrimId, {String? from, String? to, String? type});
  Future<PositionModel> getLatestPosition(String pilgrimId);
  Future<List<PositionModel>> getPositionHistory(String pilgrimId);
}

class GeoRemoteDataSourceImpl implements GeoRemoteDataSource {
  final DioClient dioClient;

  GeoRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<Map<String, dynamic>>> getPois({String? agencyId, String? type}) async {
    try {
      final response = await dioClient.get(
        '/api/v1/geo/pois',
        queryParameters: {
          if (agencyId != null) 'agencyId': agencyId,
          if (type != null) 'type': type,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des POIs: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHotels({String? agencyId}) async {
    try {
      final response = await dioClient.get(
        '/api/v1/geo/hotels',
        queryParameters: {
          if (agencyId != null) 'agencyId': agencyId,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des hôtels: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPilgrimHotel(String pilgrimId) async {
    try {
      final response = await dioClient.get('/api/v1/geo/hotels/$pilgrimId');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'hôtel du pèlerin: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPilgrimMap(String pilgrimId, {String? from, String? to, String? type}) async {
    try {
      final response = await dioClient.get(
        '/api/v1/pilgrims/$pilgrimId/map',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (type != null) 'type': type,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la carte du pèlerin: $e');
    }
  }

  @override
  Future<PositionModel> getLatestPosition(String pilgrimId) async {
    try {
      final response = await dioClient.get('/api/v1/pilgrims/$pilgrimId/position/latest');
      return PositionModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la position: $e');
    }
  }

  @override
  Future<List<PositionModel>> getPositionHistory(String pilgrimId) async {
    try {
      final response = await dioClient.get('/api/v1/pilgrims/$pilgrimId/positions');
      final List<dynamic> data = response.data;
      return data.map((json) => PositionModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique des positions: $e');
    }
  }
}
