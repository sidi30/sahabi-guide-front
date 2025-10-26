import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';


abstract class RitualsRepository {
  Future<List<RitualModel>> getRituals();
  Future<List<DuaModel>> getDuas();
  Future<RitualModel?> getRitualById(String id);
  //Future<List<RitualModel>> getRitualsByType(RitualType type);
  //Future<List<RitualModel>> getTodayRituals();
  //Future<void> markRitualAsCompleted(String id);
  //Future<void> updateRitual(RitualModel ritual);
}