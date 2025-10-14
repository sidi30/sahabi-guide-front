import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/models/dua_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';

abstract class DuasRemoteDataSource {
  /// Calls the https://sahabi-care-api-production.up.railway.app/api/v1/duas endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<DuaModel>> getDuas({String? tag});

  /// Calls the https://sahabi-care-api-production.up.railway.app/api/v1/duas/{id} endpoint.
  ///
  /// Returns null if the dua is not found.
  /// Throws a [ServerException] for all other error codes.
  Future<DuaModel?> getDuaById(String id);
}

class DuasRemoteDataSourceImpl implements DuasRemoteDataSource {
  final http.Client client;
  final String baseUrl = AppConstants.apiBaseUrl;

  DuasRemoteDataSourceImpl({required this.client});

  @override
  Future<List<DuaModel>> getDuas({String? tag}) async {
    try {
      final queryParameters = tag != null ? {'tag': tag} : <String, String>{};
      final uri = Uri.parse('$baseUrl/api/v1/duas')
          .replace(queryParameters: queryParameters);

      // Debug network trace
      // ignore: avoid_print
      print('*** GET DUAS *** -> $uri');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // ignore: avoid_print
      print('*** DUAS STATUS: ${response.statusCode}');
      // ignore: avoid_print
      print('*** DUAS BODY: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => DuaModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ServerException();
      }
    } catch (e) {
      // ignore: avoid_print
      print('*** DUAS ERROR: $e');
      throw ServerException();
    }
  }

  @override
  Future<DuaModel?> getDuaById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/duas/$id');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return DuaModel.fromJson(json as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
