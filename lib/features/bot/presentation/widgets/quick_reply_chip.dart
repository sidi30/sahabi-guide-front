import 'package:flutter/material.dart';

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
              ? const Color(0xFF1D3557).withOpacity(0.3)
              : Colors.grey[400]!,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: isEnabled ? 2 : 0,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }
}

/// Liste de boutons de réponse rapide
class QuickReplyList extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplySelected;
  final bool isEnabled;

  const QuickReplyList({
    super.key,
    required this.replies,
    required this.onReplySelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Réponses suggérées',
            style: TextStyle(
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
              children: replies
                  .map((reply) => QuickReplyChip(
                        text: reply,
                        onTap: () => onReplySelected(reply),
                        isEnabled: isEnabled,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

