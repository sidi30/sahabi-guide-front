import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/services/position_tracking_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Widget de contrôle du tracking GPS
/// Permet de démarrer/arrêter le suivi automatique de position
class TrackingControlWidget extends StatefulWidget {
  const TrackingControlWidget({super.key});

  @override
  State<TrackingControlWidget> createState() => _TrackingControlWidgetState();
}

class _TrackingControlWidgetState extends State<TrackingControlWidget> {
  late final PositionTrackingService _trackingService;
  late final FlutterSecureStorage _secureStorage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _trackingService = sl<PositionTrackingService>();
    _secureStorage = sl<FlutterSecureStorage>();
    _trackingService.addListener(_onTrackingUpdate);
    _initializeTracking();
  }

  @override
  void dispose() {
    _trackingService.removeListener(_onTrackingUpdate);
    super.dispose();
  }

  void _onTrackingUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeTracking() async {
    // Récupérer l'userId depuis le stockage sécurisé
    final userId = await _secureStorage.read(key: 'userId');
    
    setState(() {
      _isInitialized = true;
    });

    // Démarrer automatiquement le tracking si un userId est disponible
    if (userId != null && !_trackingService.isTracking) {
      await _startTracking();
    }
  }

  Future<void> _startTracking() async {
    final userId = await _secureStorage.read(key: 'userId');
    
    if (userId == null) {
      _showSnackBar('Impossible de démarrer le tracking: utilisateur non connecté', isError: true);
      return;
    }

    try {
      await _trackingService.startTracking(userId);
      _showSnackBar('📍 Tracking GPS démarré !');
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    }
  }

  void _stopTracking() {
    _trackingService.stopTracking();
    _showSnackBar('🛑 Tracking GPS arrêté');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _trackingService.isTracking ? Icons.gps_fixed : Icons.gps_off,
                  color: _trackingService.isTracking ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking GPS',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _trackingService.isTracking 
                            ? 'Position partagée toutes les ${_trackingService.interval.inMinutes} min'
                            : 'Désactivé',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _trackingService.isTracking,
                  onChanged: (value) {
                    if (value) {
                      _startTracking();
                    } else {
                      _stopTracking();
                    }
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            
            if (_trackingService.isTracking) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.access_time,
                'Dernière mise à jour',
                _trackingService.lastSentTime != null
                    ? _formatTime(_trackingService.lastSentTime!)
                    : 'En attente...',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.check_circle,
                'Envois réussis',
                '${_trackingService.successCount}',
                color: Colors.green,
              ),
              if (_trackingService.errorCount > 0) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.error,
                  'Erreurs',
                  '${_trackingService.errorCount}',
                  color: Colors.red,
                ),
              ],
              if (_trackingService.lastError != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _trackingService.lastError!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'Il y a ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else {
      return 'Il y a ${difference.inHours}h';
    }
  }
}

