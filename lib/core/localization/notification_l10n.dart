import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

/// Accès SANS BuildContext à [AppLocalizations], pour localiser les
/// notifications planifiées/en arrière-plan (construites hors d'un widget).
///
/// On lit le code de langue persisté (même clé que [LanguageService] :
/// `app_language`, source de [languageProvider]) puis on charge le bundle
/// .arb correspondant via `AppLocalizations.delegate.load(...)`. Par défaut
/// `fr`. Les langues supportées : fr, en, ar, ha.
class NotificationL10n {
  static const String _languageKey = 'app_language';
  static const List<String> _supported = ['fr', 'en', 'ar', 'ha'];

  /// Code de langue actuellement persisté (`fr|en|ar|ha`), `fr` par défaut.
  static Future<String> currentLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_languageKey);
      if (code != null && _supported.contains(code)) return code;
    } catch (_) {
      // Best-effort : retombe sur fr.
    }
    return 'fr';
  }

  /// Charge [AppLocalizations] pour la langue persistée (context-free).
  static Future<AppLocalizations> load() async {
    final code = await currentLanguageCode();
    return loadForCode(code);
  }

  /// Charge [AppLocalizations] pour un code donné (retombe sur `fr` si non
  /// supporté ou en cas d'échec).
  static Future<AppLocalizations> loadForCode(String code) async {
    final lang = _supported.contains(code) ? code : 'fr';
    try {
      return await AppLocalizations.delegate.load(Locale(lang));
    } catch (_) {
      return AppLocalizations.delegate.load(const Locale('fr'));
    }
  }
}
