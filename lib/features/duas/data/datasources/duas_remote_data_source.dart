import 'package:dio/dio.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';

abstract class DuasRemoteDataSource {
  /// Calls the /api/v1/duas endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<DuaModel>> getDuas({String? tag});

  /// Calls the /api/v1/duas/{id} endpoint.
  ///
  /// Returns null if the dua is not found.
  /// Throws a [ServerException] for all other error codes.
  Future<DuaModel?> getDuaById(String id);
}

class DuasRemoteDataSourceImpl implements DuasRemoteDataSource {
  final DioClient dioClient;

  DuasRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DuaModel>> getDuas({String? tag}) async {
    try {
      final queryParameters = tag != null ? {'tag': tag} : <String, String>{};

      AppLogger.debug('GET DUAS -> /api/v1/duas with params: $queryParameters');

      final response = await dioClient.get(
        '/api/v1/duas',
        queryParameters: queryParameters,
      );

      AppLogger.debug('DUAS STATUS: ${response.statusCode}');
      AppLogger.verbose('DUAS BODY: ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List;
        return jsonList
            .map((json) => DuaModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      AppLogger.error('DUAS DIO ERROR: ${e.message}');
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ServerException();
    } catch (e) {
      AppLogger.error('DUAS ERROR: $e');
      throw ServerException();
    }
  }

  @override
  Future<DuaModel?> getDuaById(String id) async {
    try {
      final response = await dioClient.get('/api/v1/duas/$id');

      if (response.statusCode == 200) {
        return DuaModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}
