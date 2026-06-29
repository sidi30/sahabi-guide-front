// Point d'entrée pour l'environnement de PRODUCTION
//
// Utilisation :
// flutter run -t lib/main_prod.dart --release --dart-define=API_BASE_URL=https://api.sahabi.com

import 'core/config/env_config.dart';
import 'core/utils/app_logger.dart';
import 'main.dart' as app;

void main() {
  // Initialiser l'environnement de production
  EnvConfig.init(Environment.production);

  // Message de démarrage
  AppLogger.debug('');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('SAHABI GUIDE - ENVIRONNEMENT: PRODUCTION');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('API URL: ${EnvConfig.apiFullUrl}');
  AppLogger.debug('Mode: PRODUCTION');
  AppLogger.debug('═══════════════════════════════════════════════════');
  AppLogger.debug('');

  // Lancer l'application
  app.main();
}

