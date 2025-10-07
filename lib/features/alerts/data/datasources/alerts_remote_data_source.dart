import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/alert_model.dart';

abstract class AlertsRemoteDataSource {
  Future<List<AlertModel>> getAlerts({String? status, String? pilgrimId});
  Future<List<AlertModel>> getPilgrimAlerts(String pilgrimId);
  Future<AlertModel> createAlert(AlertModel alert);
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  final DioClient dioClient;

  AlertsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<AlertModel>> getAlerts({String? status, String? pilgrimId}) async {
    try {
      final response = await dioClient.get(
        '/api/v1/alerts',
        queryParameters: {
          if (status != null) 'status': status,
          if (pilgrimId != null) 'pilgrimId': pilgrimId,
        },
      );
      final List<dynamic> data = response.data;
      return data.map((json) => AlertModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des alertes: $e');
    }
  }

  @override
  Future<List<AlertModel>> getPilgrimAlerts(String pilgrimId) async {
    try {
      final response = await dioClient.get('/api/v1/pilgrims/$pilgrimId/alerts');
      final List<dynamic> data = response.data;
      return data.map((json) => AlertModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des alertes du pèlerin: $e');
    }
  }

  @override
  Future<AlertModel> createAlert(AlertModel alert) async {
    try {
      final response = await dioClient.post(
        '/api/v1/alerts',
        data: alert.toJson(),
      );
      return AlertModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'alerte: $e');
    }
  }
}
