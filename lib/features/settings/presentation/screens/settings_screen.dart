import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';
import 'package:sahabi_guide/features/settings/settings.dart';
import 'package:sahabi_guide/shared/constants/app_locale.dart';
import 'package:sahabi_guide/core/providers/language_provider.dart';
import 'package:sahabi_guide/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:sahabi_guide/core/theme/app_color_schemes.dart';

import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings_title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildGenderSection(context, ref, settings),
          _buildColorThemeSection(context, ref, settings),
          _buildThemeModeSection(context, ref, settings),
          _buildLanguageSection(context, ref, settings),
        ],
      ),
    );
  }

  /// Section pour choisir le genre (pilote le contenu des rites + thème par défaut)
  Widget _buildGenderSection(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    Widget option(String value, IconData icon, String label) {
      final selected = settings.gender == value;
      final color = Theme.of(context).colorScheme.primary;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await ref.read(settingsProvider.notifier).setGender(value);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profil "$label" appliqué'),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.10) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? color : Theme.of(context).dividerColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 32, color: selected ? color : null),
                const SizedBox(height: 6),
                Text(label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? color : null,
                    )),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('Profil', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Les rites affichés diffèrent entre un homme et une femme.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    option('MALE', Icons.man, 'Pèlerin'),
                    const SizedBox(width: 12),
                    option('FEMALE', Icons.woman, 'Pèlerine'),
                  ],
                ),
                if (settings.gender == 'FEMALE') ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.menses,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setMenses(v),
                    title: const Text('Je suis actuellement empêchée'),
                    subtitle: const Text(
                      'Menstrues ou lochies. Adapte le guidage (Tawaf/Sa\'i reportés). '
                      'Reste sur votre téléphone, n\'est jamais partagé.',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section pour choisir le thème de couleur
  Widget _buildColorThemeSection(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Thème de couleur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColorTheme.values.map((theme) {
                final isSelected = settings.colorTheme == theme;
                return _ColorThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setColorTheme(theme);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Thème "${theme.displayName}" appliqué'),
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Section pour choisir le mode (clair/sombre/système)
  Widget _buildThemeModeSection(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    const List<AppThemeMode> themeModes = AppThemeMode.values;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.brightness_6_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mode d\'affichage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...themeModes.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeModeName(mode)),
              subtitle: Text(_getThemeModeDescription(mode)),
              secondary: Icon(_getThemeModeIcon(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(settingsProvider.notifier).setThemeMode(value);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mode "${_getThemeModeName(value)}" activé'),
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  }
                }
              },
            );
          }),
          const SizedBox(height: 8),
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              Icons.language,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              localizations.settings_language,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              currentAppLocale.displayName,
              style: Theme.of(context).textTheme.bodyMedium,
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.headphones_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizations.settings_audio_language,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.common_success),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: 8),
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

  String _getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Suit les paramètres de votre appareil';
      case AppThemeMode.light:
        return 'Toujours afficher le thème clair';
      case AppThemeMode.dark:
        return 'Toujours afficher le thème sombre';
    }
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.settings_suggest_outlined;
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  String _getAudioLanguageName(
      AudioLanguage lang, AppLocalizations localizations) {
    // Le libellé canonique de chaque langue est porté par l'enum lui-même
    // (français, anglais, arabe + langues africaines servies par le backend
    // voix : Hausa, Zarma, Yoruba, Kiswahili, Wolof, Bambara).
    return lang.label;
  }
}

/// Widget pour afficher une carte de thème de couleur
class _ColorThemeCard extends StatelessWidget {
  final AppColorTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = theme.scheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.previewColor.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.previewColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.previewColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prévisualisation des couleurs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ColorDot(color: scheme.primary, size: 20),
                const SizedBox(width: 4),
                _ColorDot(color: scheme.secondary, size: 20),
                const SizedBox(width: 4),
                _ColorDot(color: scheme.accent, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            // Nom du thème
            Text(
              theme.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.previewColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Indicateur de sélection
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                color: theme.previewColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher un point de couleur
class _ColorDot extends StatelessWidget {
  final Color color;
  final double size;

  const _ColorDot({
    required this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
