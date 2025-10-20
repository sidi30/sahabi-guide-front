import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/sharing_link_model.dart';

/// Service pour gérer les liens de partage de localisation
class LocationSharingService {
  final DioClient _dioClient;

  LocationSharingService({required DioClient dioClient}) : _dioClient = dioClient;

  /// Crée un nouveau lien de partage
  Future<SharingLinkModel> createSharingLink({
    required String userId,
    int expiresInDays = 30,
    String? familyMemberName,
    String? description,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/users/$userId/sharing/links',
        data: {
          'expiresInDays': expiresInDays,
          if (familyMemberName != null) 'familyMemberName': familyMemberName,
          if (description != null) 'description': description,
        },
      );

      return SharingLinkModel.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère tous les liens actifs
  Future<List<SharingLinkModel>> getActiveLinks(String userId) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/users/$userId/sharing/links',
        queryParameters: {'activeOnly': true},
      );

      final list = response.data as List;
      return list.map((json) => SharingLinkModel.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère tous les liens (actifs et inactifs)
  Future<List<SharingLinkModel>> getAllLinks(String userId) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/users/$userId/sharing/links',
        queryParameters: {'activeOnly': false},
      );

      final list = response.data as List;
      return list.map((json) => SharingLinkModel.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Révoque un lien de partage
  Future<void> revokeLink({
    required String userId,
    required String linkId,
  }) async {
    try {
      await _dioClient.put(
        '/api/v1/users/$userId/sharing/links/$linkId/revoke',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime un lien de partage
  Future<void> deleteLink({
    required String userId,
    required String linkId,
  }) async {
    try {
      await _dioClient.delete(
        '/api/v1/users/$userId/sharing/links/$linkId',
      );
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

