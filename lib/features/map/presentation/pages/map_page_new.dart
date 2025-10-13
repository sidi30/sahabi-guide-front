import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/poi_model.dart';
import '../../data/services/poi_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final PoiService _poiService = sl<PoiService>();
  
  // State variables
  List<PoiModel> _allPois = [];
  List<PoiModel> _filteredPois = [];
  Set<Marker> _markers = {};
  PoiType? _selectedFilter;
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;
  MapType _mapType = MapType.normal;

  // Makkah center coordinates (default)
  static const LatLng _makkahCenter = LatLng(21.4225, 39.8262);
  static const CameraPosition _initialPosition = CameraPosition(
    target: _makkahCenter,
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadPois();
  }

  /// Récupère la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Service de localisation désactivé';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Permission de localisation refusée';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée définitivement';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Centrer la carte sur la position actuelle
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de localisation: $e';
      });
    }
  }

  /// Charge les POI depuis le backend
  Future<void> _loadPois() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pois = await _poiService.getAllPois();
      setState(() {
        _allPois = pois;
        _filteredPois = pois;
        _isLoading = false;
      });
      _updateMarkers();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de chargement des POI: $e';
      });
    }
  }

  /// Filtre les POI par type
  void _filterPois(PoiType? type) {
    setState(() {
      _selectedFilter = type;
      _filteredPois = type == null
          ? _allPois
          : _allPois.where((poi) => poi.type == type).toList();
    });
    _updateMarkers();
  }

  /// Met à jour les marqueurs sur la carte
  void _updateMarkers() {
    final Set<Marker> markers = {};

    for (var poi in _filteredPois) {
      markers.add(
        Marker(
          markerId: MarkerId(poi.id),
          position: poi.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(poi.type)),
          infoWindow: InfoWindow(
            title: poi.name,
            snippet: poi.description ?? poi.typeLabel,
            onTap: () => _showPoiDetails(poi),
          ),
        ),
      );
    }

    // Ajouter le marqueur de position actuelle si disponible
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Ma position'),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  /// Retourne la couleur du marqueur selon le type de POI
  double _getMarkerColor(PoiType type) {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return BitmapDescriptor.hueGreen;
      case PoiType.hospital:
        return BitmapDescriptor.hueRed;
      case PoiType.hotel:
        return BitmapDescriptor.hueOrange;
      case PoiType.restaurant:
        return BitmapDescriptor.hueYellow;
      case PoiType.hajjSite:
        return BitmapDescriptor.hueBlue;
      case PoiType.transport:
        return BitmapDescriptor.hueCyan;
      case PoiType.airport:
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRose;
    }
  }

  /// Affiche les détails d'un POI
  void _showPoiDetails(PoiModel poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // POI icon and type
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getPoiColor(poi.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPoiIcon(poi.type),
                        color: _getPoiColor(poi.type),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poi.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            poi.typeLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (poi.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    poi.description!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                
                if (poi.address != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          poi.address!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (poi.phone != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        poi.phone!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implémenter navigation vers POI
                          Navigator.pop(context);
                          _showSnackBar('Navigation vers ${poi.name}');
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Itinéraire'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (poi.phone != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSnackBar('Appel ${poi.phone}');
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Appeler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPoiColor(PoiType type) {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return const Color(0xFF2A9D8F);
      case PoiType.hospital:
        return Colors.red;
      case PoiType.hotel:
        return const Color(0xFFE63946);
      case PoiType.restaurant:
        return const Color(0xFFF77F00);
      case PoiType.hajjSite:
        return const Color(0xFF457B9D);
      case PoiType.transport:
        return const Color(0xFF06AED5);
      case PoiType.airport:
        return const Color(0xFF6F4E37);
      default:
        return const Color(0xFF1D3557);
    }
  }

  IconData _getPoiIcon(PoiType type) {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return Icons.mosque;
      case PoiType.hospital:
        return Icons.local_hospital;
      case PoiType.hotel:
        return Icons.hotel;
      case PoiType.restaurant:
        return Icons.restaurant;
      case PoiType.hajjSite:
        return Icons.place;
      case PoiType.transport:
        return Icons.directions_bus;
      case PoiType.airport:
        return Icons.flight;
      default:
        return Icons.location_on;
    }
  }

  /// Appelle le guide via le backend
  Future<void> _callGuide() async {
    try {
      await _poiService.callGuide();
      _showSnackBar('Guide appelé avec succès', isError: false);
    } catch (e) {
      _showSnackBar('Erreur lors de l\'appel du guide: $e', isError: true);
    }
  }

  /// Déclenche une urgence via le backend
  Future<void> _triggerEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Urgence'),
        content: const Text('Voulez-vous vraiment déclencher une alerte d\'urgence ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _poiService.triggerEmergency();
        _showSnackBar('Urgence déclenchée avec succès', isError: false);
      } catch (e) {
        _showSnackBar('Erreur lors du déclenchement d\'urgence: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: _mapType,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Filter chips
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(null, 'Tous', Icons.map),
                  const SizedBox(width: 8),
                  _buildFilterChip(PoiType.mosque, 'Mosquées', Icons.mosque),
                  const SizedBox(width: 8),
                  _buildFilterChip(PoiType.hospital, 'Hôpitaux', Icons.local_hospital),
                  const SizedBox(width: 8),
                  _buildFilterChip(PoiType.hotel, 'Hôtels', Icons.hotel),
                  const SizedBox(width: 8),
                  _buildFilterChip(PoiType.restaurant, 'Restaurants', Icons.restaurant),
                  const SizedBox(width: 8),
                  _buildFilterChip(PoiType.hajjSite, 'Sites Hajj', Icons.place),
                ],
              ),
            ),
          ),

          // Map controls (zoom, map type, location)
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                // Map type toggle
                FloatingActionButton.small(
                  heroTag: 'mapType',
                  onPressed: () {
                    setState(() {
                      _mapType = _mapType == MapType.normal
                          ? MapType.satellite
                          : MapType.normal;
                    });
                  },
                  backgroundColor: Colors.white,
                  child: Icon(
                    _mapType == MapType.normal ? Icons.satellite : Icons.map,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                
                // My location button
                FloatingActionButton.small(
                  heroTag: 'myLocation',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                
                // Zoom in
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  onPressed: () async {
                    final controller = await _mapController.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                
                // Zoom out
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  onPressed: () async {
                    final controller = await _mapController.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Action buttons (Guide & Urgence)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Guide
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _callGuide,
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Appel Guide'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Bouton Urgence
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _triggerEmergency,
                    icon: const Icon(Icons.warning_rounded),
                    label: const Text('Urgence'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildFilterChip(PoiType? type, String label, IconData icon) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () => _filterPois(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

