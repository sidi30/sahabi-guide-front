import '../../../../shared/models/ritual_model.dart';

abstract class RitualsRepository {
  Future<List<RitualModel>> getRituals();
  Future<List<DuaModel>> getDuas({String? tag});
  Future<List<RitualProgressModel>> getRitualProgress(String pilgrimId);
  Future<void> updateRitualProgress(String pilgrimId, String ritualId, RitualStatus status);
  Future<RitualModel?> getRitualById(String id);
  Future<void> markRitualAsCompleted(String id);
  Future<void> updateRitual(RitualModel ritual);
}
