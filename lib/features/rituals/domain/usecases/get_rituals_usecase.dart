import '../../../../shared/models/ritual_model.dart';
import '../repositories/rituals_repository.dart';

class GetRitualsUseCase {
  final RitualsRepository repository;

  GetRitualsUseCase(this.repository);

  Future<List<RitualModel>> call() async {
    return await repository.getRituals();
  }

  Future<List<RitualModel>> getDuas() async {
    return await repository.getDuas();
  }

  Future<RitualModel?> getRitualById(String id) async {
    return await repository.getRitualById(id);
  }
}
