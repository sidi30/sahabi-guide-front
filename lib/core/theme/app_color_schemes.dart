import 'package:flutter/material.dart';

/// Enum des thèmes de couleurs disponibles
enum AppColorTheme {
  /// Thème par défaut - Sérénité Sacrée
  /// Vert émeraude profond + Or doux + Bleu-gris apaisant
  serenity,

  /// Thème Classique Vert - Vert islamique traditionnel
  classicGreen,

  /// Thème Désert Doré - Tons sable et or du désert
  desertGold,

  /// Thème Nuit Étoilée - Bleu nuit profond
  starryNight,

  /// Thème Minéral - Tons neutres et élégants
  mineral,
}

/// Extension pour obtenir les informations sur chaque thème
extension AppColorThemeExtension on AppColorTheme {
  /// Nom d'affichage du thème
  String get displayName {
    switch (this) {
      case AppColorTheme.serenity:
        return 'Sérénité Sacrée';
      case AppColorTheme.classicGreen:
        return 'Classique Vert';
      case AppColorTheme.desertGold:
        return 'Désert Doré';
      case AppColorTheme.starryNight:
        return 'Nuit Étoilée';
      case AppColorTheme.mineral:
        return 'Minéral';
    }
  }

  /// Description du thème
  String get description {
    switch (this) {
      case AppColorTheme.serenity:
        return 'Vert émeraude apaisant, idéal pour la méditation';
      case AppColorTheme.classicGreen:
        return 'Vert islamique traditionnel et chaleureux';
      case AppColorTheme.desertGold:
        return 'Tons dorés inspirés du désert sacré';
      case AppColorTheme.starryNight:
        return 'Bleu nuit profond et mystique';
      case AppColorTheme.mineral:
        return 'Tons neutres élégants et modernes';
    }
  }

  /// Couleur preview pour l'affichage dans les settings
  Color get previewColor {
    switch (this) {
      case AppColorTheme.serenity:
        return const Color(0xFF1D5D4E);
      case AppColorTheme.classicGreen:
        return const Color(0xFF2E7D32);
      case AppColorTheme.desertGold:
        return const Color(0xFFC9A227);
      case AppColorTheme.starryNight:
        return const Color(0xFF1D3557);
      case AppColorTheme.mineral:
        return const Color(0xFF5D6D7E);
    }
  }

  /// Obtenir le schéma de couleurs pour ce thème
  AppColorScheme get scheme {
    switch (this) {
      case AppColorTheme.serenity:
        return AppColorScheme.serenity();
      case AppColorTheme.classicGreen:
        return AppColorScheme.classicGreen();
      case AppColorTheme.desertGold:
        return AppColorScheme.desertGold();
      case AppColorTheme.starryNight:
        return AppColorScheme.starryNight();
      case AppColorTheme.mineral:
        return AppColorScheme.mineral();
    }
  }
}

/// Schéma de couleurs complet pour l'application
class AppColorScheme {
  // Couleurs principales
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  // Couleurs secondaires
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;

  // Couleurs d'accent
  final Color accent;
  final Color accentLight;
  final Color accentDark;

  // Couleurs de fond (mode clair)
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Couleurs de fond (mode sombre)
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceVariant;

  // Couleurs de texte (mode clair)
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;
  final Color textOnPrimary;
  final Color textOnSecondary;

  // Couleurs de texte (mode sombre)
  final Color darkTextPrimary;
  final Color darkTextSecondary;
  final Color darkTextLight;

  // Couleurs d'état
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  // Couleurs utilitaires
  final Color border;
  final Color divider;
  final Color shadow;

  // Dégradé principal
  final List<Color> primaryGradient;

  const AppColorScheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.textOnPrimary,
    required this.textOnSecondary,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
    required this.darkTextLight,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.primaryGradient,
  });

  // ===== THÈME SÉRÉNITÉ SACRÉE (DÉFAUT) =====
  /// Vert émeraude profond + Or doux + Bleu-gris apaisant
  /// Inspiré par la tranquillité et la spiritualité
  factory AppColorScheme.serenity() {
    return const AppColorScheme(
      // Couleurs principales - Vert émeraude profond
      primary: Color(0xFF1D5D4E),
      primaryLight: Color(0xFF2D7D6E),
      primaryDark: Color(0xFF0D3D2E),

      // Couleurs secondaires - Or doux
      secondary: Color(0xFFC9A227),
      secondaryLight: Color(0xFFDDB84A),
      secondaryDark: Color(0xFFA68B1F),

      // Couleurs d'accent - Bleu-gris apaisant
      accent: Color(0xFF457B9D),
      accentLight: Color(0xFF6B9BBD),
      accentDark: Color(0xFF1D3557),

      // Couleurs de fond (mode clair)
      background: Color(0xFFF8F9FA),
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFF1F3F4),

      // Couleurs de fond (mode sombre)
      darkBackground: Color(0xFF0D1B2A),
      darkSurface: Color(0xFF1B2838),
      darkSurfaceVariant: Color(0xFF243447),

      // Couleurs de texte (mode clair)
      textPrimary: Color(0xFF1D3557),
      textSecondary: Color(0xFF6C757D),
      textLight: Color(0xFF9CA3AF),
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSecondary: Color(0xFF1D3557),

      // Couleurs de texte (mode sombre)
      darkTextPrimary: Color(0xFFE8EAED),
      darkTextSecondary: Color(0xFFB0B8C1),
      darkTextLight: Color(0xFF7A8490),

      // Couleurs d'état
      success: Color(0xFF2E7D32),
      error: Color(0xFFD32F2F),
      warning: Color(0xFFF9A825),
      info: Color(0xFF1976D2),

      // Couleurs utilitaires
      border: Color(0xFFDEE2E6),
      divider: Color(0xFFE9ECEF),
      shadow: Color(0x1A000000),

      // Dégradé principal
      primaryGradient: [Color(0xFF1D5D4E), Color(0xFF2D7D6E)],
    );
  }

  // ===== THÈME CLASSIQUE VERT =====
  /// Vert islamique traditionnel - chaleureux et familier
  factory AppColorScheme.classicGreen() {
    return const AppColorScheme(
      // Couleurs principales - Vert islamique
      primary: Color(0xFF2E7D32),
      primaryLight: Color(0xFF4CAF50),
      primaryDark: Color(0xFF1B5E20),

      // Couleurs secondaires - Doré Kaaba
      secondary: Color(0xFFF57C00),
      secondaryLight: Color(0xFFFF9800),
      secondaryDark: Color(0xFFE65100),

      // Couleurs d'accent - Bleu ciel
      accent: Color(0xFF1976D2),
      accentLight: Color(0xFF42A5F5),
      accentDark: Color(0xFF0D47A1),

      // Couleurs de fond (mode clair)
      background: Color(0xFFFAFAFA),
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFF5F5F5),

      // Couleurs de fond (mode sombre)
      darkBackground: Color(0xFF121212),
      darkSurface: Color(0xFF1E1E1E),
      darkSurfaceVariant: Color(0xFF2D2D2D),

      // Couleurs de texte (mode clair)
      textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF757575),
      textLight: Color(0xFF9E9E9E),
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSecondary: Color(0xFFFFFFFF),

      // Couleurs de texte (mode sombre)
      darkTextPrimary: Color(0xFFE0E0E0),
      darkTextSecondary: Color(0xFFB0B0B0),
      darkTextLight: Color(0xFF808080),

      // Couleurs d'état
      success: Color(0xFF4CAF50),
      error: Color(0xFFD32F2F),
      warning: Color(0xFFFF9800),
      info: Color(0xFF2196F3),

      // Couleurs utilitaires
      border: Color(0xFFE0E0E0),
      divider: Color(0xFFE0E0E0),
      shadow: Color(0x1A000000),

      // Dégradé principal
      primaryGradient: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    );
  }

  // ===== THÈME DÉSERT DORÉ =====
  /// Tons sable et or inspirés du désert sacré
  factory AppColorScheme.desertGold() {
    return const AppColorScheme(
      // Couleurs principales - Or désert
      primary: Color(0xFFB8860B),
      primaryLight: Color(0xFFDAA520),
      primaryDark: Color(0xFF8B6914),

      // Couleurs secondaires - Terre cuite
      secondary: Color(0xFFCD853F),
      secondaryLight: Color(0xFFDEB887),
      secondaryDark: Color(0xFFA0522D),

      // Couleurs d'accent - Vert oasis
      accent: Color(0xFF6B8E23),
      accentLight: Color(0xFF9ACD32),
      accentDark: Color(0xFF556B2F),

      // Couleurs de fond (mode clair)
      background: Color(0xFFFFFBF5),
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFFAF5EB),

      // Couleurs de fond (mode sombre)
      darkBackground: Color(0xFF1A1512),
      darkSurface: Color(0xFF2A231D),
      darkSurfaceVariant: Color(0xFF3A3028),

      // Couleurs de texte (mode clair)
      textPrimary: Color(0xFF3E2723),
      textSecondary: Color(0xFF6D4C41),
      textLight: Color(0xFF8D6E63),
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSecondary: Color(0xFF3E2723),

      // Couleurs de texte (mode sombre)
      darkTextPrimary: Color(0xFFEFE6DD),
      darkTextSecondary: Color(0xFFBCAA99),
      darkTextLight: Color(0xFF8A7968),

      // Couleurs d'état
      success: Color(0xFF6B8E23),
      error: Color(0xFFCD5C5C),
      warning: Color(0xFFDAA520),
      info: Color(0xFF4682B4),

      // Couleurs utilitaires
      border: Color(0xFFE8DDD0),
      divider: Color(0xFFF0E6D9),
      shadow: Color(0x1A3E2723),

      // Dégradé principal
      primaryGradient: [Color(0xFFB8860B), Color(0xFFDAA520)],
    );
  }

  // ===== THÈME NUIT ÉTOILÉE =====
  /// Bleu nuit profond et mystique
  factory AppColorScheme.starryNight() {
    return const AppColorScheme(
      // Couleurs principales - Bleu nuit
      primary: Color(0xFF1D3557),
      primaryLight: Color(0xFF457B9D),
      primaryDark: Color(0xFF0D1B2A),

      // Couleurs secondaires - Argent lunaire
      secondary: Color(0xFF8DAAB9),
      secondaryLight: Color(0xFFA8DADC),
      secondaryDark: Color(0xFF5C7D8A),

      // Couleurs d'accent - Or étoile
      accent: Color(0xFFD4AF37),
      accentLight: Color(0xFFE6C65C),
      accentDark: Color(0xFFB8960F),

      // Couleurs de fond (mode clair)
      background: Color(0xFFF5F7FA),
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFEDF1F5),

      // Couleurs de fond (mode sombre)
      darkBackground: Color(0xFF0D1117),
      darkSurface: Color(0xFF161B22),
      darkSurfaceVariant: Color(0xFF21262D),

      // Couleurs de texte (mode clair)
      textPrimary: Color(0xFF1D3557),
      textSecondary: Color(0xFF5A7184),
      textLight: Color(0xFF8B99A8),
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSecondary: Color(0xFF1D3557),

      // Couleurs de texte (mode sombre)
      darkTextPrimary: Color(0xFFE6EDF3),
      darkTextSecondary: Color(0xFF8B949E),
      darkTextLight: Color(0xFF6E7681),

      // Couleurs d'état
      success: Color(0xFF238636),
      error: Color(0xFFDA3633),
      warning: Color(0xFFD29922),
      info: Color(0xFF58A6FF),

      // Couleurs utilitaires
      border: Color(0xFFD0D7DE),
      divider: Color(0xFFD8DEE4),
      shadow: Color(0x1A1D3557),

      // Dégradé principal
      primaryGradient: [Color(0xFF1D3557), Color(0xFF457B9D)],
    );
  }

  // ===== THÈME MINÉRAL =====
  /// Tons neutres élégants et modernes
  factory AppColorScheme.mineral() {
    return const AppColorScheme(
      // Couleurs principales - Gris ardoise
      primary: Color(0xFF5D6D7E),
      primaryLight: Color(0xFF85929E),
      primaryDark: Color(0xFF34495E),

      // Couleurs secondaires - Cuivre
      secondary: Color(0xFFB87333),
      secondaryLight: Color(0xFFCD8C52),
      secondaryDark: Color(0xFF8B5A2B),

      // Couleurs d'accent - Turquoise minéral
      accent: Color(0xFF17A589),
      accentLight: Color(0xFF48C9B0),
      accentDark: Color(0xFF117864),

      // Couleurs de fond (mode clair)
      background: Color(0xFFF7F9F9),
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFECF0F1),

      // Couleurs de fond (mode sombre)
      darkBackground: Color(0xFF17202A),
      darkSurface: Color(0xFF1C2833),
      darkSurfaceVariant: Color(0xFF273746),

      // Couleurs de texte (mode clair)
      textPrimary: Color(0xFF2C3E50),
      textSecondary: Color(0xFF5D6D7E),
      textLight: Color(0xFF95A5A6),
      textOnPrimary: Color(0xFFFFFFFF),
      textOnSecondary: Color(0xFFFFFFFF),

      // Couleurs de texte (mode sombre)
      darkTextPrimary: Color(0xFFECF0F1),
      darkTextSecondary: Color(0xFFBDC3C7),
      darkTextLight: Color(0xFF7F8C8D),

      // Couleurs d'état
      success: Color(0xFF27AE60),
      error: Color(0xFFE74C3C),
      warning: Color(0xFFF39C12),
      info: Color(0xFF3498DB),

      // Couleurs utilitaires
      border: Color(0xFFD5DBDB),
      divider: Color(0xFFE5E8E8),
      shadow: Color(0x1A2C3E50),

      // Dégradé principal
      primaryGradient: [Color(0xFF5D6D7E), Color(0xFF85929E)],
    );
  }

  // ===== MÉTHODES UTILITAIRES =====

  /// Obtenir une couleur avec opacité
  Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Obtenir une couleur plus claire
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Obtenir une couleur plus foncée
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // ===== COULEURS DÉRIVÉES =====

  /// Couleurs de navigation
  Color get bottomNavBackground => surface;
  Color get bottomNavSelected => primary;
  Color get bottomNavUnselected => textSecondary;

  /// Couleurs des boutons
  Color get buttonPrimary => primary;
  Color get buttonSecondary => secondary;
  Color get buttonDisabled => border;
  Color get buttonText => textOnPrimary;

  /// Couleurs des champs de saisie
  Color get inputBackground => surface;
  Color get inputBorder => border;
  Color get inputFocusedBorder => primary;
  Color get inputErrorBorder => error;
  Color get inputHint => textLight;

  /// Couleurs des icônes
  Color get iconPrimary => primary;
  Color get iconSecondary => secondary;
  Color get iconInactive => textLight;

  /// Couleurs des cartes
  Color get cardBackground => surface;
  Color get cardShadow => shadow;
}
