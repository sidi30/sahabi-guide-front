import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_locale.dart';
import '../services/language_service.dart';

/// Provider pour le service de langue
final languageServiceProvider = Provider<LanguageService>((ref) {
  throw UnimplementedError('LanguageService should be overridden in main.dart');
});

/// Notifier pour gérer l'état de la langue
class LanguageNotifier extends StateNotifier<Locale> {
  final LanguageService languageService;

  LanguageNotifier(this.languageService, Locale initialLocale) : super(initialLocale);

  /// Change la langue de l'application
  Future<void> changeLanguage(AppLocale appLocale) async {
    await languageService.changeLanguage(appLocale);
    state = appLocale.locale;
  }

  /// Récupère l'AppLocale actuel
  AppLocale get currentAppLocale {
    return AppLocale.fromLocale(state);
  }
}

/// Provider pour la gestion de la langue
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final languageService = ref.watch(languageServiceProvider);
  final savedLocale = languageService.getSavedAppLocale();
  return LanguageNotifier(languageService, savedLocale.locale);
});

