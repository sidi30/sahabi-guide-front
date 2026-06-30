import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';


abstract class RitualsRepository {
  Future<List<RitualModel>> getRituals({bool forceRefresh = false, String? userId, String? gender, String? states, String? lang});
  Future<List<DuaModel>> getDuas();
  Future<RitualModel?> getRitualById(String id);
}