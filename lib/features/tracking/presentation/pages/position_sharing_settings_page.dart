import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/tracking_config_model.dart';
import '../providers/position_sharing_provider.dart';

/// Réglage du partage de position.
///
/// Trois partis pris, écrits ici parce qu'ils se discutent :
///
/// 1. **Éteint par défaut.** Rien ne part tant que le pèlerin n'a pas basculé
///    l'interrupteur lui-même. Un suivi de personnes qui s'allume tout seul est
///    une surveillance, pas un service.
/// 2. **Cadence espacée.** 30 minutes ou 1 heure. Une position par minute ne
///    servirait qu'à vider la batterie de quelqu'un qui marche entre deux lieux
///    distants de quelques centaines de mètres — et une batterie vide, c'est un
///    pèlerin injoignable.
/// 3. **Une seule exception, dite en toutes lettres à l'écran** : pendant un
///    appel d'urgence, la position est envoyée fréquemment même si le partage
///    est éteint. Cacher cette exception serait un mensonge par omission.
class PositionSharingSettingsPage extends ConsumerStatefulWidget {
  const PositionSharingSettingsPage({super.key});

  @override
  ConsumerState<PositionSharingSettingsPage> createState() =>
      _PositionSharingSettingsPageState();
}

class _PositionSharingSettingsPageState
    extends ConsumerState<PositionSharingSettingsPage> {
  bool _demandeEnCours = false;

  /// Activer sans permission système donnerait un interrupteur allumé qui
  /// n'envoie rien : on demande la permission AVANT d'enregistrer le réglage,
  /// et on ne l'enregistre que si elle est accordée.
  Future<void> _activer() async {
    setState(() => _demandeEnCours = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final accordee = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!accordee) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sans autorisation de localisation, votre position ne peut pas '
              'être partagée. Vous pouvez l\'accorder dans les réglages du téléphone.',
            ),
          ),
        );
        return;
      }
      await ref.read(positionSharingProvider.notifier).setEnabled(true);
    } finally {
      if (mounted) setState(() => _demandeEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharing = ref.watch(positionSharingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Partage de position')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Partager ma position'),
              subtitle: Text(
                sharing.enabled
                    ? 'Votre agence voit où vous êtes sur sa carte.'
                    : 'Désactivé : aucune position n\'est envoyée.',
              ),
              value: sharing.enabled,
              onChanged: _demandeEnCours
                  ? null
                  : (value) async {
                      if (value) {
                        await _activer();
                      } else {
                        await ref
                            .read(positionSharingProvider.notifier)
                            .setEnabled(false);
                      }
                    },
            ),
          ),
          const SizedBox(height: 16),
          Text('Fréquence', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final mode in TrackingConfig.selectableModes)
                  RadioListTile<TrackingMode>(
                    title: Text(mode.label),
                    subtitle: Text('Impact batterie : ${mode.batteryImpact}'),
                    value: mode,
                    groupValue: sharing.mode,
                    onChanged: sharing.enabled
                        ? (value) {
                            if (value != null) {
                              ref
                                  .read(positionSharingProvider.notifier)
                                  .setMode(value);
                            }
                          }
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendant une alerte d\'urgence',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Si vous déclenchez le bouton d\'urgence, votre position est '
                    'envoyée fréquemment jusqu\'à ce que votre agence confirme '
                    'avoir reçu l\'alerte — même si le partage ci-dessus est '
                    'désactivé. Appeler à l\'aide, c\'est demander à être trouvé.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
