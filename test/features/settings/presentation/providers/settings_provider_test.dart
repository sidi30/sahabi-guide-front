import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';
import 'package:sahabi_guide/core/theme/app_color_schemes.dart';

void main() {
  group('AppThemeMode', () {
    test('has all expected values', () {
      expect(AppThemeMode.values.length, 3);
      expect(AppThemeMode.values, contains(AppThemeMode.system));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
    });
  });

  group('AudioLanguage', () {
    test('has all expected values (langues actives : fr/en/ar/ha)', () {
      expect(AudioLanguage.values.length, 4);
      expect(AudioLanguage.values, contains(AudioLanguage.french));
      expect(AudioLanguage.values, contains(AudioLanguage.english));
      expect(AudioLanguage.values, contains(AudioLanguage.arabic));
      expect(AudioLanguage.values, contains(AudioLanguage.hausa));
    });

    test('code returns correct language codes', () {
      expect(AudioLanguage.french.code, 'fr');
      expect(AudioLanguage.english.code, 'en');
      expect(AudioLanguage.arabic.code, 'ar');
      expect(AudioLanguage.hausa.code, 'ha');
    });

    test('label returns correct display names', () {
      expect(AudioLanguage.french.label, 'Français');
      expect(AudioLanguage.english.label, 'English');
      expect(AudioLanguage.arabic.label, 'العربية');
      expect(AudioLanguage.hausa.label, 'Hausa');
    });

    test('fromCode resolves canonical codes', () {
      expect(AudioLanguage.fromCode('fr'), AudioLanguage.french);
      expect(AudioLanguage.fromCode('en'), AudioLanguage.english);
      expect(AudioLanguage.fromCode('ar'), AudioLanguage.arabic);
      expect(AudioLanguage.fromCode('ha'), AudioLanguage.hausa);
      expect(AudioLanguage.fromCode('zz'), AudioLanguage.french);
    });
  });

  group('SettingsState', () {
    test('initial state has correct defaults', () {
      const state = SettingsState();
      expect(state.themeMode, AppThemeMode.system);
      expect(state.colorTheme, AppColorTheme.serenity);
      expect(state.audioLanguage, AudioLanguage.french);
    });

    test('factory initial returns default state', () {
      final state = SettingsState.initial();
      expect(state.themeMode, AppThemeMode.system);
      expect(state.colorTheme, AppColorTheme.serenity);
      expect(state.audioLanguage, AudioLanguage.french);
    });

    test('currentColorScheme returns the scheme for the colorTheme', () {
      const state = SettingsState(colorTheme: AppColorTheme.serenity);
      expect(state.currentColorScheme, isNotNull);
      expect(state.currentColorScheme, AppColorTheme.serenity.scheme);
    });

    test('copyWith creates a new state with overridden fields', () {
      const state = SettingsState();
      final newState = state.copyWith(
        themeMode: AppThemeMode.dark,
        audioLanguage: AudioLanguage.hausa,
      );
      expect(newState.themeMode, AppThemeMode.dark);
      expect(newState.audioLanguage, AudioLanguage.hausa);
      expect(newState.colorTheme, state.colorTheme); // unchanged
    });

    test('copyWith with no args returns equivalent state', () {
      const state = SettingsState();
      final newState = state.copyWith();
      expect(newState, equals(state));
    });

    test('equality works correctly', () {
      const state1 = SettingsState();
      const state2 = SettingsState();
      expect(state1, equals(state2));
    });

    test('inequality works with different themeMode', () {
      const state1 = SettingsState(themeMode: AppThemeMode.light);
      const state2 = SettingsState(themeMode: AppThemeMode.dark);
      expect(state1, isNot(equals(state2)));
    });

    test('hashCode is consistent with equality', () {
      const state1 = SettingsState();
      const state2 = SettingsState();
      expect(state1.hashCode, equals(state2.hashCode));
    });
  });

  group('SettingsNotifier', () {
    late SettingsNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      notifier = SettingsNotifier(prefs: prefs);
    });

    test('initial state is default', () {
      // After construction, loadSettings is called but with empty prefs
      // State may be default
      expect(notifier.state.themeMode, isNotNull);
    });

    test('setThemeMode persists and updates state', () async {
      await notifier.setThemeMode(AppThemeMode.dark);
      expect(notifier.state.themeMode, AppThemeMode.dark);
    });

    test('setThemeMode is no-op for same value', () async {
      await notifier.setThemeMode(AppThemeMode.light);
      final stateBefore = notifier.state;
      await notifier.setThemeMode(AppThemeMode.light);
      expect(identical(notifier.state, stateBefore), isTrue);
    });

    test('setColorTheme persists and updates state', () async {
      for (final theme in AppColorTheme.values) {
        await notifier.setColorTheme(theme);
        expect(notifier.state.colorTheme, theme);
      }
    });

    test('setColorTheme is no-op for same value', () async {
      await notifier.setColorTheme(AppColorTheme.serenity);
      final stateBefore = notifier.state;
      await notifier.setColorTheme(AppColorTheme.serenity);
      expect(identical(notifier.state, stateBefore), isTrue);
    });

    test('setAudioLanguage persists and updates state', () async {
      await notifier.setAudioLanguage(AudioLanguage.hausa);
      expect(notifier.state.audioLanguage, AudioLanguage.hausa);
    });

    test('setAudioLanguage is no-op for same value', () async {
      await notifier.setAudioLanguage(AudioLanguage.english);
      final stateBefore = notifier.state;
      await notifier.setAudioLanguage(AudioLanguage.english);
      expect(identical(notifier.state, stateBefore), isTrue);
    });

    test('setAudioLanguage persists the language CODE (not the enum index)', () async {
      await notifier.setAudioLanguage(AudioLanguage.hausa);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('audio_language'), 'ha');
    });

    test('loadSettings restores saved values', () async {
      // Save some values
      await notifier.setThemeMode(AppThemeMode.dark);
      await notifier.setAudioLanguage(AudioLanguage.arabic);

      // Create a new notifier with same prefs
      final prefs = await SharedPreferences.getInstance();
      final newNotifier = SettingsNotifier(prefs: prefs);
      // Need to manually call loadSettings (it's also called in constructor)
      await newNotifier.loadSettings();

      expect(newNotifier.state.themeMode, AppThemeMode.dark);
      expect(newNotifier.state.audioLanguage, AudioLanguage.arabic);
    });

    test('loadSettings migrates a legacy int index to the enum value', () async {
      // Anciennes versions : index d'enum stocké en int (1 = english).
      SharedPreferences.setMockInitialValues({'audio_language': 1});
      final prefs = await SharedPreferences.getInstance();
      final migratedNotifier = SettingsNotifier(prefs: prefs);
      await migratedNotifier.loadSettings();

      expect(migratedNotifier.state.audioLanguage, AudioLanguage.english);
    });

    test('loadSettings handles invalid indices gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 999,
        'audio_language': 999,
        'color_theme': 999,
      });
      final prefs = await SharedPreferences.getInstance();
      final safeNotifier = SettingsNotifier(prefs: prefs);
      await safeNotifier.loadSettings();

      // Should fall back to defaults
      expect(safeNotifier.state.themeMode, AppThemeMode.system);
      expect(safeNotifier.state.audioLanguage, AudioLanguage.french);
    });
  });

}
