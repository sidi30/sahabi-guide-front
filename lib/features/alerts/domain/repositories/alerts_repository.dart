import '../../../../shared/models/pilgrim_alert_model.dart';

abstract class AlertsRepository {
  Future<List<PilgrimAlertModel>> getPilgrimAlerts(String pilgrimId);
}