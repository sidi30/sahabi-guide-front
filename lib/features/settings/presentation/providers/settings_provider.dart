import 'dart:async';
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
/// Langues actives uniquement : Français, Anglais, Arabe, Hausa.
/// Codes canoniques alignés avec le backend : fr, en, ar, ha.
/// (Zarma, Yoruba, Swahili, Wolof, Bambara désactivés.)
enum AudioLanguage {
  french,
  english,
  arabic,
  hausa;

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
    }
  }
}

// Supported locales
final List<Locale> supportedLocales =
    AppLocale.values.map((e) => e.locale).toList();

/// Palette par défaut associée à un genre (repère visuel anti-erreur).
/// Femme → Rawdah (aubergine) ; sinon → Sérénité (émeraude).
AppColorTheme genderDefaultColorTheme(String? gender) {
  return gender == 'FEMALE' ? AppColorTheme.rawdah : AppColorTheme.serenity;
}

// State class
class SettingsState {
  final AppThemeMode themeMode;
  final AppColorTheme colorTheme;
  final AudioLanguage audioLanguage;
  final AppLocale locale;

  /// Genre du pèlerin (MALE/FEMALE/null) — pilote la palette par défaut.
  final String? gender;

  /// L'utilisateur a-t-il choisi une palette manuellement ? Si oui, on respecte
  /// son choix ; sinon on applique la palette par défaut du genre.
  final bool colorThemeExplicit;

  /// État de menstruation/lochies — DONNÉE DE SANTÉ : strictement on-device,
  /// jamais envoyée à l'API/agence. Visible uniquement pour le profil FEMALE.
  /// Adapte le guidage côté client (Tawaf/Sa'i reportés, actes alternatifs).
  final bool menses;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.colorTheme = AppColorTheme.serenity, // Thème par défaut
    this.audioLanguage = AudioLanguage.english,
    this.locale = AppLocale.fr, // Default to French
    this.gender,
    this.colorThemeExplicit = false,
    this.menses = false,
  });

  factory SettingsState.initial() => const SettingsState();

  /// Obtenir le schéma de couleurs actuel : choix manuel sinon défaut du genre.
  AppColorScheme get currentColorScheme => colorThemeExplicit
      ? colorTheme.scheme
      : genderDefaultColorTheme(gender).scheme;

  SettingsState copyWith({
    AppThemeMode? themeMode,
    AppColorTheme? colorTheme,
    AudioLanguage? audioLanguage,
    AppLocale? locale,
    String? gender,
    bool? colorThemeExplicit,
    bool? menses,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      colorTheme: colorTheme ?? this.colorTheme,
      audioLanguage: audioLanguage ?? this.audioLanguage,
      locale: locale ?? this.locale,
      gender: gender ?? this.gender,
      colorThemeExplicit: colorThemeExplicit ?? this.colorThemeExplicit,
      menses: menses ?? this.menses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.themeMode == themeMode &&
        other.colorTheme == colorTheme &&
        other.audioLanguage == audioLanguage &&
        other.locale == locale &&
        other.gender == gender &&
        other.colorThemeExplicit == colorThemeExplicit &&
        other.menses == menses;
  }

  @override
  int get hashCode => Object.hash(
      themeMode, colorTheme, audioLanguage, locale, gender, colorThemeExplicit, menses);
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  static const _themeKey = 'theme_mode';
  static const _colorThemeKey = 'color_theme';
  static const _languageKey = 'audio_language';
  static const _localeKey = 'app_locale';
  static const _genderKey = 'pilgrim_gender';
  static const _colorThemeExplicitKey = 'color_theme_explicit';
  static const _mensesKey = 'pilgrim_menses'; // on-device uniquement (donnée santé)
  static const _genderColorMigratedKey = 'gender_color_migrated_v1';

  SettingsNotifier({required this.prefs}) : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final colorThemeIndex = prefs.getInt(_colorThemeKey) ?? 0;
      final languageIndex = prefs.getInt(_languageKey) ?? 0;
      final localeCode = prefs.getString(_localeKey);
      final gender = prefs.getString(_genderKey);
      // Migration one-shot : débloque une fois pour toutes les installs où le
      // drapeau « choix manuel » est resté figé (tests), afin que la couleur suive
      // le genre. Après ça, un nouveau choix manuel persiste normalement.
      // Écriture non bloquante (ne pas retarder loadSettings).
      final migrated = prefs.getBool(_genderColorMigratedKey) ?? false;
      final colorThemeExplicit =
          migrated ? (prefs.getBool(_colorThemeExplicitKey) ?? false) : false;
      if (!migrated) {
        unawaited(prefs.setBool(_colorThemeExplicitKey, false));
        unawaited(prefs.setBool(_genderColorMigratedKey, true));
      }

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
        gender: gender,
        colorThemeExplicit: colorThemeExplicit,
        menses: prefs.getBool(_mensesKey) ?? false,
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
    // No-op si deja ce theme ET deja explicite (evite une reconstruction inutile).
    if (state.colorTheme == theme && state.colorThemeExplicit) return;
    // Choix manuel : on le memorise comme explicite (prioritaire sur le defaut genre).
    await prefs.setInt(_colorThemeKey, theme.index);
    await prefs.setBool(_colorThemeExplicitKey, true);
    state = state.copyWith(colorTheme: theme, colorThemeExplicit: true);
  }

  /// Définit le genre (MALE/FEMALE). Le genre PILOTE la palette : choisir un
  /// genre ré-applique sa palette par défaut (homme=émeraude, femme=aubergine)
  /// et réinitialise le drapeau « choix manuel », sinon une palette choisie
  /// auparavant resterait figée et la couleur ne changerait jamais avec le genre.
  Future<void> setGender(String gender) async {
    // Pas d'early-return : sélectionner un genre doit TOUJOURS ré-appliquer sa
    // palette et lever un éventuel choix manuel figé (sinon la couleur ne suit
    // jamais le genre pour qui a déjà tapé un thème).
    await prefs.setString(_genderKey, gender);
    // Sortir d'un état menses qui n'a aucun sens hors profil féminin.
    final clearMenses = gender != 'FEMALE' && state.menses;
    if (clearMenses) await prefs.setBool(_mensesKey, false);
    // Réaffirmer la palette du genre.
    await prefs.setBool(_colorThemeExplicitKey, false);
    final genderTheme = genderDefaultColorTheme(gender);
    await prefs.setInt(_colorThemeKey, genderTheme.index);
    state = state.copyWith(
      gender: gender,
      menses: clearMenses ? false : null,
      colorTheme: genderTheme,
      colorThemeExplicit: false,
    );
  }

  /// Active/désactive l'état de menstruation. DONNÉE DE SANTÉ : reste strictement
  /// sur l'appareil (SharedPreferences), jamais transmise.
  Future<void> setMenses(bool value) async {
    if (state.menses == value) return;
    await prefs.setBool(_mensesKey, value);
    state = state.copyWith(menses: value);
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
