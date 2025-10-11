import '../../../../shared/models/alert_model.dart';
import '../repositories/alerts_repository.dart';

class GetAlertsUseCase {
  final AlertsRepository repository;

  GetAlertsUseCase(this.repository);

  Future<List<AlertModel>> call({String? status, String? pilgrimId}) async {
    return await repository.getAlerts(status: status, pilgrimId: pilgrimId);
  }
}

class GetPilgrimAlertsUseCase {
  final AlertsRepository repository;

  GetPilgrimAlertsUseCase(this.repository);

  Future<List<AlertModel>> call(String pilgrimId) async {
    return await repository.getPilgrimAlerts(pilgrimId);
  }
}

class CreateAlertUseCase {
  final AlertsRepository repository;

  CreateAlertUseCase(this.repository);

  Future<AlertModel> call(AlertModel alert) async {
    return await repository.createAlert(alert);
  }
}
