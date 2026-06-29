import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
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
                  'Période d\'empêchement',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Le Tawaf et le Sa\'i sont reportés jusqu\'à la fin de vos menstrues et '
            'les grandes ablutions (Ghusl). Vous restez en état de sacralisation. '
            'Le pilier (Tawaf al-Ifadah) sera accompli ensuite, il ne se remplace pas.',
            style: TextStyle(fontSize: 13.5, height: 1.4),
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
                label: const Text('Actes que vous pouvez accomplir'),
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
        const acts = [
          'Lire ou écouter le Coran (avec un gant ou une barrière si vous touchez le Livre).',
          'Le Dhikr : Tahlîl, Takbîr, Tasbîh.',
          'Prier sur le Prophète (paix et salut sur lui).',
          'Invoquer Allah pour vos besoins.',
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous pouvez vous rapprocher d\'Allah par :',
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
                const Text(
                  'Les actes valent par l\'intention : vous obtenez la récompense de '
                  'ce que vous aviez l\'intention d\'accomplir.',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
