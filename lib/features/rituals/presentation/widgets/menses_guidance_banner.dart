import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Bannière de guidage en période de menstrues/lochies (profil féminin uniquement).
/// L'adaptation est faite côté client : aucune donnée de santé n'est transmise.
/// Ton apaisant, non culpabilisant.
class MensesGuidanceBanner extends ConsumerWidget {
  const MensesGuidanceBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (settings.gender != 'FEMALE' || !settings.menses) {
      return const SizedBox.shrink();
    }
    final color = ref.colors.primary;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.menses_title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.menses_body,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showAlternativeActs(context, color),
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(l10n.menses_acts_button),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAlternativeActs(BuildContext context, Color color) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final acts = [
          l10n.menses_act_quran,
          l10n.menses_act_dhikr,
          l10n.menses_act_salawat,
          l10n.menses_act_dua,
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.menses_acts_sheet_title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                ...acts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: color),
                          const SizedBox(width: 10),
                          Expanded(child: Text(a, style: const TextStyle(height: 1.4))),
                        ],
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  l10n.menses_acts_note,
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
