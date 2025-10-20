import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/services/position_tracking_service.dart';

/// Indicateur de statut du tracking GPS (petit widget pour la barre d'état)
class TrackingStatusIndicator extends StatefulWidget {
  const TrackingStatusIndicator({super.key});

  @override
  State<TrackingStatusIndicator> createState() => _TrackingStatusIndicatorState();
}

class _TrackingStatusIndicatorState extends State<TrackingStatusIndicator> {
  late final PositionTrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    _trackingService = sl<PositionTrackingService>();
    _trackingService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _trackingService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_trackingService.isTracking) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.gps_fixed,
            size: 14,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            'GPS actif',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


