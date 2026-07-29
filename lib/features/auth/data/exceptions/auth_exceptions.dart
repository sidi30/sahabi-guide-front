/// Exception lancée quand un numéro de passeport n'est pas trouvé dans le système
class PassportNotFoundException implements Exception {
  final String message;

  PassportNotFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception lancée quand la validation du passeport échoue
class PassportValidationException implements Exception {
  final String message;

  PassportValidationException(this.message);

  @override
  String toString() => message;
}

/// Exception lancée quand le code OTP est invalide ou expiré
class OtpInvalidException implements Exception {
  final String message;

  OtpInvalidException(this.message);

  @override
  String toString() => message;
}

/// Exception lancée quand le token est invalide ou expiré
class TokenInvalidException implements Exception {
  final String message;

  TokenInvalidException(this.message);

  @override
  String toString() => message;
}

/// Rejet d'authentification EXPLICITE par le serveur (401/403).
/// Seule cette exception autorise la destruction de la session locale.
class AuthRejectedException implements Exception {
  final String message;

  AuthRejectedException(this.message);

  @override
  String toString() => message;
}

/// Erreur réseau / timeout / 5xx pendant un appel d'auth : ne prouve PAS que
/// la session est invalide. Ne JAMAIS détruire la session sur cette exception.
class AuthNetworkException implements Exception {
  final String message;

  AuthNetworkException(this.message);

  @override
  String toString() => message;
}




