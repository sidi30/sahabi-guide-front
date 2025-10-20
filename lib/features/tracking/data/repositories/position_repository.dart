import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/pilgrim_position_model.dart';

/// Repository pour gérer les positions GPS via l'API
class PositionRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  PositionRepository({
    required DioClient dioClient,
    required FlutterSecureStorage secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  /// Envoie une nouvelle position GPS au serveur
  Future<PilgrimPositionModel> sendPosition({
    required String userId,
    required double lat,
    required double lng,
    double? accuracy,
    int? battery,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/users/$userId/positions',
        data: {
          'lat': lat,
          'lng': lng,
          if (accuracy != null) 'accuracy': accuracy,
          if (battery != null) 'battery': battery,
          if (speed != null) 'speed': speed,
          if (heading != null) 'heading': heading,
          'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
        },
      );

      return PilgrimPositionModel.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère la dernière position d'un utilisateur
  Future<PilgrimPositionModel?> getLatestPosition(String userId) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/users/$userId/position/latest',
      );

      if (response.statusCode == 404) {
        return null;
      }

      return PilgrimPositionModel.fromMap(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  /// Récupère l'historique des positions d'un utilisateur
  Future<List<PilgrimPositionModel>> getPositionHistory({
    required String userId,
    int page = 0,
    int size = 20,
    DateTime? since,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (since != null) 'since': since.toIso8601String(),
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      };

      final response = await _dioClient.get(
        '/api/v1/users/$userId/positions',
        queryParameters: queryParams,
      );

      final content = response.data['content'] as List;
      return content.map((json) => PilgrimPositionModel.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les N dernières positions d'un utilisateur
  Future<List<PilgrimPositionModel>> getLastPositions({
    required String userId,
    int count = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/users/$userId/positions/last',
        queryParameters: {'count': count},
      );

      final list = response.data as List;
      return list.map((json) => PilgrimPositionModel.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Compte le nombre de positions d'un utilisateur
  Future<int> countPositions(String userId) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/users/$userId/positions/count',
      );

      return response.data as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime toutes les positions d'un utilisateur
  Future<void> deleteAllPositions(String userId) async {
    try {
      await _dioClient.delete('/api/v1/users/$userId/positions');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gestion des erreurs
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data?['message'] ?? e.message;
      
      switch (statusCode) {
        case 400:
          return Exception('Données invalides: $message');
        case 401:
          return Exception('Non authentifié');
        case 403:
          return Exception('Accès refusé');
        case 404:
          return Exception('Ressource non trouvée');
        case 500:
          return Exception('Erreur serveur: $message');
        default:
          return Exception('Erreur HTTP $statusCode: $message');
      }
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Timeout: Vérifiez votre connexion');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return Exception('Erreur de connexion: Pas de réseau');
    }
    
    return Exception('Erreur inconnue: ${e.message}');
  }
}


