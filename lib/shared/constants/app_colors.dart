import 'package:flutter/material.dart';

/// Couleurs unifiées pour l'application Sahabi Guide
/// Optimisées pour le Hajj et les utilisateurs de 35-70 ans
class AppColors {
  // ===== COULEURS PRINCIPALES =====

  /// Vert sacré - Couleur principale inspirée de l'Islam
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  /// Doré sacré - Inspiré de la Kaaba
  static const Color secondary = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFE65100);

  /// Or (gold) utilitaire pour badges/étiquettes
  /// Note: Colors.gold n'existe pas dans Flutter; utilisez AppColors.gold
  static const Color gold = Color(0xFFFFD700);

  /// Bleu apaisant - Inspiré du ciel de La Mecque
  static const Color accent = Color(0xFF1976D2);
  static const Color accentLight = Color(0xFF42A5F5);
  static const Color accentDark = Color(0xFF0D47A1);

  // ===== COULEURS DE FOND =====

  /// Fond principal - Blanc cassé doux pour réduire la fatigue oculaire
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Fond sombre pour le mode nuit
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);

  // ===== COULEURS DE TEXTE =====

  /// Texte principal - Gris foncé pour une excellente lisibilité
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  /// Texte pour mode sombre
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextLight = Color(0xFF808080);

  // ===== COULEURS D'ÉTAT =====

  /// Succès - Vert apaisant
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  /// Erreur - Rouge doux mais visible
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  /// Attention - Orange chaleureux
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  /// Information - Bleu apaisant
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ===== COULEURS NEUTRES =====

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  /// Gris optimisés pour la lisibilité
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ===== COULEURS SPÉCIFIQUES AU HAJJ =====

  /// Couleurs pour les différents types de rituels
  static const Color prayer = primary;
  static const Color dua = secondary;
  static const Color dhikr = accent;
  static const Color reading = Color(0xFF7B1FA2); // Violet sacré
  static const Color charity = success;
  static const Color fasting = warning;
  static const Color tawaf = Color(0xFF795548); // Brun terreux

  // ===== COULEURS D'INTERFACE =====

  /// Bordures et séparateurs
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);

  /// Ombres et élévations
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);

  /// Overlays et modales
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x33000000);

  // ===== COULEURS DE BOUTONS =====

  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonAccent = accent;
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonText = white;
  static const Color buttonTextDisabled = Color(0xFF9E9E9E);

  // ===== COULEURS DE CHAMPS DE SAISIE =====

  static const Color inputBackground = white;
  static const Color inputBorder = border;
  static const Color inputFocusedBorder = primary;
  static const Color inputErrorBorder = error;
  static const Color inputHint = textLight;
  static const Color inputDisabled = grey100;

  // ===== COULEURS D'ICÔNES =====

  static const Color iconPrimary = primary;
  static const Color iconSecondary = secondary;
  static const Color iconAccent = accent;
  static const Color iconInactive = grey500;
  static const Color iconDisabled = grey400;

  // ===== COULEURS DE NAVIGATION =====

  /// Barre de navigation inférieure
  static const Color bottomNavBackground = white;
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = grey600;
  static const Color bottomNavIndicator = primary;

  /// Barre d'application
  static const Color appBarBackground = primary;
  static const Color appBarText = white;
  static const Color appBarIcon = white;

  /// Onglets
  static const Color tabBarBackground = white;
  static const Color tabBarSelected = primary;
  static const Color tabBarUnselected = grey600;
  static const Color tabBarIndicator = primary;

  // ===== DÉGRADÉS SACRÉS =====

  /// Dégradé principal (vert sacré)
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
  ];

  /// Dégradé secondaire (doré sacré)
  static const List<Color> secondaryGradient = [
    Color(0xFFF57C00),
    Color(0xFFFF9800),
  ];

  /// Dégradé accent (bleu apaisant)
  static const List<Color> accentGradient = [
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
  ];

  /// Dégradé Hajj (vert vers doré)
  static const List<Color> hajjGradient = [
    Color(0xFF2E7D32),
    Color(0xFFF57C00),
  ];

  // ===== COULEURS DE CARTES =====

  static const Color cardBackground = white;
  static const Color cardShadow = shadow;
  static const Color cardBorder = borderLight;

  // ===== COULEURS DE STATUT BAR =====

  static const Color statusBarLight = primary;
  static const Color statusBarDark = primaryDark;

  // ===== COULEURS D'ACCESSIBILITÉ =====

  /// Couleurs avec contraste élevé pour l'accessibilité
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastBackground = Color(0xFFFFFFFF);
  static const Color highContrastBorder = Color(0xFF000000);

  // ===== MÉTHODES UTILITAIRES =====

  /// Obtenir une couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
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
}
