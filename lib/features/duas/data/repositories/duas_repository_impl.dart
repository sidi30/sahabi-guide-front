import '../../domain/repositories/duas_repository.dart';
import '../../../../shared/models/dua_model.dart';
import '../datasources/duas_local_data_source.dart';

class DuasRepositoryImpl implements DuasRepository {
  final DuasLocalDataSource localDataSource;

  DuasRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DuaModel>> getDuas() async {
    try {
      return await localDataSource.getDuas();
    } catch (e) {
      throw Exception('Failed to get duas: $e');
    }
  }

  @override
  Future<List<DuaModel>> getFavoriteDuas() async {
    try {
      return await localDataSource.getFavoriteDuas();
    } catch (e) {
      throw Exception('Failed to get favorite duas: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String duaId) async {
    try {
      await localDataSource.toggleFavorite(duaId);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<DuaModel>> searchDuas(String query) async {
    try {
      return await localDataSource.searchDuas(query);
    } catch (e) {
      throw Exception('Failed to search duas: $e');
    }
  }
}
