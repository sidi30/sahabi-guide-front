import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/app_locale.dart';
import '../../../../shared/constants/app_colors.dart';

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
        automaticallyImplyLeading: true, // ✅ Bouton retour automatique
      ),
      body: ListView(
        children: [
          // Section d'information
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choisissez la langue de l\'interface\nChoose interface language\nاختر لغة الواجهة',
                    style: const TextStyle(
                      color: AppColors.primary,
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
                  backgroundColor: AppColors.success,
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
                ? AppColors.primary.withValues(alpha: 0.1)
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
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        subtitle: Text(
          _getSubtitle(appLocale),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              )
            : Icon(
                Icons.circle_outlined,
                color: Colors.grey[400],
                size: 28,
              ),
      ),
    );
  }

  String _getFlag(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.fr:
        return '🇫🇷';
      case AppLocale.en:
        return '🇬🇧';
      case AppLocale.ar:
        return '🇸🇦';
    }
  }

  String _getSubtitle(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.fr:
        return 'Français';
      case AppLocale.en:
        return 'English';
      case AppLocale.ar:
        return 'العربية';
    }
  }

  String _getSuccessMessage(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.fr:
        return 'Langue changée en Français';
      case AppLocale.en:
        return 'Language changed to English';
      case AppLocale.ar:
        return 'تم تغيير اللغة إلى العربية';
    }
  }
}

