import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/constants/app_colors.dart';

/// Thème unifié pour l'application Sahabi Guide
/// Optimisé pour le Hajj et les utilisateurs de 35-70 ans
class AppTheme {
  // ===== CONFIGURATION DE BASE =====
  
  /// Configuration de la police optimisée pour la lisibilité
  static const String _fontFamily = 'Noto Sans';
  
  /// Tailles de police adaptées aux utilisateurs âgés
  static const double _baseFontSize = 16.0;
  static const double _largeFontSize = 18.0;
  static const double _extraLargeFontSize = 20.0;
  
  /// Espacements optimisés pour la facilité d'utilisation
  static const double _baseSpacing = 16.0;
  static const double _largeSpacing = 24.0;
  static const double _smallSpacing = 8.0;
  
  /// Rayons de bordure pour une interface douce
  static const double _baseRadius = 12.0;
  static const double _largeRadius = 16.0;
  static const double _smallRadius = 8.0;

  // ===== THÈME CLAIR =====
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Configuration de la couleur de la barre de statut
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onTertiary: AppColors.textOnAccent,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.shadow,
        scrim: AppColors.overlay,
      ),
      
      // Configuration de la typographie
      textTheme: _buildTextTheme(Brightness.light),
      
      // Configuration de la barre d'application
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textOnPrimary,
          size: 24,
        ),
      ),
      
      // Configuration des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
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
          foregroundColor: AppColors.buttonPrimary,
          side: const BorderSide(
            color: AppColors.buttonPrimary,
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
          foregroundColor: AppColors.buttonPrimary,
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
        color: AppColors.cardBackground,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        margin: const EdgeInsets.all(_smallSpacing),
      ),
      
      // Configuration des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(
            color: AppColors.inputFocusedBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(color: AppColors.inputErrorBorder),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(
            color: AppColors.inputErrorBorder,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _baseSpacing,
          vertical: _baseSpacing,
        ),
        hintStyle: GoogleFonts.notoSans(
          color: AppColors.inputHint,
          fontSize: _baseFontSize,
        ),
        labelStyle: GoogleFonts.notoSans(
          color: AppColors.textSecondary,
          fontSize: _baseFontSize,
        ),
      ),
      
      // Configuration de la barre de navigation inférieure
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomNavBackground,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Configuration des onglets
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.tabBarSelected,
        unselectedLabelColor: AppColors.tabBarUnselected,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.tabBarIndicator,
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
      iconTheme: const IconThemeData(
        color: AppColors.iconPrimary,
        size: 24,
      ),
      
      // Configuration des séparateurs
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
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
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          color: AppColors.textSecondary,
        ),
      ),
      
      // Configuration des snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: GoogleFonts.notoSans(
          color: AppColors.white,
          fontSize: _baseFontSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== THÈME SOMBRE =====
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Configuration de la couleur de la barre de statut
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        tertiary: AppColors.accentLight,
        surface: AppColors.darkSurface,
        error: AppColors.errorLight,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onTertiary: AppColors.textOnAccent,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.textOnPrimary,
        outline: AppColors.grey600,
        outlineVariant: AppColors.grey700,
        shadow: AppColors.shadowDark,
        scrim: AppColors.overlay,
      ),
      
      // Configuration de la typographie
      textTheme: _buildTextTheme(Brightness.dark),
      
      // Configuration de la barre d'application
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.darkSurface,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 24,
        ),
      ),
      
      // Configuration des cartes
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        margin: const EdgeInsets.all(_smallSpacing),
      ),
      
      // Configuration des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
          borderSide: const BorderSide(
            color: AppColors.errorLight,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _baseSpacing,
          vertical: _baseSpacing,
        ),
        hintStyle: GoogleFonts.notoSans(
          color: AppColors.darkTextLight,
          fontSize: _baseFontSize,
        ),
        labelStyle: GoogleFonts.notoSans(
          color: AppColors.darkTextSecondary,
          fontSize: _baseFontSize,
        ),
      ),
      
      // Configuration de la barre de navigation inférieure
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Configuration des icônes
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
      
      // Configuration des séparateurs
      dividerTheme: const DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
        space: 1,
      ),
      
      // Configuration des modales
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: _extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: _baseFontSize,
          color: AppColors.darkTextSecondary,
        ),
      ),
      
      // Configuration des snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey700,
        contentTextStyle: GoogleFonts.notoSans(
          color: AppColors.darkTextPrimary,
          fontSize: _baseFontSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_baseRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== CONSTRUCTION DE LA TYPOGRAPHIE =====
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textPrimary = brightness == Brightness.light
        ? AppColors.textPrimary
        : AppColors.darkTextPrimary;
    final Color textSecondary = brightness == Brightness.light
        ? AppColors.textSecondary
        : AppColors.darkTextSecondary;
    final Color textLight = brightness == Brightness.light
        ? AppColors.textLight
        : AppColors.darkTextLight;

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
  
  /// Obtenir le thème approprié selon le mode
  static ThemeData getTheme({required bool isDarkMode}) {
    return isDarkMode ? darkTheme : lightTheme;
  }
  
  /// Obtenir la couleur de texte appropriée selon le mode
  static Color getTextColor({required bool isDarkMode, required bool isPrimary}) {
    if (isDarkMode) {
      return isPrimary ? AppColors.darkTextPrimary : AppColors.darkTextSecondary;
    } else {
      return isPrimary ? AppColors.textPrimary : AppColors.textSecondary;
    }
  }
  
  /// Obtenir la couleur de fond appropriée selon le mode
  static Color getBackgroundColor({required bool isDarkMode}) {
    return isDarkMode ? AppColors.darkBackground : AppColors.background;
  }
  
  /// Obtenir la couleur de surface appropriée selon le mode
  static Color getSurfaceColor({required bool isDarkMode}) {
    return isDarkMode ? AppColors.darkSurface : AppColors.surface;
  }
}