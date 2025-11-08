/// Point d'entrée pour l'environnement de DÉVELOPPEMENT
/// 
/// Utilisation :
/// flutter run -t lib/main_dev.dart

import 'package:flutter/material.dart';
import 'core/config/env_config.dart';
import 'main.dart' as app;

void main() {
  // Initialiser l'environnement de développement
  EnvConfig.init(Environment.development);

  // Message de démarrage
  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('🚀 SAHABI GUIDE - ENVIRONNEMENT: DÉVELOPPEMENT');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('🔗 API URL: ${EnvConfig.apiFullUrl}');
  debugPrint('🔐 Keycloak: ${EnvConfig.keycloakAuthUrl}');
  debugPrint('📱 Mode: ${EnvConfig.isDevelopment ? "DEV" : "PROD"}');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('');

  // Lancer l'application
  app.main();
}

