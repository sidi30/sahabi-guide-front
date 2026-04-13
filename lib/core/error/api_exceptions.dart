/// Exceptions personnalisées pour les erreurs API
library;

/// Exception de base pour toutes les erreurs API
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

/// Erreur de timeout de connexion
class TimeoutException extends ApiException {
  TimeoutException([super.message = 'Timeout de connexion'])
      : super(statusCode: 408);
}

/// Erreur d'authentification (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Non autorisé'])
      : super(statusCode: 401);
}

/// Erreur d'accès interdit (403)
class ForbiddenException extends ApiException {
  ForbiddenException([super.message = 'Accès interdit'])
      : super(statusCode: 403);
}

/// Erreur ressource non trouvée (404)
class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Ressource non trouvée'])
      : super(statusCode: 404);
}

/// Erreur de validation (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, {this.errors})
      : super(statusCode: 422);
}

/// Erreur serveur (500+)
class ServerException extends ApiException {
  ServerException([super.message = 'Erreur serveur'])
      : super(statusCode: 500);
}

/// Erreur de connexion réseau
class NetworkException extends ApiException {
  NetworkException([super.message = 'Erreur de connexion réseau']);
}

/// Requête annulée
class CancelException extends ApiException {
  CancelException([super.message = 'Requête annulée']);
}

/// Certificat invalide
class CertificateException extends ApiException {
  CertificateException([super.message = 'Certificat SSL invalide']);
}

/// Erreur inconnue
class UnknownException extends ApiException {
  UnknownException([super.message = 'Erreur inconnue', dynamic originalError])
      : super(originalError: originalError);
}
