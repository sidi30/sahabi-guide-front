import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/app_locale.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  final SharedPreferences prefs;

  LanguageService(this.prefs);

  /// Récupère la langue sauvegardée ou la langue système par défaut
  Future<Locale> getSavedLocale() async {
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    // Retourner français par défaut
    return const Locale('fr');
  }

  /// Sauvegarde la langue choisie
  Future<void> saveLocale(Locale locale) async {
    await prefs.setString(_languageKey, locale.languageCode);
  }

  /// Récupère l'AppLocale sauvegardé
  AppLocale getSavedAppLocale() {
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      try {
        return AppLocale.values.firstWhere(
          (e) => e.locale.languageCode == languageCode,
        );
      } catch (e) {
        return AppLocale.fr;
      }
    }
    
    return AppLocale.fr;
  }

  /// Sauvegarde l'AppLocale choisi
  Future<void> saveAppLocale(AppLocale appLocale) async {
    await prefs.setString(_languageKey, appLocale.locale.languageCode);
  }

  /// Change la langue de l'application
  Future<void> changeLanguage(AppLocale appLocale) async {
    await saveAppLocale(appLocale);
  }

  /// Vérifie si une langue est RTL (Right-to-Left)
  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar' || locale.languageCode == 'he';
  }

  /// Récupère la direction du texte pour une locale
  static TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }
}


