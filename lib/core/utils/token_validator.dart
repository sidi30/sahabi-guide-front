import 'dart:convert';

import 'package:sahabi_guide/core/utils/app_logger.dart';

/// Utilitaire pour valider les tokens JWT côté client
class TokenValidator {

  /// Vérifie si un token JWT est expiré
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      // Ajouter le padding si nécessaire
      final normalizedPayload = _addPaddingIfNeeded(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final claims = json.decode(decoded);

      final exp = claims['exp'] as int?;
      if (exp == null) return true;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Ajouter une marge de sécurité de 5 minutes
      final safeExpirationDate = expirationDate.subtract(const Duration(minutes: 5));

      return now.isAfter(safeExpirationDate);
    } catch (e) {
      AppLogger.error('Erreur lors de la validation du token', error: e);
      return true;
    }
  }

  /// Vérifie si un token JWT est valide (format et expiration)
  static bool isValidToken(String token) {
    if (token.isEmpty) return false;

    final parts = token.split('.');
    if (parts.length != 3) return false;

    return !isTokenExpired(token);
  }

  /// Extrait les claims d'un token JWT
  static Map<String, dynamic>? extractClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = _addPaddingIfNeeded(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'extraction des claims', error: e);
      return null;
    }
  }
  
  /// Extrait l'ID utilisateur du token
  static String? extractUserId(String token) {
    final claims = extractClaims(token);
    return claims?['pilgrimId'] as String?;
  }
  
  /// Extrait le numéro de passeport du token
  static String? extractPassportNo(String token) {
    final claims = extractClaims(token);
    return claims?['passportNo'] as String?;
  }
  
  /// Extrait le type de token
  static String? extractTokenType(String token) {
    final claims = extractClaims(token);
    return claims?['tokenType'] as String?;
  }
  
  /// Ajoute le padding nécessaire pour le base64Url
  static String _addPaddingIfNeeded(String input) {
    final remainder = input.length % 4;
    if (remainder == 0) return input;
    
    final padding = 4 - remainder;
    return input + '=' * padding;
  }
}



