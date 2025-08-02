import '../../../../shared/models/ritual_model.dart';

abstract class RitualsRepository {
  Future<List<RitualModel>> getRituals();
  Future<List<RitualModel>> getDuas();
  Future<RitualModel?> getRitualById(String id);
  Future<void> markRitualAsCompleted(String id);
  Future<void> updateRitual(RitualModel ritual);
}
