import '../../../../shared/models/alert_model.dart';
import '../../../../shared/models/pilgrim_alert_model.dart';

abstract class AlertsRepository {
  Future<List<AlertModel>> getAlerts({String? status, String? pilgrimId});
  Future<AlertModel> createAlert(AlertModel alert);
  Future<List<PilgrimAlertModel>> getPilgrimAlerts(String pilgrimId);
}