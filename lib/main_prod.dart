// Point d'entrée pour l'environnement de PRODUCTION
//
// Utilisation :
// flutter run -t lib/main_prod.dart --release --dart-define=API_BASE_URL=https://api.sahabi.com

import 'package:flutter/material.dart';
import 'core/config/env_config.dart';
import 'main.dart' as app;

void main() {
  // Initialiser l'environnement de production
  EnvConfig.init(Environment.production);

  // Message de démarrage
  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('SAHABI GUIDE - ENVIRONNEMENT: PRODUCTION');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('API URL: ${EnvConfig.apiFullUrl}');
  debugPrint('Mode: PRODUCTION');
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('');

  // Lancer l'application
  app.main();
}

