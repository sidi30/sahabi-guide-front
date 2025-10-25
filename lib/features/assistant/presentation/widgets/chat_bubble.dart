import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final Animation<double> animation;

  const ChatBubble({
    super.key,
    required this.message,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: message.isBot ? const Offset(-0.3, 0) : const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment:
                message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isBot) ...[
                _buildAvatar(context, isBot: true),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: _buildBubbleContent(context),
              ),
              if (!message.isBot) ...[
                const SizedBox(width: 12),
                _buildAvatar(context, isBot: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isBot}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isBot
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: isBot
          ? ClipOval(
              child: Image.asset(
                'assets/images/bot.jpeg',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback si l'image ne charge pas
                  return const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isBot
            ? Colors.grey[100]
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(message.isBot ? 4 : 20),
          bottomRight: Radius.circular(message.isBot ? 20 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: message.isBot ? Colors.black87 : Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: message.isBot ? Colors.grey[600] : Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

