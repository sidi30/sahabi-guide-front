/// Configuration des environnements pour l'application Flutter
/// 
/// Ce fichier gère les différents environnements (dev, staging, prod)
/// et les URLs correspondantes pour l'API backend

library;

import 'package:flutter/foundation.dart';

/// Énumération des environnements disponibles
enum Environment {
  development,
  staging,
  production,
}

/// Configuration de l'environnement
class EnvConfig {
  /// Environnement actuel
  static Environment _currentEnvironment = Environment.development;

  /// URLs de base pour l'API selon l'environnement
  static const Map<Environment, String> _apiUrls = {
    // Développement local
    Environment.development: 'http://10.0.2.2:8084',  // Android emulator
    
    // Staging / Test
    Environment.staging: 'https://sahabi-backend-gcobrlag7q-ew.a.run.app',
    
    // Production - Google Cloud Run
    Environment.production: 'https://sahabi-backend-gcobrlag7q-ew.a.run.app',
  };

  // ⚠️ KEYCLOAK NON UTILISÉ DANS L'APP MOBILE
  // L'application mobile utilise l'authentification par PASSEPORT + OTP
  // Keycloak est uniquement pour le dashboard web
  
  /// URLs Keycloak (NON UTILISÉ - conservé pour référence uniquement)
  static const Map<Environment, String> _keycloakUrls = {
    Environment.development: 'http://10.0.2.2:8080',
    Environment.staging: 'https://sahabi-keycloak-520537349678.europe-west1.run.app',
    Environment.production: 'https://sahabi-keycloak-520537349678.europe-west1.run.app',
  };

  /// Realm Keycloak (NON UTILISÉ)
  static const String keycloakRealm = 'sahabi';

  /// Client ID Keycloak (NON UTILISÉ)
  static const String keycloakClientId = 'sahabi-mobile';

  /// Initialiser l'environnement
  static void init(Environment environment) {
    _currentEnvironment = environment;
    if (kDebugMode) {
      print('🌍 Environment: ${environment.name}');
      print('🔗 API URL: ${apiBaseUrl}');
      print('🔐 Keycloak URL: ${keycloakUrl}');
    }
  }

  /// Obtenir l'environnement actuel
  static Environment get environment => _currentEnvironment;

  /// URL de base de l'API
  static String get apiBaseUrl {
    // Permet de surcharger via variable d'environnement
    const envApiUrl = String.fromEnvironment('API_BASE_URL');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }

    // URL spécifique pour le web
    if (kIsWeb) {
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8084',
      );
    }

    // URL selon l'environnement
    return _apiUrls[_currentEnvironment] ?? _apiUrls[Environment.development]!;
  }

  /// URL Keycloak
  static String get keycloakUrl {
    const envKeycloakUrl = String.fromEnvironment('KEYCLOAK_URL');
    if (envKeycloakUrl.isNotEmpty) {
      return envKeycloakUrl;
    }

    if (kIsWeb) {
      return const String.fromEnvironment(
        'KEYCLOAK_URL',
        defaultValue: 'http://localhost:8080',
      );
    }

    return _keycloakUrls[_currentEnvironment] ?? _keycloakUrls[Environment.development]!;
  }

  /// URL complète d'authentification Keycloak
  static String get keycloakAuthUrl => '$keycloakUrl/realms/$keycloakRealm';

  /// Préfixe du chemin de l'API
  static const String apiBasePath = '/api/v1';

  /// URL complète de l'API
  static String get apiFullUrl => '$apiBaseUrl$apiBasePath';

  /// Timeout des requêtes HTTP (en millisecondes)
  static const int httpTimeout = 30000;  // 30 secondes

  /// Timeout de connexion (en millisecondes)
  static const int connectionTimeout = 10000;  // 10 secondes

  /// Est-ce un environnement de développement ?
  static bool get isDevelopment => _currentEnvironment == Environment.development;

  /// Est-ce un environnement de staging ?
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// Est-ce un environnement de production ?
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Activer les logs détaillés (dev et staging uniquement)
  static bool get enableDetailedLogs => !isProduction;

  /// Activer le mode debug de Dio (dev uniquement)
  static bool get enableDioDebugMode => isDevelopment;

  /// Configuration de cache
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const Duration cacheStaleAge = Duration(hours: 48);

  /// Version de l'API supportée
  static const String apiVersion = 'v1';
}

