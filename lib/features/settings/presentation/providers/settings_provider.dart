import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabi_guide/shared/constants/app_locale.dart';
import 'package:sahabi_guide/core/theme/app_color_schemes.dart';

// Enums
enum AppThemeMode { system, light, dark }

/// Langue choisie pour le copilote vocal / assistant (bot).
///
/// Couvre les langues d'interface classiques (fr/en/ar) et les langues
/// africaines servies par le microservice voix backend (ha/dje/yo/sw/wo/bm).
/// Codes canoniques alignés avec le backend : en, fr, ar, ha, dje, yo, sw, wo, bm.
enum AudioLanguage {
  french,
  english,
  arabic,
  hausa,
  zarma,
  yoruba,
  swahili,
  wolof,
  bambara;

  /// Résout une [AudioLanguage] depuis un code canonique (fr, en, ha, ...).
  static AudioLanguage fromCode(String code) {
    return AudioLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AudioLanguage.french,
    );
  }
}

extension AudioLanguageX on AudioLanguage {
  String get code {
    switch (this) {
      case AudioLanguage.french:
        return 'fr';
      case AudioLanguage.english:
        return 'en';
      case AudioLanguage.arabic:
        return 'ar';
      case AudioLanguage.hausa:
        return 'ha';
      case AudioLanguage.zarma:
        return 'dje';
      case AudioLanguage.yoruba:
        return 'yo';
      case AudioLanguage.swahili:
        return 'sw';
      case AudioLanguage.wolof:
        return 'wo';
      case AudioLanguage.bambara:
        return 'bm';
    }
  }

  String get label {
    switch (this) {
      case AudioLanguage.french:
        return 'Français';
      case AudioLanguage.english:
        return 'English';
      case AudioLanguage.arabic:
        return 'العربية';
      case AudioLanguage.hausa:
        return 'Hausa';
      case AudioLanguage.zarma:
        return 'Zarma';
      case AudioLanguage.yoruba:
        return 'Yoruba';
      case AudioLanguage.swahili:
        return 'Kiswahili';
      case AudioLanguage.wolof:
        return 'Wolof';
      case AudioLanguage.bambara:
        return 'Bambara';
    }
  }
}

// Supported locales
final List<Locale> supportedLocales =
    AppLocale.values.map((e) => e.locale).toList();

// State class
class SettingsState {
  final AppThemeMode themeMode;
  final AppColorTheme colorTheme;
  final AudioLanguage audioLanguage;
  final AppLocale locale;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.colorTheme = AppColorTheme.serenity, // Thème par défaut
    this.audioLanguage = AudioLanguage.english,
    this.locale = AppLocale.fr, // Default to French
  });

  factory SettingsState.initial() => const SettingsState();

  /// Obtenir le schéma de couleurs actuel
  AppColorScheme get currentColorScheme => colorTheme.scheme;

  SettingsState copyWith({
    AppThemeMode? themeMode,
    AppColorTheme? colorTheme,
    AudioLanguage? audioLanguage,
    AppLocale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      colorTheme: colorTheme ?? this.colorTheme,
      audioLanguage: audioLanguage ?? this.audioLanguage,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.themeMode == themeMode &&
        other.colorTheme == colorTheme &&
        other.audioLanguage == audioLanguage &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(themeMode, colorTheme, audioLanguage, locale);
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  static const _themeKey = 'theme_mode';
  static const _colorThemeKey = 'color_theme';
  static const _languageKey = 'audio_language';
  static const _localeKey = 'app_locale';

  SettingsNotifier({required this.prefs}) : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final colorThemeIndex = prefs.getInt(_colorThemeKey) ?? 0;
      final languageIndex = prefs.getInt(_languageKey) ?? 0;
      final localeCode = prefs.getString(_localeKey);

      // Default to system locale if available, otherwise French
      AppLocale defaultLocale = AppLocale.fr;
      try {
        final systemLocale = PlatformDispatcher.instance.locale;
        final detectedLocale = AppLocale.tryFromLocale(systemLocale);
        if (detectedLocale != null) {
          defaultLocale = detectedLocale;
        }
      } catch (_) {}

      state = state.copyWith(
        themeMode: themeIndex < AppThemeMode.values.length
            ? AppThemeMode.values[themeIndex]
            : AppThemeMode.system,
        colorTheme: colorThemeIndex < AppColorTheme.values.length
            ? AppColorTheme.values[colorThemeIndex]
            : AppColorTheme.serenity,
        audioLanguage: languageIndex < AudioLanguage.values.length
            ? AudioLanguage.values[languageIndex]
            : AudioLanguage.english,
        locale: localeCode != null
            ? AppLocale.values.firstWhere(
                (e) => e.locale.languageCode == localeCode,
                orElse: () => defaultLocale,
              )
            : defaultLocale,
      );
    } catch (e) {
      // Reset to default settings if loading fails
      await prefs.clear();
      state = SettingsState.initial();
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state.themeMode == mode) return; // No change needed
    await prefs.setInt(_themeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setColorTheme(AppColorTheme theme) async {
    if (state.colorTheme == theme) return; // No change needed
    await prefs.setInt(_colorThemeKey, theme.index);
    state = state.copyWith(colorTheme: theme);
  }

  Future<void> setAudioLanguage(AudioLanguage language) async {
    if (state.audioLanguage == language) return; // No change needed
    await prefs.setInt(_languageKey, language.index);
    state = state.copyWith(audioLanguage: language);
  }

  Future<void> setLocale(AppLocale locale) async {
    if (state.locale == locale) return; // No change needed
    await prefs.setString(_localeKey, locale.locale.languageCode);
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  throw UnimplementedError(
      'SettingsNotifier should be overridden in main.dart');
});

/// Provider pour obtenir le schéma de couleurs actuel
final colorSchemeProvider = Provider<AppColorScheme>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.currentColorScheme;
});
