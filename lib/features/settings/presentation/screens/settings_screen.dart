import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';
import 'package:sahabi_guide/features/settings/settings.dart';

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
    BuildContext context, 
    WidgetRef ref, 
    SettingsState settings
  ) {
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context, 
    WidgetRef ref, 
    SettingsState settings
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Langue Audio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...AudioLanguage.values.map((lang) {
            return RadioListTile<AudioLanguage>(
              title: Text(_getLanguageName(lang)),
              value: lang,
              groupValue: settings.audioLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setAudioLanguage(value);
                }
              },
            );
          }).toList(),
        ],
      ),
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

  String _getLanguageName(AudioLanguage lang) {
    switch (lang) {
      case AudioLanguage.hausa:
        return 'Hausa';
      case AudioLanguage.zarma:
        return 'Zarma';
    }
  }
}
