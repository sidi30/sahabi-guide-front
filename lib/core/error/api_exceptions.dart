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
  TimeoutException([String message = 'Timeout de connexion'])
      : super(message, statusCode: 408);
}

/// Erreur d'authentification (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Non autorisé'])
      : super(message, statusCode: 401);
}

/// Erreur d'accès interdit (403)
class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Accès interdit'])
      : super(message, statusCode: 403);
}

/// Erreur ressource non trouvée (404)
class NotFoundException extends ApiException {
  NotFoundException([String message = 'Ressource non trouvée'])
      : super(message, statusCode: 404);
}

/// Erreur de validation (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  
  ValidationException(String message, {this.errors})
      : super(message, statusCode: 422);
}

/// Erreur serveur (500+)
class ServerException extends ApiException {
  ServerException([String message = 'Erreur serveur'])
      : super(message, statusCode: 500);
}

/// Erreur de connexion réseau
class NetworkException extends ApiException {
  NetworkException([String message = 'Erreur de connexion réseau'])
      : super(message);
}

/// Requête annulée
class CancelException extends ApiException {
  CancelException([String message = 'Requête annulée'])
      : super(message);
}

/// Certificat invalide
class CertificateException extends ApiException {
  CertificateException([String message = 'Certificat SSL invalide'])
      : super(message);
}

/// Erreur inconnue
class UnknownException extends ApiException {
  UnknownException([String message = 'Erreur inconnue', dynamic originalError])
      : super(message, originalError: originalError);
}

