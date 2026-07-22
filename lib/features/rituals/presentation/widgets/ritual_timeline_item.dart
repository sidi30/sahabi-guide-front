import 'package:flutter/material.dart';
import '../../../../shared/models/ritual_model.dart';
import 'ritual_detail_section.dart';
import 'video_player_widget.dart';

class RitualTimelineItem extends StatefulWidget {
  final RitualModel ritual;
  final bool isLast;
  final String audioLanguage;
  final VoidCallback? onMarkAsCompleted;
  /// Override local de l'état « accompli » (suivi on-device), prioritaire sur
  /// le statut serveur pour que le marquage soit immédiatement visible.
  final bool isDone;
  /// Position dans la liste affichée (0-based) — sert au numéro d'étape du cercle.
  final int index;

  const RitualTimelineItem({
    super.key,
    required this.ritual,
    required this.isLast,
    required this.audioLanguage,
    this.index = 0,
    this.onMarkAsCompleted,
    this.isDone = false,
  });

  @override
  State<RitualTimelineItem> createState() => _RitualTimelineItemState();
}

class _RitualTimelineItemState extends State<RitualTimelineItem> {
  bool _showDetails = false;

  bool get _completed =>
      widget.isDone || widget.ritual.status == RitualStatus.completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          _buildTimelineIndicator(),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              children: [
                _buildRitualContent(),

                // Section détaillée unifiée
                if (_showDetails) ...[
                  const SizedBox(height: 16),
                  RitualDetailSection(
                    ritual: widget.ritual,
                    audioLanguage: widget.audioLanguage,
                    onMarkAsCompleted: () {
                      widget.onMarkAsCompleted?.call();
                      setState(() {
                        _showDetails = false;
                      });
                    },
                    onWatchVideo: () {},
                  ),
                  // Affiche la carte vidéo (miniature + tap externe) dès
                  // l'expansion des détails — sinon invisible jusqu'à un clic
                  // « Regarder la vidéo » qui ne se déclenchait jamais si
                  // launchUrl externe échouait.
                  const SizedBox(height: 16),
                  VideoPlayerWidget(
                    videoUrl: widget.ritual.getVideoUrl(widget.audioLanguage),
                    ritualName: widget.ritual.name,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    // Jeu de couleurs par état, pensé pour la LISIBILITÉ du numéro :
    //  - fill  : fond du cercle
    //  - fg    : couleur du numéro (contraste AA garanti sur le fond)
    //  - un anneau clair entoure le cercle pour le détacher du fond.
    Color fill;
    Color fg;

    if (_completed) {
      fill = const Color(0xFF10B981); // Vert — accompli
      fg = Colors.white;
      return _indicatorColumn(fill, fg, done: true);
    }

    switch (widget.ritual.status) {
      case RitualStatus.completed:
        fill = const Color(0xFF10B981); // Vert
        fg = Colors.white;
        return _indicatorColumn(fill, fg, done: true);
      case RitualStatus.active:
        fill = const Color(0xFF2563EB); // Bleu franc — en cours (lisible, blanc dessus)
        fg = Colors.white;
        break;
      case RitualStatus.overdue:
        fill = const Color(0xFFDC2626); // Rouge — manqué
        fg = Colors.white;
        break;
      case RitualStatus.pending:
        // À venir : cercle teinté clair + numéro FONCÉ (fort contraste), au lieu de
        // blanc-sur-gris (illisible). Numéro dans la couleur de marque.
        fill = const Color(0xFFE8F1EE);
        fg = const Color(0xFF1D6B57);
        break;
    }

    return _indicatorColumn(fill, fg);
  }

  Widget _indicatorColumn(Color fill, Color fg, {bool done = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: fill.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: done
                ? Icon(Icons.check, color: fg, size: 20)
                : Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (!widget.isLast)
          Container(
            width: 2,
            height: 80,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: done ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  Widget _buildRitualContent() {
    final isCompleted = _completed;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Repère glanceable : un rite accompli a un fond vert clair + bordure verte,
        // pour ne pas se tromper d'un coup d'oeil pendant la marche.
        color: isCompleted ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: const Color(0xFF10B981), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et statut
          Row(
            children: [
              if (isCompleted) ...[
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.ritual.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF065F46)
                        : const Color(0xFF1D3557),
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF10B981),
                  ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            widget.ritual.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Bouton principal d'action
          _buildMainActionButton(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String statusText;
    Color backgroundColor;
    Color textColor;

    if (_completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('✅ Fait',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
      );
    }

    switch (widget.ritual.status) {
      case RitualStatus.completed:
        statusText = '✅ Fait';
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case RitualStatus.active:
        statusText = '🔘 En cours';
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        break;
      case RitualStatus.overdue:
        statusText = '❌ Manqué';
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case RitualStatus.pending:
        statusText = '🕓 À venir';
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMainActionButton() {
    final isCompleted = _completed;
    final isOverdue = widget.ritual.status == RitualStatus.overdue;
    final isActive = widget.ritual.status == RitualStatus.active;

    if (isCompleted) {
      // Tappable pour annuler en cas d'erreur de marquage.
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.onMarkAsCompleted,
          icon: const Icon(Icons.check_circle, size: 20),
          label: const Text('✅ Accompli — appuyez pour annuler'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
            foregroundColor: const Color(0xFF065F46),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    }

    if (isOverdue) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.warning, size: 20),
          label: const Text('❌ Rituel manqué'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            foregroundColor: Colors.grey,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _showDetails = !_showDetails;
          });
        },
        icon: Icon(
          _showDetails ? Icons.expand_less : Icons.expand_more,
          size: 20,
        ),
        label: Text(
          _showDetails ? 'Masquer les détails' : 'Voir les détails',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? const Color(0xFF4FC3F7).withValues(alpha: 0.1)
              : const Color(0xFF6B7280).withValues(alpha: 0.1),
          foregroundColor:
              isActive ? const Color(0xFF4FC3F7) : const Color(0xFF6B7280),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
