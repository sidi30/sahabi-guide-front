import '../../../../shared/models/alert_model.dart';
import '../../../../shared/models/pilgrim_alert_model.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<AlertModel>> getAlerts({String? status, String? pilgrimId}) async {
    final data = await remoteDataSource.getAlerts(status: status, pilgrimId: pilgrimId);
    return data.map((alertData) => AlertModel.fromJson(alertData)).toList();
  }

  @override
  Future<AlertModel> createAlert(AlertModel alert) async {
    final data = await remoteDataSource.createAlert(alert.toJson());
    return AlertModel.fromJson(data);
  }

  @override
  Future<List<PilgrimAlertModel>> getPilgrimAlerts(String userId) async {
    final data = await remoteDataSource.getUserAlerts(userId);
    return data.map((alertData) => PilgrimAlertModel.fromMap(alertData)).toList();
  }
}