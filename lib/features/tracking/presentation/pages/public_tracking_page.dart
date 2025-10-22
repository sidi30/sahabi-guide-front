import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../../core/utils/constants.dart';

/// Page publique pour afficher la position partagée d'un pèlerin
/// Accessible via /public/geo/track/{token}
class PublicTrackingPage extends StatefulWidget {
  final String token;

  const PublicTrackingPage({super.key, required this.token});

  @override
  State<PublicTrackingPage> createState() => _PublicTrackingPageState();
}

class _PublicTrackingPageState extends State<PublicTrackingPage> {
  Map<String, dynamic>? _trackingData;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
    // Rafraîchir toutes les 30 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadTrackingData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTrackingData() async {
    setState(() {
      if (_trackingData == null) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      // Appeler endpoint public
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/public/geo/track/${widget.token}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _trackingData = data;
          _isLoading = false;
        });

        // Centrer la carte sur la nouvelle position
        if (data['latestPosition'] != null) {
          final pos = data['latestPosition'];
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(pos['lat'], pos['lng'])),
          );
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Lien de partage introuvable ou expiré';
          _isLoading = false;
        });
        _refreshTimer?.cancel();
      } else if (response.statusCode == 410) {
        setState(() {
          _errorMessage = 'Ce lien de partage a expiré';
          _isLoading = false;
        });
        _refreshTimer?.cancel();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Suivi en Temps Réel'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _trackingData == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadTrackingData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _buildTrackingView(),
    );
  }

  Widget _buildTrackingView() {
    if (_trackingData == null) return const SizedBox();

    final position = _trackingData!['latestPosition'];
    final userName = _trackingData!['userName'] ?? 'Pèlerin';
    final sharedWithName = _trackingData!['sharedWithName'] ?? 'Famille';
    final expiresAt = DateTime.parse(_trackingData!['expiresAt']);

    return Column(
      children: [
        // Informations
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suivi de $userName',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.share, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Partagé avec: $sharedWithName'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Expire: ${_formatDateTime(expiresAt)}'),
                ],
              ),
              if (position != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.update, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                        'Dernière mise à jour: ${_formatDateTime(DateTime.parse(position['timestamp']))}'),
                  ],
                ),
                if (position['battery'] != null)
                  Row(
                    children: [
                      Icon(
                        Icons.battery_std,
                        size: 16,
                        color: _getBatteryColor(position['battery']),
                      ),
                      const SizedBox(width: 4),
                      Text('Batterie: ${position['battery']}%'),
                    ],
                  ),
              ],
            ],
          ),
        ),

        // Carte
        Expanded(
          child: position == null
              ? const Center(child: Text('Aucune position disponible'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position['lat'], position['lng']),
                    zoom: 15,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: {
                    Marker(
                      markerId: const MarkerId('user'),
                      position: LatLng(position['lat'], position['lng']),
                      infoWindow: InfoWindow(title: userName.split(' ')[0]),
                    ),
                  },
                ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Il y a ${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return '${dt.day}/${dt.month} à ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getBatteryColor(int battery) {
    if (battery > 50) return Colors.green;
    if (battery > 20) return Colors.orange;
    return Colors.red;
  }
}


