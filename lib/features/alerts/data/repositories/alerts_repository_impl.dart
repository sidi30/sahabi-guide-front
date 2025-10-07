import '../../../../shared/models/alert_model.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AlertModel>> getAlerts({String? status, String? pilgrimId}) async {
    try {
      return await remoteDataSource.getAlerts(status: status, pilgrimId: pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des alertes: $e');
    }
  }

  @override
  Future<List<AlertModel>> getPilgrimAlerts(String pilgrimId) async {
    try {
      return await remoteDataSource.getPilgrimAlerts(pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des alertes du pèlerin: $e');
    }
  }

  @override
  Future<AlertModel> createAlert(AlertModel alert) async {
    try {
      return await remoteDataSource.createAlert(alert);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'alerte: $e');
    }
  }
}
