import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/dua_model.dart';
import '../../domain/repositories/duas_repository.dart';
import '../datasources/duas_local_data_source.dart';
import '../datasources/duas_remote_data_source.dart';

class DuasRepositoryImpl implements DuasRepository {
  final DuasRemoteDataSource remoteDataSource;
  final DuasLocalDataSource localDataSource;
  final Connectivity connectivity;

  DuasRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<List<DuaModel>> getDuas({String? tag}) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return _getLocalDuas();
      }

      final remoteDuas = await remoteDataSource.getDuas(tag: tag);
      await localDataSource.cacheDuas(remoteDuas);
      return remoteDuas;
    } on ServerException {
      return _getLocalDuas();
    } catch (e) {
      return _getLocalDuas();
    }
  }

  Future<List<DuaModel>> _getLocalDuas() async {
    try {
      return await localDataSource.getCachedDuas();
    } on CacheException {
      return await localDataSource.getLocalDuas();
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
      // Get all duas first
      final allDuas = await getDuas();

      if (query.isEmpty) {
        return allDuas;
      }

      // Filter duas based on the search query
      final filteredDuas = allDuas.where((dua) {
        final textMatch = dua.arabicText.toLowerCase().contains(query.toLowerCase());
        final translationMatch = dua.translation.toLowerCase().contains(query.toLowerCase());
        final tagMatch = dua.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));

        return textMatch || translationMatch || tagMatch;
      }).toList();

      return filteredDuas;
    } catch (e) {
      throw Exception('Failed to search duas: $e');
    }
  }
}
