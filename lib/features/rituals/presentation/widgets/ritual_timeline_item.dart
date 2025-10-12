import 'package:flutter/material.dart';
import '../../../../shared/models/ritual_model.dart';

class RitualTimelineItem extends StatelessWidget {
  final RitualModel ritual;
  final bool isLast;
  final VoidCallback? onStartRitual;
  final VoidCallback? onCompleteRitual;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onWatchVideo;

  const RitualTimelineItem({
    super.key,
    required this.ritual,
    required this.isLast,
    this.onStartRitual,
    this.onCompleteRitual,
    this.onPlayAudio,
    this.onWatchVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ritual.getStatusColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ritual.getStatusColor().withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                ritual.getStatusIcon(),
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 80,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: ritual.isCompleted 
                      ? ritual.getStatusColor()
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ritual.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ritual.isCompleted 
                              ? Colors.grey[600] 
                              : const Color(0xFF1D3557),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ritual.getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ritual.getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  ritual.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                // Scheduled time
                if (ritual.scheduledTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatScheduledTime(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                // Action buttons
                if (ritual.status == RitualStatus.active) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ] else if (ritual.status == RitualStatus.pending) ...[
                  const SizedBox(height: 16),
                  _buildPendingButtons(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Media buttons
        if (ritual.audioPaths.isNotEmpty || ritual.videoPath != null) ...[
          Row(
            children: [
              if (ritual.audioPaths.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPlayAudio,
                    icon: const Icon(Icons.headphones, size: 18),
                    label: const Text('Audio Guide'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      foregroundColor: const Color(0xFF4FC3F7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              if (ritual.audioPaths.isNotEmpty && ritual.videoPath != null)
                const SizedBox(width: 8),
              if (ritual.videoPath != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onWatchVideo,
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: const Text('Vidéo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      foregroundColor: const Color(0xFF4FC3F7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Complete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCompleteRitual,
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('Marquer comme terminé'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onStartRitual,
        icon: const Icon(Icons.play_arrow, size: 20),
        label: const Text('Commencer le rituel'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (ritual.status) {
      case RitualStatus.completed:
        return 'TERMINÉ';
      case RitualStatus.active:
        return 'EN COURS';
      case RitualStatus.overdue:
        return 'EN RETARD';
      case RitualStatus.pending:
        return 'À VENIR';
    }
  }

  String _formatScheduledTime() {
    if (ritual.scheduledTime == null) return '';
    
    final now = DateTime.now();
    final scheduled = ritual.scheduledTime!;
    final difference = scheduled.difference(now);

    if (difference.isNegative) {
      return 'Était prévu à ${_formatTime(scheduled)}';
    } else if (difference.inDays > 0) {
      return 'Dans ${difference.inDays} jour(s) à ${_formatTime(scheduled)}';
    } else if (difference.inHours > 0) {
      return 'Dans ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return 'Dans ${difference.inMinutes} minutes';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
