import '../../../../shared/models/pilgrim_position_model.dart';
import '../repository/pilgrim_position_repository.dart';

class GetLatestPilgrimPositionUseCase {
  final PilgrimPositionRepository repository;

  GetLatestPilgrimPositionUseCase(this.repository);

  Future<PilgrimPositionModel> call(String pilgrimId) async {
    return await repository.getLatestPilgrimPosition(pilgrimId);
  }
}
