import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_locale.dart';
import '../services/language_service.dart';

/// Provider pour le service de langue
final languageServiceProvider = Provider<LanguageService>((ref) {
  throw UnimplementedError('LanguageService should be overridden in main.dart');
});

/// Notifier pour gérer l'état de la langue.
///
/// C'est LA source de vérité unique de la langue de l'app : elle pilote à la
/// fois l'UI (`MaterialApp.locale`, RTL), la langue de réponse du bot et la
/// langue de la synthèse vocale. Le code 2 lettres (`fr|en|ar|ha`) est dérivé
/// de cette locale via [languageCodeProvider].
class LanguageNotifier extends StateNotifier<Locale> {
  final LanguageService languageService;

  LanguageNotifier(this.languageService, Locale initialLocale)
      : super(initialLocale);

  /// Change la langue de l'application (persistée dans SharedPreferences).
  Future<void> changeLanguage(AppLocale appLocale) async {
    await languageService.changeLanguage(appLocale);
    state = appLocale.locale;
  }

  /// Change la langue à partir d'un code canonique 2 lettres (`fr|en|ar|ha`).
  /// Utilisé par le sélecteur de l'AppBar du bot. Si le code n'est pas une
  /// langue d'interface connue, on n'altère pas la locale (l'app n'a pas de
  /// traduction pour, p.ex., une langue audio-only) — l'appelant gère la
  /// langue audio séparément.
  Future<void> changeLanguageByCode(String code) async {
    final matches =
        AppLocale.values.where((e) => e.locale.languageCode == code);
    if (matches.isEmpty) return;
    await changeLanguage(matches.first);
  }

  /// Récupère l'AppLocale actuel
  AppLocale get currentAppLocale {
    return AppLocale.fromLocale(state);
  }
}

/// Provider pour la gestion de la langue
final languageProvider =
    StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final languageService = ref.watch(languageServiceProvider);
  final savedLocale = languageService.getSavedAppLocale();
  return LanguageNotifier(languageService, savedLocale.locale);
});

/// Code de langue canonique 2 lettres dérivé de la source de vérité unique
/// ([languageProvider]). C'est cette valeur qui est envoyée au bot
/// (`askQuestion(language:)`) et à la voix (`voice.speak(lang:)`), garantissant
/// que l'UI, la réponse et la voix suivent le MÊME choix de langue.
final languageCodeProvider = Provider<String>((ref) {
  final locale = ref.watch(languageProvider);
  return locale.languageCode;
});
