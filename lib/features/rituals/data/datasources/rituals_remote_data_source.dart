import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/ritual_model.dart';

abstract class RitualsRemoteDataSource {
  Future<List<RitualModel>> getRituals();
  Future<List<DuaModel>> getDuas({String? tag});
  Future<List<RitualProgressModel>> getRitualProgress(String pilgrimId);
  Future<void> updateRitualProgress(String pilgrimId, String ritualId, RitualStatus status);
}

class RitualsRemoteDataSourceImpl implements RitualsRemoteDataSource {
  final DioClient dioClient;

  RitualsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<RitualModel>> getRituals() async {
    try {
      final response = await dioClient.get('/api/v1/rituals');
      final List<dynamic> data = response.data;
      return data.map((json) => RitualModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des rituels: $e');
    }
  }

  @override
  Future<List<DuaModel>> getDuas({String? tag}) async {
    try {
      final response = await dioClient.get(
        '/api/v1/duas',
        queryParameters: tag != null ? {'tag': tag} : null,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => DuaModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des duas: $e');
    }
  }

  @override
  Future<List<RitualProgressModel>> getRitualProgress(String pilgrimId) async {
    try {
      final response = await dioClient.get('/api/v1/pilgrims/$pilgrimId/rituals/progress');
      final List<dynamic> data = response.data;
      return data.map((json) => RitualProgressModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération du progrès: $e');
    }
  }

  @override
  Future<void> updateRitualProgress(String pilgrimId, String ritualId, RitualStatus status) async {
    try {
      await dioClient.put(
        '/api/v1/pilgrims/$pilgrimId/rituals/$ritualId',
        data: {'status': status.name},
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du progrès: $e');
    }
  }
}
