import '../../../../shared/models/dua_model.dart';

abstract class DuasRepository {
  Future<List<DuaModel>> getDuas({String? tag});
  Future<List<DuaModel>> getFavoriteDuas();
  Future<void> toggleFavorite(String duaId);
  Future<List<DuaModel>> searchDuas(String query);
}
