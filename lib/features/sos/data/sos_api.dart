import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../domain/sos_request.dart';

/// Confirmation d'un SOS par le serveur. Tant que cet objet n'a pas été
/// obtenu, rien ne permet de dire au pèlerin que son appel est parti.
class SosAcknowledgement {
  const SosAcknowledgement({
    required this.alertId,
    required this.positionRecorded,
    this.createdAt,
  });

  final String alertId;

  /// Le serveur a-t-il enregistré une position avec l'alerte.
  final bool positionRecorded;

  final DateTime? createdAt;
}

/// Échec d'envoi d'un SOS.
///
/// [retryable] sépare « le réseau n'est pas là » (on réessaie tout seul, en
/// boucle) de « le serveur a refusé » (réessayer à l'identique ne changera
/// rien : il faut le dire au pèlerin et lui laisser la main).
class SosSendException implements Exception {
  const SosSendException(
    this.message, {
    required this.retryable,
    this.authRequired = false,
  });

  final String message;
  final bool retryable;

  /// Le serveur ne sait pas qui appelle (401/403). Réessayer à l'identique est
  /// inutile tant que le pèlerin ne s'est pas reconnecté : il faut le lui dire.
  final bool authRequired;

  @override
  String toString() => message;
}

abstract class SosApi {
  /// Envoie [request]. Lève [SosSendException] en cas d'échec.
  Future<SosAcknowledgement> send(SosRequest request);
}

class SosApiImpl implements SosApi {
  SosApiImpl(this._dioClient);

  static const String endpoint = '/api/v1/pilgrims/me/sos';

  final DioClient _dioClient;

  @override
  Future<SosAcknowledgement> send(SosRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        endpoint,
        data: request.toRequestBody(),
      );

      final status = response.statusCode ?? 0;
      final data = response.data;
      if (status != 200 && status != 201) {
        throw SosSendException(
          'Réponse inattendue du serveur ($status)',
          retryable: status >= 500,
        );
      }
      if (data is! Map || data['id'] == null) {
        // Un 200 sans identifiant d'alerte ne prouve rien : le traiter comme un
        // succès serait exactement le faux succès que ce flux doit éviter.
        throw const SosSendException(
          'Réponse du serveur sans identifiant d\'alerte',
          retryable: true,
        );
      }

      return SosAcknowledgement(
        alertId: data['id'].toString(),
        positionRecorded: data['positionRecorded'] == true,
        createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
      );
    } on SosSendException {
      rethrow;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw SosSendException(
        _describe(e),
        retryable: _isRetryable(e),
        authRequired: status == 401 || status == 403,
      );
    } catch (e) {
      // Inconnu : on considère l'envoi comme réessayable plutôt que d'abandonner
      // un appel au secours sur une erreur mal identifiée.
      throw SosSendException(e.toString(), retryable: true);
    }
  }

  /// Sans réponse HTTP (coupure, timeout) ou avec une réponse « réessaie plus
  /// tard », le même envoi finira par passer. Un refus 4xx, non.
  bool _isRetryable(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) return true;
    if (status == 408 || status == 429) return true;
    return status >= 500;
  }

  String _describe(DioException e) {
    final apiError = e.error;
    if (apiError != null && apiError is! Error) return apiError.toString();
    final status = e.response?.statusCode;
    if (status != null) return 'Erreur HTTP $status';
    return e.message ?? 'Erreur réseau';
  }
}
