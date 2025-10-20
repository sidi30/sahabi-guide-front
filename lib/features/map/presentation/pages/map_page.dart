import 'dart:async';
import 'package:flutter/material.dart';
// old: remplacé par Google Maps Flutter
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/services/poi_service.dart';
import '../../data/models/poi_model.dart';

// Mapbox configuration with token from --dart-define (fallback to provided token)
class MapboxConfig {
  static const String _fallbackToken =
      'pk.eyJ1Ijoic2lyMzAiLCJhIjoiY21ncXlvcWltMG81bDJrczRteDVlMXJ2OCJ9.2Rt-_W07GpuPVcQX3tkuUw';

  static const String accessToken = String.fromEnvironment(
    'MAPBOX_TOKEN',
    defaultValue: _fallbackToken,
  );

  static const String styleStreets = 'mapbox/streets-v12';
  static const String styleSatellite = 'mapbox/satellite-v9';
  static const String styleSatelliteStreets = 'mapbox/satellite-streets-v12';

  static bool get isConfigured =>
      accessToken.isNotEmpty && accessToken.startsWith('pk.');

  static String styleUrl(String style,
      {int tileSize = 512, String language = 'fr'}) {
    final size = tileSize >= 512 ? '512' : '256';
    return 'https://api.mapbox.com/styles/v1/$style/tiles/$size/{z}/{x}/{y}@2x?language=$language&access_token=$accessToken';
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  late final PoiService _poiService;
  List<PoiModel> _pois = [];
  List<Marker> _markers = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;
  String? _error;

  // Position par défaut : La Mecque
  static const LatLng _meccaCenter = LatLng(21.4225, 39.8262);
  static const LatLng _medinaCenter = LatLng(24.4672, 39.6142);
  LatLng? _currentPosition;

  // Carte: état d'affichage
  double _currentZoom = 15.0;
  MapMode _mapMode = MapMode.satellite;
  HolyCity _selectedCity = HolyCity.mecca;

  // Suivi automatique de la position
  bool _followUserPosition = true;
  StreamSubscription<Position>? _positionSubscription;

  String _getTileUrl() {
    if (MapboxConfig.isConfigured) {
      switch (_mapMode) {
        case MapMode.satellite:
          return MapboxConfig.styleUrl(MapboxConfig.styleSatelliteStreets);
        case MapMode.normal:
          return MapboxConfig.styleUrl(MapboxConfig.styleStreets);
      }
    }
    // Fallback providers
    switch (_mapMode) {
      case MapMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapMode.normal:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  void initState() {
    super.initState();
    _poiService = sl<PoiService>();
    _initializeMap();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Récupérer la position initiale
      await _getCurrentLocation();
      // Charger les POIs
      await _loadPois();
      // Centrer sur la position actuelle si disponible
      if (_currentPosition != null && _followUserPosition) {
        _mapController.move(_currentPosition!, _currentZoom);
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'initialisation: $e';
        _isLoading = false;
      });
    }
  }

  /// Démarre le suivi en temps réel de la position
  void _startLocationTracking() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mise à jour si déplacement > 10m
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Centrer automatiquement si le mode "suivi" est activé
        if (_followUserPosition) {
          _mapController.move(_currentPosition!, _currentZoom);
        }

        // Mettre à jour les marqueurs pour afficher la position actuelle
        _updateMarkers();
      },
      onError: (error) {
        print('Erreur de suivi position: $error');
      },
    );
  }

  /// Active/désactive le suivi automatique
  void _toggleFollowMode() {
    setState(() {
      _followUserPosition = !_followUserPosition;
    });

    // Si on réactive le suivi, centrer immédiatement
    if (_followUserPosition && _currentPosition != null) {
      _mapController.move(_currentPosition!, _currentZoom);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Erreur de géolocalisation: $e');
      // Utiliser La Mecque comme position par défaut
      setState(() {
        _currentPosition = _meccaCenter;
      });
    }
  }

  Future<void> _loadPois() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final pois = await _poiService.getAllPois();
      setState(() {
        _pois = pois;
        _isLoading = false;
      });

      _updateMarkers();
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des POI: $e';
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    final markers = <Marker>[];

    // Ajouter le marqueur de position actuelle de l'utilisateur (priorité)
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: _currentPosition!,
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.3),
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 40,
            ),
          ),
        ),
      );
    }

    // Ajouter un marqueur pour La Mecque
    markers.add(
      Marker(
        point: _meccaCenter,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    );

    // Ajouter les marqueurs des POI
    for (final poi in _pois) {
      if (_selectedFilter == 'all' || poi.type.name == _selectedFilter) {
        markers.add(
          Marker(
            point: poi.coordinates,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPoiDetails(poi),
              child: Icon(
                Icons.location_on,
                color: _getPoiIconColor(poi.type),
                size: 40,
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  Color _getPoiIconColor(PoiType type) {
    switch (type) {
      case PoiType.hotel:
        return Colors.blue;
      case PoiType.hospital:
        return Colors.red;
      case PoiType.mosque:
        return Colors.green;
      case PoiType.restaurant:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  void _filterPois(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _updateMarkers();
  }

  // --- Carte: interactions ---
  void _toggleMapMode() {
    setState(() {
      _mapMode =
          _mapMode == MapMode.normal ? MapMode.satellite : MapMode.normal;
    });
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(5.0, 18.0);
    });
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(5.0, 18.0);
    });
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _switchCity(HolyCity city) {
    setState(() {
      _selectedCity = city;
    });
    final target = city == HolyCity.mecca ? _meccaCenter : _medinaCenter;
    _mapController.move(target, _currentZoom);
  }

  void _showPoiDetails(PoiModel poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(poi.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${poi.typeLabel}'),
            if (poi.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(poi.description!),
            ],
            if (poi.address?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Adresse: ${poi.address!}'),
            ],
            if (poi.phone?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Téléphone: ${poi.phone!}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _callGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appel Guide'),
        content: const Text(
            'Fonctionnalité d\'appel guide en cours de développement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Urgence'),
        content:
            const Text('Fonctionnalité d\'urgence en cours de développement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Carte'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ma position',
            icon: const Icon(Icons.my_location),
            onPressed: () {
              final target = _currentPosition ??
                  (_selectedCity == HolyCity.mecca
                      ? _meccaCenter
                      : _medinaCenter);
              _mapController.move(target, _currentZoom);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPois,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedCity == HolyCity.mecca
                  ? _meccaCenter
                  : _medinaCenter,
              initialZoom: _currentZoom,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(),
                userAgentPackageName: 'com.example.sahabi_guide',
                tileSize: MapboxConfig.isConfigured ? 512 : 256,
                additionalOptions: MapboxConfig.isConfigured
                    ? const {'id': 'mapbox-tiles'}
                    : const {},
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // Sélecteur de ville (Mecque / Médine)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _switchCity(HolyCity.mecca),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedCity == HolyCity.mecca
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            'La Mecque',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedCity == HolyCity.mecca
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 28,
                      color: Colors.grey.withOpacity(0.3)),
                  Expanded(
                    child: InkWell(
                      onTap: () => _switchCity(HolyCity.medina),
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedCity == HolyCity.medina
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            'Médine',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedCity == HolyCity.medina
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filtres POI
          Positioned(
            top: 72,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPill('Tous', Icons.layers, 'all'),
                  _buildPill('Hôpitaux', Icons.local_hospital, 'hospital'),
                  _buildPill('Mosquées', Icons.mosque, 'mosque'),
                  _buildPill('Restaurants', Icons.restaurant, 'restaurant'),
                  _buildPill('Hôtels', Icons.hotel, 'hotel'),
                ],
              ),
            ),
          ),

          // Boutons d'action
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                // Changer type de carte
                FloatingActionButton(
                  heroTag: 'mapMode',
                  mini: true,
                  onPressed: _toggleMapMode,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _mapMode == MapMode.satellite
                        ? Icons.satellite_alt
                        : Icons.map,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                // Zoom +
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                // Zoom -
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                // Bouton de suivi automatique
                FloatingActionButton(
                  heroTag: 'followMe',
                  mini: true,
                  onPressed: _toggleFollowMode,
                  backgroundColor:
                      _followUserPosition ? Colors.blue : Colors.white,
                  child: Icon(
                    _followUserPosition
                        ? Icons.my_location
                        : Icons.location_searching,
                    color: _followUserPosition ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _callGuide,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _showEmergencyDialog,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.emergency, color: Colors.white),
                ),
              ],
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Message d'erreur
          if (_error != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                        _loadPois();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, IconData icon, String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _filterPois(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18, color: isSelected ? Colors.white : Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MapMode { normal, satellite }

enum HolyCity { mecca, medina }
