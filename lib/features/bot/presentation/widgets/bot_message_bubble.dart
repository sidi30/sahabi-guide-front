import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
import '../../data/models/bot_message_model.dart';

/// Bulle de message du chat. Pour les messages bot, decoupe le contenu en
/// trois sections distinctes rendues avec un style different :
///   1. Corps principal (fond gris clair)
///   2. Texte arabe original des invocations (encadré vert, police plus grande)
///   3. Disclaimer "reponse indicative" (italique, icone info, fond clair)
class BotMessageBubble extends StatelessWidget {
  final BotMessageModel message;
  final Animation<double> animation;
  final VoidCallback? onSpeak;
  final VoidCallback? onStop;
  final bool isSpeaking;

  const BotMessageBubble({
    super.key,
    required this.message,
    required this.animation,
    this.onSpeak,
    this.onStop,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      ),
      child: message.isBot ? _buildBotBubble(context) : _buildUserBubble(context),
    );
  }

  /// Decoupe le contenu en { main, arabic, disclaimer } selon les marqueurs.
  _ContentParts _splitContent(String raw) {
    String main = raw;
    String? arabic;
    String? disclaimer;

    // Disclaimer : tout ce qui est apres "\n\nℹ️"
    final infoIdx = main.indexOf('ℹ️');
    if (infoIdx > 0) {
      disclaimer = main.substring(infoIdx).trim();
      main = main.substring(0, infoIdx).trim();
    }

    // Arabe : bloc "— Texte arabe" ou "— Addu'o'i a Larabci"
    final arabicMarkers = ['— Texte arabe', "— Addu'o'i a Larabci"];
    for (final marker in arabicMarkers) {
      final idx = main.indexOf(marker);
      if (idx > 0) {
        arabic = main.substring(idx).trim();
        main = main.substring(0, idx).trim();
        break;
      }
    }
    return _ContentParts(main: main, arabic: arabic, disclaimer: disclaimer);
  }

  Widget _buildBotBubble(BuildContext context) {
    final parts = _splitContent(message.content);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1D3557),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/bot.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (parts.main.isNotEmpty)
                        SelectableText(
                          parts.main,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      if (parts.arabic != null) ...[
                        const SizedBox(height: 12),
                        _buildArabicBlock(parts.arabic!),
                      ],
                      if (parts.disclaimer != null) ...[
                        const SizedBox(height: 12),
                        _buildDisclaimerBlock(parts.disclaimer!),
                      ],
                      // Note discrète "réponse incertaine" (abstention / low conf.)
                      if (message.isLowConfidence) ...[
                        const SizedBox(height: 10),
                        _buildLowConfidenceNote(context),
                      ],
                      // Citations RAG : top 1-2 sources, ligne sobre.
                      if (message.sources != null &&
                          message.sources!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildSources(context, message.sources!),
                      ],
                    ],
                  ),
                ),
                // Actions sous le message
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Row(
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      if (onSpeak != null || onStop != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: isSpeaking ? onStop : onSpeak,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSpeaking
                                      ? Icons.stop_circle
                                      : Icons.volume_up_rounded,
                                  size: 16,
                                  color: isSpeaking
                                      ? Colors.red
                                      : const Color(0xFF1D3557),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSpeaking
                                      ? AppLocalizations.of(context)!.bot_stop
                                      : AppLocalizations.of(context)!
                                          .bot_listen,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSpeaking
                                        ? Colors.red
                                        : const Color(0xFF1D3557),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (message.relatedRitualId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: TextButton.icon(
                      onPressed: () {
                        context.push('/rituals/detail/${message.relatedRitualId}');
                      },
                      icon: const Icon(Icons.book, size: 16),
                      label: Text(AppLocalizations.of(context)!.bot_view_ritual),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArabicBlock(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A9D8F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          right: BorderSide(color: Color(0xFF2A9D8F), width: 3),
          left: BorderSide(color: Color(0xFF2A9D8F), width: 3),
        ),
      ),
      child: SelectableText(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: Color(0xFF0F3B32),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDisclaimerBlock(String text) {
    // Retire l'emoji "ℹ️" pour la mise en forme visuelle
    final clean = text.replaceFirst('ℹ️', '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFECB5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF856404),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              clean,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF856404),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Note amber discrète sous une réponse incertaine (abstention / low conf.).
  Widget _buildLowConfidenceNote(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 15,
          color: Color(0xFFB7791F),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.bot_low_confidence,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xFFB7791F),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Affiche les 1-2 meilleures citations RAG sous forme de ligne sobre
  /// "Source : <titre>". Si un ritualId est présent, le titre est cliquable et
  /// ouvre la fiche rituel (route existante `/rituals/detail/:id`).
  Widget _buildSources(BuildContext context, List<BotSource> sources) {
    final label = AppLocalizations.of(context)!.bot_source;
    final top = sources.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in top)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: s.ritualId != null
                      ? InkWell(
                          onTap: () => context
                              .push('/rituals/detail/${s.ritualId}'),
                          child: Text(
                            '$label : ${s.title}',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF1D3557),
                              decoration: TextDecoration.underline,
                              height: 1.3,
                            ),
                          ),
                        )
                      : Text(
                          '$label : ${s.title}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D3557),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06D6A0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _ContentParts {
  final String main;
  final String? arabic;
  final String? disclaimer;

  _ContentParts({
    required this.main,
    this.arabic,
    this.disclaimer,
  });
}
