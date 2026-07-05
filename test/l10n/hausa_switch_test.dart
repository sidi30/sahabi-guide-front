// Hard-evidence tests that the Hausa (ha) language switch actually renders
// Hausa strings across the app's localization stack.
//
// Three layers are proven here:
//   1. l10n correctness   -> the generated Hausa bundle returns real Hausa
//                            (distinct from French/English) for representative
//                            bot + general keys.
//   2. Widget rendering   -> flipping MaterialApp.locale from fr to ha changes
//                            the strings actually painted on screen.
//   3. Selector wiring    -> LanguageNotifier.changeLanguageByCode('ha')
//                            (the path the bot language selector calls) resolves
//                            to Locale('ha') without throwing.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sahabi_guide/l10n/app_localizations.dart';
import 'package:sahabi_guide/l10n/fallback_material_localizations.dart';
import 'package:sahabi_guide/core/services/language_service.dart';
import 'package:sahabi_guide/core/providers/language_provider.dart';

/// Representative keys covering bot + general UI, with their EXPECTED value in
/// each language taken directly from the .arb source files. Every entry is a
/// getter on AppLocalizations.
typedef Reader = String Function(AppLocalizations l);

final Map<String, Map<String, String>> expected = {
  // key label            fr                   en             ha
  'common_loading': {'fr': 'Chargement...', 'en': 'Loading...', 'ha': 'Ana lodi...'},
  'nav_health': {'fr': 'Santé', 'en': 'Health', 'ha': 'Lafiya'},
  'home_greeting_morning': {'fr': 'Bonjour', 'en': 'Good morning', 'ha': 'Barka da safiya'},
  'bot_listen': {'fr': 'Écouter', 'en': 'Listen', 'ha': 'Saurara'},
  'bot_source': {'fr': 'Source', 'en': 'Source', 'ha': 'Tushe'},
  'notifications_title': {'fr': 'Notifications', 'en': 'Notifications', 'ha': 'Sanarwa'},
  'common_cancel': {'fr': 'Annuler', 'en': 'Cancel', 'ha': 'Soke'},
};

final Map<String, Reader> readers = {
  'common_loading': (l) => l.common_loading,
  'nav_health': (l) => l.nav_health,
  'home_greeting_morning': (l) => l.home_greeting_morning,
  'bot_listen': (l) => l.bot_listen,
  'bot_source': (l) => l.bot_source,
  'notifications_title': (l) => l.notifications_title,
  'common_cancel': (l) => l.common_cancel,
};

void main() {
  // ---------------------------------------------------------------------------
  // 1. l10n correctness: the Hausa bundle is complete and distinct.
  // ---------------------------------------------------------------------------
  group('l10n bundle correctness', () {
    test('ha is registered as a supported locale', () {
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode),
        contains('ha'),
      );
    });

    for (final code in ['fr', 'en', 'ha']) {
      test('$code bundle returns the expected string for every representative key', () {
        final l = lookupAppLocalizations(Locale(code));
        expected.forEach((key, byLang) {
          final actual = readers[key]!(l);
          expect(
            actual,
            byLang[code],
            reason: '[$code] $key expected "${byLang[code]}" but got "$actual"',
          );
        });
      });
    }

    test('Hausa values are real Hausa, not English fallbacks', () {
      final ha = lookupAppLocalizations(const Locale('ha'));
      final en = lookupAppLocalizations(const Locale('en'));
      // Keys that genuinely differ between English and Hausa (excludes proper
      // nouns like "Notifications"/"Source" which are shared).
      for (final key in ['common_loading', 'nav_health', 'home_greeting_morning', 'bot_listen', 'common_cancel']) {
        expect(
          readers[key]!(ha),
          isNot(equals(readers[key]!(en))),
          reason: 'Hausa "$key" must not equal the English value (would mean missing translation)',
        );
      }
    });

    test('Hausa and French are distinct languages', () {
      final ha = lookupAppLocalizations(const Locale('ha'));
      final fr = lookupAppLocalizations(const Locale('fr'));
      for (final key in ['common_loading', 'nav_health', 'home_greeting_morning', 'bot_listen', 'common_cancel']) {
        expect(readers[key]!(ha), isNot(equals(readers[key]!(fr))));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Widget rendering: flipping MaterialApp.locale actually repaints in Hausa.
  // ---------------------------------------------------------------------------
  testWidgets('changing MaterialApp locale fr -> ha flips the rendered UI to Hausa',
      (tester) async {
    Widget app(Locale locale) => MaterialApp(
          locale: locale,
          // Mirror the EXACT delegate list from main.dart, incl. the Hausa
          // Material/Cupertino fallback (flutter_localizations has no `ha`).
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...haFallbackLocalizationsDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l = AppLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    Text(l.nav_health),
                    Text(l.common_loading),
                    Text(l.bot_listen),
                  ],
                ),
              );
            },
          ),
        );

    // First render in French.
    await tester.pumpWidget(app(const Locale('fr')));
    await tester.pumpAndSettle();
    expect(find.text('Santé'), findsOneWidget);
    expect(find.text('Chargement...'), findsOneWidget);
    expect(find.text('Écouter'), findsOneWidget);
    // Hausa must NOT be on screen yet.
    expect(find.text('Lafiya'), findsNothing);

    // Switch the whole app to Hausa.
    await tester.pumpWidget(app(const Locale('ha')));
    await tester.pumpAndSettle();

    // Hausa strings are now painted...
    expect(find.text('Lafiya'), findsOneWidget);
    expect(find.text('Ana lodi...'), findsOneWidget);
    expect(find.text('Saurara'), findsOneWidget);
    // ...and the French strings are gone.
    expect(find.text('Santé'), findsNothing);
    expect(find.text('Chargement...'), findsNothing);
    expect(find.text('Écouter'), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // 3. Selector wiring: the exact path the bot language button invokes.
  //    bot_chat_page.dart calls languageProvider.notifier.changeLanguageByCode(code).
  // ---------------------------------------------------------------------------
  group('LanguageNotifier.changeLanguageByCode', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test("changeLanguageByCode('ha') sets state to Locale('ha') and persists it",
        () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      final notifier = LanguageNotifier(service, const Locale('fr'));

      expect(notifier.state.languageCode, 'fr');

      await notifier.changeLanguageByCode('ha');

      // In-memory state flipped to Hausa.
      expect(notifier.state.languageCode, 'ha');
      expect(notifier.currentAppLocale.locale.languageCode, 'ha');
      // Persisted so the app reopens in Hausa.
      expect(prefs.getString('app_language'), 'ha');
    });

    test("unknown code leaves the locale unchanged (no throw)", () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = LanguageNotifier(LanguageService(prefs), const Locale('fr'));
      await notifier.changeLanguageByCode('zz');
      expect(notifier.state.languageCode, 'fr');
    });
  });
}
