/// Point d'entrée pour l'environnement de STAGING
/// 
/// Utilisation :
/// flutter run -t lib/main_staging.dart --dart-define=API_BASE_URL=https://api-staging.sahabi.com

import 'package:flutter/material.dart';
import 'core/config/env_config.dart';
import 'main.dart' as app;

void main() {
  // Initialiser l'environnement de staging
  EnvConfig.init(Environment.staging);

  // Message de démarrage
  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('🚀 SAHABI GUIDE - ENVIRONNEMENT: STAGING');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('🔗 API URL: ${EnvConfig.apiFullUrl}');
  debugPrint('🔐 Keycloak: ${EnvConfig.keycloakAuthUrl}');
  debugPrint('📱 Mode: ${EnvConfig.isStaging ? "STAGING" : "PROD"}');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('');

  // Lancer l'application
  app.main();
}

