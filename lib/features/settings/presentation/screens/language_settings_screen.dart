import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/app_locale.dart';
import '../providers/settings_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_language),
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        children: [
          // Section d'information
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ref.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ref.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ref.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choisissez la langue de l\'interface\nChoose interface language\naختر لغة الواجهة',
                    style: TextStyle(
                      color: ref.colors.primary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste des langues disponibles
          ...AppLocale.values.map((appLocale) {
            final isSelected = appLocale == currentAppLocale;

            return _buildLanguageTile(
              context: context,
              ref: ref,
              appLocale: appLocale,
              isSelected: isSelected,
            );
          }),

          const SizedBox(height: 16),

          // Section d'information RTL
          if (currentAppLocale == AppLocale.ar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.format_textdirection_r_to_l,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'اللغة العربية مدعومة بتنسيق من اليمين إلى اليسار (RTL)',
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontSize: 13,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocale appLocale,
    required bool isSelected,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        onTap: () async {
          if (!isSelected) {
            await ref.read(languageProvider.notifier).changeLanguage(appLocale);
            // La langue d'interface est la source de vérité unique : on aligne
            // aussi la langue audio (rituels/duas) sur ce choix pour les 4
            // langues principales (fr/en/ar/ha), afin que toute l'expérience
            // suive la même langue.
            await ref
                .read(settingsProvider.notifier)
                .setAudioLanguage(AudioLanguage.fromCode(appLocale.code));

            // Afficher un message de confirmation
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _getSuccessMessage(appLocale),
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: ref.colors.success,
                ),
              );
            }
          }
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? ref.colors.primary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              _getFlag(appLocale),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          appLocale.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? ref.colors.primary : null,
          ),
        ),
        subtitle: Text(
          _getSubtitle(appLocale),
          style: TextStyle(
            fontSize: 12,
            color: ref.colors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: ref.colors.primary,
                size: 28,
              )
            : Icon(
                Icons.circle_outlined,
                color: ref.colors.textLight,
                size: 28,
              ),
      ),
    );
  }

  String _getFlag(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.fr:
        return '\u{1F1EB}\u{1F1F7}';
      case AppLocale.en:
        return '\u{1F1EC}\u{1F1E7}';
      case AppLocale.ar:
        return '\u{1F1F8}\u{1F1E6}';
      case AppLocale.ha:
        return '\u{1F1F3}\u{1F1EA}'; // Hausa (Niger / Nigeria)
    }
  }

  String _getSubtitle(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.fr:
        return 'Francais';
      case AppLocale.en:
        return 'English';
      case AppLocale.ar:
        return 'العربية';
      case AppLocale.ha:
        return 'Hausa';
    }
  }

  String _getSuccessMessage(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.fr:
        return 'Langue changee en Francais';
      case AppLocale.en:
        return 'Language changed to English';
      case AppLocale.ar:
        return 'تم تغيير اللغة إلى العربية';
      case AppLocale.ha:
        return 'An canza harshe zuwa Hausa';
    }
  }
}
