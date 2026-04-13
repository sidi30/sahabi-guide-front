import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';


abstract class RitualsRepository {
  Future<List<RitualModel>> getRituals({String? userId});
  Future<List<DuaModel>> getDuas();
  Future<RitualModel?> getRitualById(String id);
}