import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahabi_guide/core/network/dio_client.dart';
import 'package:sahabi_guide/features/tracking/data/models/position_model.dart';
import 'package:sahabi_guide/features/tracking/data/models/route_statistics_model.dart';
import 'package:sahabi_guide/core/utils/constants.dart';

/// Repository pour récupérer l'historique des parcours
class RouteHistoryRepository {
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  RouteHistoryRepository({
    required this.dioClient,
    required this.secureStorage,
  });

  /// Récupère le parcours d'un utilisateur entre deux dates
  Future<List<PositionModel>> getRouteHistory(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final response = await dioClient.get(
        '/api/v1/users/$userId/route',
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PositionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get route history: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error getting route history: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error getting route history: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques de parcours
  Future<RouteStatisticsModel> getRouteStatistics(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final response = await dioClient.get(
        '/api/v1/users/$userId/route/statistics',
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return RouteStatisticsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get route statistics: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error getting route statistics: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error getting route statistics: $e');
      rethrow;
    }
  }

  /// Récupère le parcours d'aujourd'hui
  Future<List<PositionModel>> getTodayRoute(String userId) async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final response = await dioClient.get(
        '/api/v1/users/$userId/route/today',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PositionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get today route: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error getting today route: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error getting today route: $e');
      rethrow;
    }
  }
}


