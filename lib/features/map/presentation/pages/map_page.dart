import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/services/poi_service.dart';
import '../../data/models/poi_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  late final PoiService _poiService;
  List<PoiModel> _pois = [];
  Set<Marker> _markers = {};
  String _selectedFilter = 'all';
  bool _isLoading = true;
  String? _error;

  // Position par défaut : La Mecque
  static const LatLng _meccaCenter = LatLng(21.4225, 39.8262);
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _poiService = sl<PoiService>();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      await _loadPois();
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'initialisation: $e';
        _isLoading = false;
      });
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
    final markers = <Marker>{};

    // Ajouter un marqueur pour La Mecque
    markers.add(
      Marker(
        markerId: const MarkerId('mecca'),
        position: _meccaCenter,
        infoWindow: const InfoWindow(
          title: 'Masjid al-Haram',
          snippet: 'La Grande Mosquée de La Mecque',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Ajouter les marqueurs des POI
    for (final poi in _pois) {
      if (_selectedFilter == 'all' || poi.type.name == _selectedFilter) {
        markers.add(
          Marker(
            markerId: MarkerId(poi.id),
            position: poi.coordinates,
            infoWindow: InfoWindow(
              title: poi.name,
              snippet: poi.description,
            ),
            icon: _getPoiIcon(poi.type),
            onTap: () => _showPoiDetails(poi),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  BitmapDescriptor _getPoiIcon(PoiType type) {
    switch (type) {
      case PoiType.hotel:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case PoiType.hospital:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case PoiType.mosque:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case PoiType.restaurant:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet);
    }
  }

  void _filterPois(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _updateMarkers();
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
              final target = _currentPosition ?? _meccaCenter;
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(target, 15.0),
              );
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
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? _meccaCenter,
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              final target = _currentPosition ?? _meccaCenter;
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(target),
              );
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),

          // Filtres POI
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Tous'),
                    _buildFilterChip('hotel', 'Hôtels'),
                    _buildFilterChip('hospital', 'Hôpitaux'),
                    _buildFilterChip('mosque', 'Mosquées'),
                    _buildFilterChip('restaurant', 'Restaurants'),
                  ],
                ),
              ),
            ),
          ),

          // Boutons d'action
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
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

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _filterPois(filter),
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
