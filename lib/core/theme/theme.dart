import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_schemes.dart';

/// Thème unifié pour l'application Sahabi Guide
/// Optimisé pour le Hajj et les utilisateurs de 35-70 ans
/// Supporte les thèmes de couleurs personnalisables
class AppTheme {
  // ===== CONFIGURATION DE BASE =====

  /// Tailles de police adaptées aux utilisateurs âgés
  static const double _baseFontSize = 16.0;
  static const double _extraLargeFontSize = 20.0;

  /// Espacements optimisés pour la facilité d'utilisation
  static const double _baseSpacing = 16.0;
  static const double _largeSpacing = 24.0;
  static const double _smallSpacing = 8.0;

  /// Rayons de bordure pour une interface douce
  static const double _baseRadius = 12.0;
  static const double _largeRadius = 16.0;
  static const double _smallRadius = 8.0;

  // ===== THÈME CLAIR DYNAMIQUE =====

  static ThemeData lightTheme(AppColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Configuration de la couleur de la barre de statut
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.accent,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSecondary: colors.textOnSecondary,
        onTertiary: colors.textOnPrimary,
        onSurface: colors.textPrimary,
        onError: colors.textOnPrimary,
        outline: colors.border,
        outlineVariant: colors.divider,
        shadow: colors.shadow,
        scrim: colors.shadow,
      ),

      // Couleur de fond
      scaffoldBackgroundColor: colors.background,

      // Configuration de la typographie
      textTheme: _buildTextTheme(Brightness.light, colors),

      // Configuration de la barre d'application
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: colors.textOnPrimary,
        ),
        iconTheme: IconThemeData(
          color: colors.textOnPrimary,
          size: 24,
        ),
      ),

      // Configuration des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.buttonPrimary,
          foregroundColor: colors.buttonText,
          padding: const EdgeInsets.symmetric(
            horizontal: _largeSpacing,
            vertical: _baseSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_baseRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(120, 48),
          elevation: 2,
        ),
      ),

      // Configuration des boutons avec contour
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.buttonPrimary,
          side: BorderSide(
            color: colors.buttonPrimary,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _largeSpacing,
            vertical: _baseSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_baseRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(120, 48),
        ),
      ),

      // Configuration des boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.buttonPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: _baseSpacing,
            vertical: _smallSpacing,
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Configuration des cartes
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 2,
        shadowColor: colors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        margin: const EdgeInsets.all(_smallSpacing),
      ),

      // Configuration des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(
            color: colors.inputFocusedBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(color: colors.inputErrorBorder),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(
            color: colors.inputErrorBorder,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _baseSpacing,
          vertical: _baseSpacing,
        ),
        hintStyle: GoogleFonts.notoSans(
          color: colors.inputHint,
          fontSize: _baseFontSize,
        ),
        labelStyle: GoogleFonts.notoSans(
          color: colors.textSecondary,
          fontSize: _baseFontSize,
        ),
      ),

      // Configuration de la barre de navigation inférieure
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bottomNavBackground,
        selectedItemColor: colors.bottomNavSelected,
        unselectedItemColor: colors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Configuration des onglets
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.primary,
            width: 3,
          ),
        ),
        labelStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Configuration des icônes
      iconTheme: IconThemeData(
        color: colors.iconPrimary,
        size: 24,
      ),

      // Configuration des séparateurs
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      // Configuration des listes
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _baseSpacing,
          vertical: _smallSpacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_smallRadius)),
        ),
      ),

      // Configuration des modales
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          color: colors.textSecondary,
        ),
      ),

      // Configuration des snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: GoogleFonts.notoSans(
          color: colors.surface,
          fontSize: _baseFontSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Configuration des chips
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primary,
        labelStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),

      // Configuration du floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
      ),

      // Configuration du switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.textLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryLight;
          }
          return colors.border;
        }),
      ),

      // Configuration du checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.surface;
        }),
        checkColor: WidgetStateProperty.all(colors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Configuration du radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.textSecondary;
        }),
      ),

      // Configuration du slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.border,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.2),
      ),

      // Configuration du progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.border,
        circularTrackColor: colors.border,
      ),
    );
  }

  // ===== THÈME SOMBRE DYNAMIQUE =====

  static ThemeData darkTheme(AppColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Configuration de la couleur de la barre de statut
      colorScheme: ColorScheme.dark(
        primary: colors.primaryLight,
        secondary: colors.secondaryLight,
        tertiary: colors.accentLight,
        surface: colors.darkSurface,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSecondary: colors.textOnSecondary,
        onTertiary: colors.textOnPrimary,
        onSurface: colors.darkTextPrimary,
        onError: colors.textOnPrimary,
        outline: colors.darkTextLight,
        outlineVariant: colors.darkSurfaceVariant,
        shadow: colors.shadow,
        scrim: colors.shadow,
      ),

      // Couleur de fond
      scaffoldBackgroundColor: colors.darkBackground,

      // Configuration de la typographie
      textTheme: _buildTextTheme(Brightness.dark, colors),

      // Configuration de la barre d'application
      appBarTheme: AppBarTheme(
        backgroundColor: colors.darkSurface,
        foregroundColor: colors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colors.darkSurface,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: colors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(
          color: colors.darkTextPrimary,
          size: 24,
        ),
      ),

      // Configuration des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryLight,
          foregroundColor: colors.textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: _largeSpacing,
            vertical: _baseSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_baseRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(120, 48),
          elevation: 4,
        ),
      ),

      // Configuration des boutons avec contour
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryLight,
          side: BorderSide(
            color: colors.primaryLight,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _largeSpacing,
            vertical: _baseSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_baseRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(120, 48),
        ),
      ),

      // Configuration des boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: _baseSpacing,
            vertical: _smallSpacing,
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Configuration des cartes
      cardTheme: CardThemeData(
        color: colors.darkSurface,
        elevation: 4,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        margin: const EdgeInsets.all(_smallSpacing),
      ),

      // Configuration des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(color: colors.darkTextLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(color: colors.darkTextLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(
            color: colors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _baseSpacing,
          vertical: _baseSpacing,
        ),
        hintStyle: GoogleFonts.notoSans(
          color: colors.darkTextLight,
          fontSize: _baseFontSize,
        ),
        labelStyle: GoogleFonts.notoSans(
          color: colors.darkTextSecondary,
          fontSize: _baseFontSize,
        ),
      ),

      // Configuration de la barre de navigation inférieure
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.darkSurface,
        selectedItemColor: colors.primaryLight,
        unselectedItemColor: colors.darkTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Configuration des onglets
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primaryLight,
        unselectedLabelColor: colors.darkTextSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.primaryLight,
            width: 3,
          ),
        ),
        labelStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Configuration des icônes
      iconTheme: IconThemeData(
        color: colors.darkTextPrimary,
        size: 24,
      ),

      // Configuration des séparateurs
      dividerTheme: DividerThemeData(
        color: colors.darkSurfaceVariant,
        thickness: 1,
        space: 1,
      ),

      // Configuration des listes
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _baseSpacing,
          vertical: _smallSpacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_smallRadius)),
        ),
      ),

      // Configuration des modales
      dialogTheme: DialogThemeData(
        backgroundColor: colors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: colors.darkTextPrimary,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          color: colors.darkTextSecondary,
        ),
      ),

      // Configuration des snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.darkSurfaceVariant,
        contentTextStyle: GoogleFonts.notoSans(
          color: colors.darkTextPrimary,
          fontSize: _baseFontSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Configuration des chips
      chipTheme: ChipThemeData(
        backgroundColor: colors.darkSurfaceVariant,
        selectedColor: colors.primaryLight,
        labelStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: colors.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),

      // Configuration du floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primaryLight,
        foregroundColor: colors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
      ),

      // Configuration du switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryLight;
          }
          return colors.darkTextLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.darkSurfaceVariant;
        }),
      ),

      // Configuration du checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryLight;
          }
          return colors.darkSurface;
        }),
        checkColor: WidgetStateProperty.all(colors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Configuration du radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryLight;
          }
          return colors.darkTextSecondary;
        }),
      ),

      // Configuration du slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primaryLight,
        inactiveTrackColor: colors.darkSurfaceVariant,
        thumbColor: colors.primaryLight,
        overlayColor: colors.primaryLight.withValues(alpha: 0.2),
      ),

      // Configuration du progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primaryLight,
        linearTrackColor: colors.darkSurfaceVariant,
        circularTrackColor: colors.darkSurfaceVariant,
      ),
    );
  }

  // ===== CONSTRUCTION DE LA TYPOGRAPHIE =====

  static TextTheme _buildTextTheme(Brightness brightness, AppColorScheme colors) {
    final Color textPrimary = brightness == Brightness.light
        ? colors.textPrimary
        : colors.darkTextPrimary;
    final Color textSecondary = brightness == Brightness.light
        ? colors.textSecondary
        : colors.darkTextSecondary;
    final Color textLight = brightness == Brightness.light
        ? colors.textLight
        : colors.darkTextLight;

    return GoogleFonts.notoSansTextTheme().copyWith(
      // Titres principaux
      displayLarge: GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),

      // En-têtes
      headlineLarge: GoogleFonts.notoSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),

      // Titres
      titleLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      ),

      // Corps de texte
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textLight,
        height: 1.5,
      ),

      // Labels
      labelLarge: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.notoSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textLight,
        height: 1.4,
      ),
    );
  }

  // ===== MÉTHODES UTILITAIRES =====

  /// Obtenir le thème approprié selon le mode et le schéma de couleurs
  static ThemeData getTheme({
    required bool isDarkMode,
    required AppColorScheme colors,
  }) {
    return isDarkMode ? darkTheme(colors) : lightTheme(colors);
  }

  /// Obtenir la couleur de texte appropriée selon le mode
  static Color getTextColor({
    required bool isDarkMode,
    required bool isPrimary,
    required AppColorScheme colors,
  }) {
    if (isDarkMode) {
      return isPrimary ? colors.darkTextPrimary : colors.darkTextSecondary;
    } else {
      return isPrimary ? colors.textPrimary : colors.textSecondary;
    }
  }

  /// Obtenir la couleur de fond appropriée selon le mode
  static Color getBackgroundColor({
    required bool isDarkMode,
    required AppColorScheme colors,
  }) {
    return isDarkMode ? colors.darkBackground : colors.background;
  }

  /// Obtenir la couleur de surface appropriée selon le mode
  static Color getSurfaceColor({
    required bool isDarkMode,
    required AppColorScheme colors,
  }) {
    return isDarkMode ? colors.darkSurface : colors.surface;
  }
}
