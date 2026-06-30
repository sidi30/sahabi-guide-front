import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabi_guide/core/theme/app_color_schemes.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';

/// Verrouille la logique « palette par défaut pilotée par le genre » corrigée
/// après le rapport bug-hunter (les couleurs ne s'appliquaient pas).
void main() {
  Future<SettingsNotifier> build(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    final n = SettingsNotifier(prefs: prefs);
    await n.loadSettings();
    return n;
  }

  test('genre nul -> palette par defaut serenity', () async {
    final n = await build({});
    expect(n.state.currentColorScheme.primary,
        AppColorTheme.serenity.scheme.primary);
  });

  test('FEMALE -> palette rawdah (aubergine)', () async {
    final n = await build({});
    await n.setGender('FEMALE');
    expect(n.state.currentColorScheme.primary,
        AppColorTheme.rawdah.scheme.primary);
  });

  test('MALE -> palette serenity (emeraude)', () async {
    final n = await build({});
    await n.setGender('MALE');
    expect(n.state.currentColorScheme.primary,
        AppColorTheme.serenity.scheme.primary);
  });

  test('install existante avec cle color_theme historique : FEMALE obtient quand meme rawdah',
      () async {
    // Avant le fix, la simple presence de color_theme bloquait la palette genre.
    final n = await build({'color_theme': AppColorTheme.desertGold.index});
    await n.setGender('FEMALE');
    expect(n.state.currentColorScheme.primary,
        AppColorTheme.rawdah.scheme.primary);
  });

  test('choix manuel explicite prime sur le defaut genre', () async {
    final n = await build({});
    await n.setGender('FEMALE');
    await n.setColorTheme(AppColorTheme.starryNight);
    expect(n.state.currentColorScheme.primary,
        AppColorTheme.starryNight.scheme.primary);
  });

  test('changer pour MALE efface l etat menses', () async {
    final n = await build({'pilgrim_gender': 'FEMALE', 'pilgrim_menses': true});
    expect(n.state.menses, true);
    await n.setGender('MALE');
    expect(n.state.menses, false);
  });
}
