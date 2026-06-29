import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../repositories/rituals_repository.dart';

class GetRitualsUseCase {
  final RitualsRepository repository;

  GetRitualsUseCase(this.repository);

  Future<List<RitualModel>> call({
    String? userId,
    String? gender,
    String? states,
    String? lang,
  }) async {
    return await repository.getRituals(
      userId: userId,
      gender: gender,
      states: states,
      lang: lang,
    );
  }

  Future<List<DuaModel>> getDuas() async {
    return await repository.getDuas();
  }

  Future<RitualModel?> getRitualById(String id) async {
    return await repository.getRitualById(id);
  }
}
