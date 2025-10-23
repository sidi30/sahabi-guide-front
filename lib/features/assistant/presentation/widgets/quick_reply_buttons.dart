import 'package:flutter/material.dart';

class QuickReplyButtons extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplySelected;
  final bool isEnabled;

  const QuickReplyButtons({
    super.key,
    required this.replies,
    required this.onReplySelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Réponses suggérées',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: replies.map((reply) {
              return _buildReplyButton(context, reply);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyButton(BuildContext context, String reply) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => onReplySelected(reply) : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reply,
                style: TextStyle(
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isEnabled) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

