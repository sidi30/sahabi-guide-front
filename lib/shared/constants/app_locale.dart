import 'package:flutter/material.dart';

enum AppLocale {
  en(Locale('en'), 'English'),
  fr(Locale('fr'), 'Français'),
  ar(Locale('ar'), 'العربية');

  final Locale locale;
  final String displayName;
  
  const AppLocale(this.locale, this.displayName);
  
  static AppLocale fromLocale(Locale locale) {
    return values.firstWhere(
      (e) => e.locale.languageCode == locale.languageCode,
      orElse: () => AppLocale.en, // Default to English
    );
  }
  
  static AppLocale? tryFromLocale(Locale? locale) {
    if (locale == null) return null;
    try {
      return fromLocale(locale);
    } catch (_) {
      return null;
    }
  }
}

// Extension to get the display name of the locale
extension AppLocaleExtension on AppLocale {
  String get code => locale.languageCode;
  
  String get fullLanguageCode {
    if (locale.countryCode != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}

// Extension on BuildContext to easily access the current locale
extension AppLocaleContext on BuildContext {
  AppLocale get currentAppLocale {
    final locale = Localizations.localeOf(this);
    return AppLocale.fromLocale(locale);
  }
}
