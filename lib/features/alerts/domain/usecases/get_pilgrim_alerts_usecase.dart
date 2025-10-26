import '../../../../shared/models/pilgrim_alert_model.dart';
import '../repositories/alerts_repository.dart';

class GetPilgrimAlertsUseCase {
  final AlertsRepository repository;

  GetPilgrimAlertsUseCase(this.repository);

  Future<List<PilgrimAlertModel>> call(String pilgrimId) async {
    return await repository.getPilgrimAlerts(pilgrimId);
  }
}