/// Configuration du splash screen
/// 
/// Permet de choisir entre :
/// - Splash avec vidéo (plus immersif mais peut être lent)
/// - Splash simple (rapide, stable, sans vidéo)

library;

/// Type de splash screen à utiliser
enum SplashType {
  /// Splash avec vidéo d'introduction (assets/video/mascott-anime.mp4)
  /// Recommandé pour : production si la vidéo est légère
  video,

  /// Splash simple avec logo + animation fade-in
  /// Recommandé pour : développement, tests, ou si la vidéo pose problème
  simple,
}

class SplashConfig {
  /// Type de splash actuellement configuré
  /// 
  /// Par défaut : VIDEO (comme avant)
  /// Pour désactiver la vidéo : changer en SIMPLE
  static const SplashType currentType = SplashType.video;

  /// Durée minimale d'affichage du splash simple (en millisecondes)
  static const int simpleSplashDuration = 2500;

  /// Activer le bouton "Skip" sur la vidéo
  static const bool enableSkipButton = true;

  /// Afficher des logs de debug pour le splash
  static const bool debugLogs = true;
}

