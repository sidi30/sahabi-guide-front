import '../../domain/repositories/geo_repository.dart';
import '../datasources/geo_remote_data_source.dart';

class GeoRepositoryImpl implements GeoRepository {
  final GeoRemoteDataSource remoteDataSource;

  GeoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Map<String, dynamic>>> getPois({String? agencyId, String? type}) async {
    try {
      return await remoteDataSource.getPois(agencyId: agencyId, type: type);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des POIs: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHotels({String? agencyId}) async {
    try {
      return await remoteDataSource.getHotels(agencyId: agencyId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des hôtels: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPilgrimHotel(String pilgrimId) async {
    try {
      return await remoteDataSource.getPilgrimHotel(pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'hôtel du pèlerin: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPilgrimMap(String pilgrimId, {String? from, String? to, String? type}) async {
    try {
      return await remoteDataSource.getPilgrimMap(pilgrimId, from: from, to: to, type: type);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la carte du pèlerin: $e');
    }
  }

  @override
  Future<PositionModel> getLatestPosition(String pilgrimId) async {
    try {
      return await remoteDataSource.getLatestPosition(pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la position: $e');
    }
  }

  @override
  Future<List<PositionModel>> getPositionHistory(String pilgrimId) async {
    try {
      return await remoteDataSource.getPositionHistory(pilgrimId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique des positions: $e');
    }
  }
}
