import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';
import 'package:sahabi_guide/features/settings/settings.dart';
import 'package:sahabi_guide/shared/constants/app_locale.dart';

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
          //_buildLanguageSection(context, ref, settings),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    final List<AppThemeMode> themeModes = AppThemeMode.values;

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
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
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

    return Column(
      children: [
        // UI Language Selection
        Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  localizations.language,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...AppLocale.values.map((locale) {
                return RadioListTile<AppLocale>(
                  title: Text(_getUILanguageName(locale, localizations)),
                  value: locale,
                  groupValue: settings.locale,
                  onChanged: (AppLocale? newLocale) {
                    if (newLocale != null) {
                      ref.read(settingsProvider.notifier).setLocale(newLocale);
                    }
                  },
                );
              }).toList(),
            ],
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
                  'Audio Language',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...AudioLanguage.values.map((lang) {
                return RadioListTile<AudioLanguage>(
                  title: Text(_getAudioLanguageName(lang, localizations)),
                  value: lang,
                  groupValue: settings.audioLanguage,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .setAudioLanguage(value);
                    }
                  },
                );
              }).toList(),
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

  String _getUILanguageName(AppLocale locale, AppLocalizations localizations) {
    switch (locale) {
      case AppLocale.fr:
        return localizations.french;
      case AppLocale.en:
        return localizations.english;
      case AppLocale.ar:
        return localizations.arabic;
    }
  }

  String _getAudioLanguageName(
      AudioLanguage lang, AppLocalizations localizations) {
    switch (lang) {
      case AudioLanguage.hausa:
        return 'ha'; //localizations.hausa;
      case AudioLanguage.zarma:
        return 'zarma';
    }
  }
}
