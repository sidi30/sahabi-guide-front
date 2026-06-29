// Point d'entrée pour l'environnement de STAGING
//
// Utilisation :
// flutter run -t lib/main_staging.dart --dart-define=API_BASE_URL=https://api-staging.sahabi.com

import 'core/config/env_config.dart';
import 'core/utils/app_logger.dart';
import 'main.dart' as app;

void main() {
  // Initialiser l'environnement de staging
  EnvConfig.init(Environment.staging);

  // Message de démarrage
  AppLogger.debug('');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('SAHABI GUIDE - ENVIRONNEMENT: STAGING');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('API URL: ${EnvConfig.apiFullUrl}');
  AppLogger.debug('Mode: ${EnvConfig.isStaging ? "STAGING" : "PROD"}');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('');

  // Lancer l'application
  app.main();
}

