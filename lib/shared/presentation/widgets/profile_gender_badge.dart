import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';

/// Badge de profil persistant (homme/femme). Repère anti-erreur indépendant de
/// la couleur du thème : même si l'utilisateur change de palette, ce badge
/// rappelle le profil actif (et donc le contenu de rites affiché).
class ProfileGenderBadge extends ConsumerWidget {
  const ProfileGenderBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(settingsProvider).gender;
    if (gender != 'MALE' && gender != 'FEMALE') {
      return const SizedBox.shrink();
    }
    final isFemale = gender == 'FEMALE';
    final label = isFemale ? 'Pèlerine' : 'Pèlerin';
    final icon = isFemale ? Icons.woman : Icons.man;
    final color = ref.colors.primary;

    return Semantics(
      label: 'Profil : $label',
      child: Container(
        // Marge verticale seule : l'inset horizontal est géré par le parent
        // (home padde déjà de 16 ; rituals ajoute son propre Padding). La marge
        // basse évite que le badge soit collé à la carte d'accueil en dessous.
        margin: const EdgeInsets.only(top: 4, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
