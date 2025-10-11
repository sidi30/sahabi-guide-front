import '../../../../shared/models/alert_model.dart';

abstract class AlertsRepository {
  Future<List<AlertModel>> getAlerts({String? status, String? pilgrimId});
  Future<List<AlertModel>> getPilgrimAlerts(String pilgrimId);
  Future<AlertModel> createAlert(AlertModel alert);
}
