import '../../../../shared/models/pilgrim_position_model.dart';

abstract class PilgrimPositionRepository {
  Future<PilgrimPositionModel> getLatestPilgrimPosition(String pilgrimId);
}
