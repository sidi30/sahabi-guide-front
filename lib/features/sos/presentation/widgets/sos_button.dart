import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/sos_provider.dart';
import 'sos_countdown_sheet.dart';

/// Rouge d'urgence, volontairement hors palette de thème : le bouton doit
/// rester identifiable quel que soit le thème choisi (clair, sombre, palettes
/// homme/femme).
const Color kSosRed = Color(0xFFB3261E);

/// Ouvre le compte à rebours ; n'envoie le SOS que s'il va à son terme.
///
/// Retourne `true` quand un SOS a été mis en file (donc persisté), `false`
/// quand le pèlerin a annulé.
Future<bool> startSosCountdown(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(sosQueueProvider.notifier);

  final confirmed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'SOS',
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (dialogContext, _, __) => SosCountdownSheet(
      onElapsed: () => Navigator.of(dialogContext).pop(true),
      onCancelled: () => Navigator.of(dialogContext).pop(false),
    ),
  );

  if (confirmed != true) return false;
  await notifier.trigger();
  return true;
}

/// Bouton d'appel au secours : icône universelle + mot localisé, parce que la
/// cible ne lit pas toujours, mais reconnaît le rouge et le pictogramme.
class SosFloatingButton extends ConsumerWidget {
  const SosFloatingButton({super.key, this.compact = false});

  /// Version réduite (pages sans place pour le libellé complet).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: t.sos_button_semantics,
      child: Material(
        color: kSosRed,
        elevation: 6,
        shadowColor: kSosRed.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => startSosCountdown(context, ref),
          child: Container(
            constraints: const BoxConstraints(minWidth: 72, minHeight: 56),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sos_rounded, color: Colors.white, size: 26),
                const SizedBox(height: 2),
                Text(
                  t.sos_button_label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
