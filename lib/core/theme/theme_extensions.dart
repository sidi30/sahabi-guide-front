import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_color_schemes.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

/// Extension sur BuildContext pour accéder facilement aux couleurs du thème
extension ThemeExtensions on BuildContext {
  /// Accès rapide au ColorScheme de Material
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Accès rapide au TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Couleur primaire du thème actuel
  Color get primaryColor => colorScheme.primary;

  /// Couleur secondaire du thème actuel
  Color get secondaryColor => colorScheme.secondary;

  /// Couleur tertiaire (accent) du thème actuel
  Color get accentColor => colorScheme.tertiary;

  /// Couleur de surface du thème actuel
  Color get surfaceColor => colorScheme.surface;

  /// Couleur d'erreur du thème actuel
  Color get errorColor => colorScheme.error;

  /// Couleur du texte sur fond primaire
  Color get onPrimaryColor => colorScheme.onPrimary;

  /// Couleur du texte sur fond de surface
  Color get onSurfaceColor => colorScheme.onSurface;

  /// Couleur de bordure/outline
  Color get outlineColor => colorScheme.outline;

  /// Vérifier si le thème actuel est sombre
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Couleur de texte primaire (adapté au mode)
  Color get textPrimaryColor => colorScheme.onSurface;

  /// Couleur de texte secondaire (adapté au mode)
  Color get textSecondaryColor =>
      colorScheme.onSurface.withValues(alpha: 0.7);

  /// Couleur de texte légère (adapté au mode)
  Color get textLightColor =>
      colorScheme.onSurface.withValues(alpha: 0.5);

  /// Couleur de fond du scaffold
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Couleur de fond des cartes
  Color get cardColor => Theme.of(this).cardColor;

  /// Couleur de divider
  Color get dividerColor => Theme.of(this).dividerColor;

  /// Couleur de succes (vert)
  Color get successColor => const Color(0xFF4CAF50);

  /// Couleur d'avertissement (orange)
  Color get warningColor => const Color(0xFFFF9800);

  /// Couleur d'information (bleu)
  Color get infoColor => const Color(0xFF2196F3);
}

/// Extension sur WidgetRef pour accéder au schéma de couleurs personnalisé
extension RefThemeExtensions on WidgetRef {
  /// Obtenir le schéma de couleurs personnalisé actuel
  AppColorScheme get colors => watch(colorSchemeProvider);

  /// Obtenir le schéma de couleurs sans écouter les changements
  AppColorScheme get colorsRead => read(colorSchemeProvider);
}

/// Classe utilitaire pour les couleurs dynamiques
/// À utiliser quand on a besoin de couleurs spécifiques au schéma personnalisé
class DynamicColors {
  final AppColorScheme scheme;
  final bool isDark;

  const DynamicColors({
    required this.scheme,
    required this.isDark,
  });

  /// Couleur primaire
  Color get primary => isDark ? scheme.primaryLight : scheme.primary;

  /// Couleur secondaire
  Color get secondary => isDark ? scheme.secondaryLight : scheme.secondary;

  /// Couleur d'accent
  Color get accent => isDark ? scheme.accentLight : scheme.accent;

  /// Couleur de fond
  Color get background =>
      isDark ? scheme.darkBackground : scheme.background;

  /// Couleur de surface
  Color get surface => isDark ? scheme.darkSurface : scheme.surface;

  /// Couleur de texte primaire
  Color get textPrimary =>
      isDark ? scheme.darkTextPrimary : scheme.textPrimary;

  /// Couleur de texte secondaire
  Color get textSecondary =>
      isDark ? scheme.darkTextSecondary : scheme.textSecondary;

  /// Couleur de texte légère
  Color get textLight => isDark ? scheme.darkTextLight : scheme.textLight;

  /// Couleur de bordure
  Color get border =>
      isDark ? scheme.darkSurfaceVariant : scheme.border;

  /// Couleur de succès
  Color get success => scheme.success;

  /// Couleur d'erreur
  Color get error => scheme.error;

  /// Couleur d'avertissement
  Color get warning => scheme.warning;

  /// Couleur d'information
  Color get info => scheme.info;

  /// Gradient primaire
  List<Color> get primaryGradient => scheme.primaryGradient;

  /// Créer depuis un WidgetRef
  factory DynamicColors.fromRef(WidgetRef ref, BuildContext context) {
    return DynamicColors(
      scheme: ref.watch(colorSchemeProvider),
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }
}
