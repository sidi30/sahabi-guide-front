import '../../../../shared/models/pilgrim_position_model.dart';
import '../../domain/repository/pilgrim_position_repository.dart';
import '../datasources/position_remote_data_source.dart';

class PilgrimPositionRepositoryImpl implements PilgrimPositionRepository {
  final PositionRemoteDataSource remoteDataSource;

  PilgrimPositionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<PilgrimPositionModel> getLatestPilgrimPosition(String pilgrimId) async {
    final data = await remoteDataSource.getLatestPilgrimPosition(pilgrimId);
    return PilgrimPositionModel.fromMap(data);
  }
}