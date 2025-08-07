import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabi_guide/shared/constants/app_locale.dart';

// Enums
enum AppThemeMode { system, light, dark }
enum AudioLanguage { hausa, zarma }

// Supported locales
final List<Locale> supportedLocales = AppLocale.values.map((e) => e.locale).toList();

// State class
class SettingsState {
  final AppThemeMode themeMode;
  final AudioLanguage audioLanguage;
  final AppLocale locale;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.audioLanguage = AudioLanguage.hausa,
    this.locale = AppLocale.en, // Default to English
  });

  factory SettingsState.initial() => const SettingsState();

  SettingsState copyWith({
    AppThemeMode? themeMode,
    AudioLanguage? audioLanguage,
    AppLocale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      audioLanguage: audioLanguage ?? this.audioLanguage,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.themeMode == themeMode &&
        other.audioLanguage == audioLanguage &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(themeMode, audioLanguage, locale);
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;
  
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'audio_language';
  static const _localeKey = 'app_locale';

  SettingsNotifier({required this.prefs}) : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final languageIndex = prefs.getInt(_languageKey) ?? 0;
      final localeCode = prefs.getString(_localeKey);
      
      // Default to system locale if available, otherwise English
      AppLocale defaultLocale = AppLocale.en;
      try {
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        defaultLocale = AppLocale.tryFromLocale(systemLocale) ?? AppLocale.en;
      } catch (_) {}

      state = state.copyWith(
        themeMode: themeIndex < AppThemeMode.values.length 
            ? AppThemeMode.values[themeIndex] 
            : AppThemeMode.system,
        audioLanguage: languageIndex < AudioLanguage.values.length 
            ? AudioLanguage.values[languageIndex] 
            : AudioLanguage.hausa,
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

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  throw UnimplementedError('SettingsNotifier should be overridden in main.dart');
});
