import 'package:flutter/material.dart';
import '../../../../shared/models/ritual_model.dart';
import 'ritual_detail_section.dart';
import 'video_player_widget.dart';

class RitualTimelineItem extends StatefulWidget {
  final RitualModel ritual;
  final bool isLast;
  final String audioLanguage;
  final VoidCallback? onMarkAsCompleted;

  const RitualTimelineItem({
    super.key,
    required this.ritual,
    required this.isLast,
    required this.audioLanguage,
    this.onMarkAsCompleted,
  });

  @override
  State<RitualTimelineItem> createState() => _RitualTimelineItemState();
}

class _RitualTimelineItemState extends State<RitualTimelineItem> {
  bool _showDetails = false;
  bool _showVideo = false;

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
                    onWatchVideo: () {
                      setState(() {
                        _showVideo = true;
                      });
                    },
                  ),
                ],
                if (_showVideo) ...[
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
    Color indicatorColor;
    IconData indicatorIcon;

    switch (widget.ritual.status) {
      case RitualStatus.completed:
        indicatorColor = const Color(0xFF10B981); // Vert
        indicatorIcon = Icons.check_circle;
        break;
      case RitualStatus.active:
        indicatorColor = const Color(0xFF4FC3F7); // Bleu
        indicatorIcon = Icons.access_time;
        break;
      case RitualStatus.overdue:
        indicatorColor = const Color(0xFFEF4444); // Rouge
        indicatorIcon = Icons.warning;
        break;
      case RitualStatus.pending:
      default:
        indicatorColor = const Color(0xFFE5E7EB); // Gris
        indicatorIcon = Icons.circle_outlined;
        break;
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: indicatorColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            indicatorIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
        if (!widget.isLast)
          Container(
            width: 2,
            height: 80,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: widget.ritual.status == RitualStatus.completed
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  Widget _buildRitualContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Expanded(
                child: Text(
                  widget.ritual.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
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
      default:
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
    final isCompleted = widget.ritual.status == RitualStatus.completed;
    final isOverdue = widget.ritual.status == RitualStatus.overdue;
    final isActive = widget.ritual.status == RitualStatus.active;

    if (isCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, size: 20),
          label: const Text('✅ Rituel accompli'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
            foregroundColor: const Color(0xFF10B981),
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
            if (!_showDetails) {
              _showVideo = false;
            }
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
