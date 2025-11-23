import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';
import 'package:sahabi_guide/features/settings/settings.dart';
import 'package:sahabi_guide/shared/constants/app_locale.dart';
import 'package:sahabi_guide/core/providers/language_provider.dart';
import 'package:sahabi_guide/features/settings/presentation/screens/language_settings_screen.dart';

import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildThemeSection(context, ref, settings),
          _buildLanguageSection(context, ref, settings),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    const List<AppThemeMode> themeModes = AppThemeMode.values;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Thème',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...themeModes.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeModeName(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(settingsProvider.notifier).setThemeMode(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Theme changed successfully'),
                        duration: Duration(milliseconds: 900)),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return Column(
      children: [
        // UI Language Selection - Navigation vers l'écran dédié
        Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.language, size: 28),
            title: Text(
              localizations.settings_language,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              currentAppLocale.displayName,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
        ),

        // Audio Language Selection
        Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  localizations.settings_audio_language,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...AudioLanguage.values.map((lang) {
                return RadioListTile<AudioLanguage>(
                  title: Text(_getAudioLanguageName(lang, localizations)),
                  value: lang,
                  groupValue: settings.audioLanguage,
                  onChanged: (value) async {
                    if (value != null) {
                      await ref
                          .read(settingsProvider.notifier)
                          .setAudioLanguage(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.common_success),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  String _getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Système';
      case AppThemeMode.light:
        return 'Clair';
      case AppThemeMode.dark:
        return 'Sombre';
    }
  }

  String _getAudioLanguageName(
      AudioLanguage lang, AppLocalizations localizations) {
    switch (lang) {
      case AudioLanguage.english:
        return 'English';
      case AudioLanguage.hausa:
        return 'Hausa';
      case AudioLanguage.zarma:
        return 'Zarma';
    }
  }
}
