import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enums
enum AppThemeMode { system, light, dark }
enum AudioLanguage { hausa, zarma }

// Supported locales
const List<Locale> supportedLocales = [
  Locale('en'), // English
  Locale('fr'), // French
  Locale('ar'), // Arabic
];

// State class
class SettingsState {
  final AppThemeMode themeMode;
  final AudioLanguage audioLanguage;
  final Locale? locale;

  const SettingsState({
    required this.themeMode,
    required this.audioLanguage,
    this.locale,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: AppThemeMode.system,
      audioLanguage: AudioLanguage.hausa,
      locale: null,
    );
  }

  SettingsState copyWith({
    AppThemeMode? themeMode,
    AudioLanguage? audioLanguage,
    Locale? locale,
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
        other.locale?.languageCode == locale?.languageCode;
  }

  @override
  int get hashCode => Object.hash(themeMode, audioLanguage, locale?.languageCode);
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

      state = state.copyWith(
        themeMode: AppThemeMode.values[themeIndex],
        audioLanguage: AudioLanguage.values[languageIndex],
        locale: localeCode != null ? Locale(localeCode) : null,
      );
    } catch (e) {
      // Reset to default settings if loading fails
      await prefs.clear();
      state = SettingsState.initial();
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await prefs.setInt(_themeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setAudioLanguage(AudioLanguage language) async {
    await prefs.setInt(_languageKey, language.index);
    state = state.copyWith(audioLanguage: language);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale != null) {
      await prefs.setString(_localeKey, locale.languageCode);
    } else {
      await prefs.remove(_localeKey);
    }
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  throw UnimplementedError('SettingsNotifier should be overridden in main.dart');
});
