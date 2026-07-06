import 'package:flutter/material.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
import 'quick_reply_keys.dart';

/// Chip pour les réponses rapides
class QuickReplyChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isEnabled;

  const QuickReplyChip({
    super.key,
    required this.text,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(
            color: isEnabled ? const Color(0xFF1D3557) : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onPressed: isEnabled ? onTap : null,
        backgroundColor: isEnabled ? Colors.white : Colors.grey[200],
        side: BorderSide(
          color: isEnabled
              ? const Color(0xFF1D3557).withValues(alpha: 0.3)
              : Colors.grey[400]!,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: isEnabled ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
    );
  }
}

/// Liste de boutons de réponse rapide.
///
/// Chaque entrée de [replies] est soit :
///   - une CLÉ FIXE `qr:*` (vocabulaire fixe) -> affichée localisée via l10n,
///     et la réponse ENVOYÉE est le libellé FR canonique (le matching du bot
///     est basé sur le FR). Le libellé se met à jour automatiquement avec la
///     locale (re-render).
///   - une valeur DYNAMIQUE (issue des données d'étape) -> affichée et envoyée
///     telle quelle.
class QuickReplyList extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplySelected;
  final bool isEnabled;

  /// Libellés d'AFFICHAGE traduits des réponses rapides DYNAMIQUES : map
  /// `valeur FR canonique -> libellé traduit`. Quand une entrée existe, le chip
  /// affiche le libellé traduit mais ENVOIE toujours la valeur FR canonique
  /// (clé), pour que le matching des étapes du bot reste correct.
  final Map<String, String>? dynamicLabels;

  const QuickReplyList({
    super.key,
    required this.replies,
    required this.onReplySelected,
    this.isEnabled = true,
    this.dynamicLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.bot_suggested_replies,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: replies.map((reply) {
                // Clé fixe (`qr:*`) -> libellé localisé via l10n. Sinon réponse
                // dynamique -> libellé traduit s'il est fourni, à défaut la
                // valeur brute. Dans tous les cas la valeur ENVOYÉE reste le FR
                // canonique (le matching du bot est basé sur le FR).
                final label = QuickReplyKeys.localizedLabel(l10n, reply) ??
                    dynamicLabels?[reply];
                final sendValue =
                    QuickReplyKeys.canonicalFr(reply) ?? reply;
                return QuickReplyChip(
                  text: label ?? reply,
                  onTap: () => onReplySelected(sendValue),
                  isEnabled: isEnabled,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
