import '../../../../shared/models/pilgrim_alert_model.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<PilgrimAlertModel>> getPilgrimAlerts(String userId) async {
    final data = await remoteDataSource.getUserAlerts(userId);
    return data.map((alertData) => PilgrimAlertModel.fromMap(alertData)).toList();
  }
}