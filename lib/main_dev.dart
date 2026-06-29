// Point d'entrée pour l'environnement de DÉVELOPPEMENT
//
// Utilisation :
// flutter run -t lib/main_dev.dart

import 'core/config/env_config.dart';
import 'core/utils/app_logger.dart';
import 'main.dart' as app;

void main() {
  // Initialiser l'environnement de développement
  EnvConfig.init(Environment.development);

  // Message de démarrage
  AppLogger.debug('');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('SAHABI GUIDE - ENVIRONNEMENT: DEVELOPPEMENT');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('API URL: ${EnvConfig.apiFullUrl}');
  AppLogger.debug('Mode: ${EnvConfig.isDevelopment ? "DEV" : "PROD"}');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('');

  // Lancer l'application
  app.main();
}

