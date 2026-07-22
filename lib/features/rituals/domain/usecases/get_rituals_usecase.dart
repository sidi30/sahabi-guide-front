import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../repositories/rituals_repository.dart';

class GetRitualsUseCase {
  final RitualsRepository repository;

  GetRitualsUseCase(this.repository);

  Future<List<RitualModel>> call({
    bool forceRefresh = false,
    String? userId,
    String? gender,
    String? states,
    String? lang,
    String? type,
  }) async {
    return await repository.getRituals(
      forceRefresh: forceRefresh,
      userId: userId,
      gender: gender,
      states: states,
      lang: lang,
      type: type,
    );
  }

  Future<List<DuaModel>> getDuas() async {
    return await repository.getDuas();
  }

  Future<RitualModel?> getRitualById(String id) async {
    return await repository.getRitualById(id);
  }
}
