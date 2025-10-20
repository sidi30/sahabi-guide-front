import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sahabi_guide/core/di/injection_container.dart';
import 'package:sahabi_guide/features/auth/domain/usecases/passport_auth_usecases.dart';
import 'package:sahabi_guide/features/tracking/data/repositories/route_history_repository.dart';
import 'package:sahabi_guide/features/tracking/data/models/position_model.dart';
import 'package:sahabi_guide/features/tracking/data/models/route_statistics_model.dart';
import 'package:intl/intl.dart';

/// Page pour afficher l'historique du parcours
class RouteHistoryPage extends StatefulWidget {
  const RouteHistoryPage({super.key});

  @override
  State<RouteHistoryPage> createState() => _RouteHistoryPageState();
}

class _RouteHistoryPageState extends State<RouteHistoryPage> {
  final RouteHistoryRepository _historyRepository = sl<RouteHistoryRepository>();
  final GetPilgrimProfileUseCase _getPilgrimProfileUseCase = sl<GetPilgrimProfileUseCase>();
  
  String? _userId;
  List<PositionModel> _route = [];
  RouteStatisticsModel? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _endDate = DateTime.now();
  
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      final profile = await _getPilgrimProfileUseCase.call();
      if (profile == null || profile.id == null) {
        setState(() {
          _errorMessage = 'Utilisateur non connecté';
          _isLoading = false;
        });
        return;
      }
      _userId = profile.id;
      await _loadRouteHistory();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur d\'initialisation: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRouteHistory() async {
    if (_userId == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final route = await _historyRepository.getRouteHistory(
        _userId!,
        _startDate,
        _endDate,
      );
      
      final statistics = await _historyRepository.getRouteStatistics(
        _userId!,
        _startDate,
        _endDate,
      );

      setState(() {
        _route = route;
        _statistics = statistics;
        _isLoading = false;
      });

      // Centrer la carte sur le parcours
      if (_route.isNotEmpty) {
        _centerMapOnRoute();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  void _centerMapOnRoute() {
    if (_route.isEmpty) return;

    double minLat = _route.first.lat;
    double maxLat = _route.first.lat;
    double minLng = _route.first.lng;
    double maxLng = _route.first.lng;

    for (var position in _route) {
      if (position.lat < minLat) minLat = position.lat;
      if (position.lat > maxLat) maxLat = position.lat;
      if (position.lng < minLng) minLng = position.lng;
      if (position.lng > maxLng) maxLng = position.lng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadRouteHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique du Parcours'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRouteHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRouteHistory,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Statistiques
                    if (_statistics != null) _buildStatisticsCard(),
                    
                    // Carte
                    Expanded(
                      child: _route.isEmpty
                          ? const Center(
                              child: Text('Aucun parcours pour cette période'),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _route.isNotEmpty
                                    ? LatLng(_route.first.lat, _route.first.lng)
                                    : const LatLng(21.4225, 39.8262),
                                zoom: 14,
                              ),
                              onMapCreated: (c) => _mapController = c,
                              polylines: {
                                if (_route.isNotEmpty)
                                  Polyline(
                                    polylineId: const PolylineId('route'),
                                    points: _route.map((p) => LatLng(p.lat, p.lng)).toList(),
                                    color: Colors.blue,
                                    width: 4,
                                  ),
                              },
                              markers: {
                                if (_route.isNotEmpty)
                                  Marker(
                                    markerId: const MarkerId('start'),
                                    position: LatLng(_route.first.lat, _route.first.lng),
                                  ),
                                if (_route.isNotEmpty)
                                  Marker(
                                    markerId: const MarkerId('end'),
                                    position: LatLng(_route.last.lat, _route.last.lng),
                                  ),
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Période: ${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.straighten,
                  'Distance',
                  _statistics!.totalDistanceFormatted,
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.access_time,
                  'Durée',
                  _statistics!.durationFormatted,
                  Colors.orange,
                ),
                _buildStatItem(
                  Icons.speed,
                  'Vitesse moy.',
                  '${_statistics!.averageSpeedKmh.toStringAsFixed(1)} km/h',
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.location_on,
                  'Points',
                  '${_statistics!.totalPoints}',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}


