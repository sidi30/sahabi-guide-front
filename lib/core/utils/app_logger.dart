import 'package:logger/logger.dart';

/// Logger centralisé pour l'application
/// Remplace les print() pour un logging structuré et contrôlable
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Nombre de méthodes dans la stack trace
      errorMethodCount: 8, // Nombre de méthodes pour les erreurs
      lineLength: 120, // Longueur des lignes
      colors: true, // Couleurs dans la console
      printEmojis: true, // Emojis pour les niveaux de log
      printTime: true, // Timestamp
    ),
  );

  /// Log de niveau debug (développement uniquement)
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log de niveau info (informations générales)
  static void info(String message) {
    _logger.i(message);
  }

  /// Log de niveau warning (avertissements)
  static void warning(String message, {dynamic error}) {
    _logger.w(message, error: error);
  }

  /// Log de niveau error (erreurs)
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log de niveau verbose (très détaillé)
  static void verbose(String message) {
    _logger.t(message);
  }
}

