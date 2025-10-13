import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/poi_model.dart';
import '../../data/services/poi_service.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;
  final PoiService _poiService = PoiService(
    dioClient: GetIt.I<DioClient>(),
    secureStorage: GetIt.I<FlutterSecureStorage>(),
  );
  
  // Map state
  Set<Marker> _markers = {};
  List<PoiModel> _filteredPois = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;
  String? _error;
  Position? _currentPosition;
  
  // Map configuration
  static const LatLng _defaultLocation = LatLng(21.4225, 39.8262); // Masjid al-Haram
  static const double _defaultZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      await _loadPois();
    } catch (e) {
      setState(() {
        _error = 'Erreur d\'initialisation: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Les services de localisation sont désactivés');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée définitivement');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Erreur de géolocalisation: $e');
      // Continue without current location
    }
  }

  Future<void> _loadPois() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<PoiModel> pois;
      if (_selectedFilter == 'all') {
        pois = await _poiService.getAllPois();
      } else {
        pois = await _poiService.getPoisByType(_selectedFilter);
      }

      setState(() {
        _filteredPois = pois;
        _isLoading = false;
      });

      await _updateMarkers();
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement des POI: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMarkers() async {
    final Set<Marker> markers = {};

    // Add current position marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Ma position',
            snippet: 'Vous êtes ici',
          ),
        ),
      );
    }

    // Add POI markers
    for (final poi in _filteredPois) {
      final BitmapDescriptor icon = await _getMarkerIcon(poi.type);
      
      markers.add(
        Marker(
          markerId: MarkerId(poi.id),
          position: poi.coordinates,
          icon: icon,
          infoWindow: InfoWindow(
            title: poi.name,
            snippet: poi.description ?? poi.typeLabel,
            onTap: () => _showPoiDetails(poi),
          ),
          onTap: () => _showPoiDetails(poi),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<BitmapDescriptor> _getMarkerIcon(PoiType type) async {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case PoiType.hospital:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case PoiType.hotel:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case PoiType.restaurant:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case PoiType.hajjSite:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case PoiType.transport:
      case PoiType.airport:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Apply custom map style if needed
    //_mapController?.setMapStyle(_mapStyle);
    
    // Move to current location or default
    final LatLng target = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultLocation;
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, _defaultZoom),
    );
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadPois();
  }

  void _showPoiDetails(PoiModel poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPoiDetailsSheet(poi),
    );
  }

  Widget _buildPoiDetailsSheet(PoiModel poi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getPoiColor(poi.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPoiIcon(poi.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      poi.typeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Description
          if (poi.description != null && poi.description!.isNotEmpty) ...[
            Text(
              poi.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Contact info
          if (poi.phone != null) ...[
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  poi.phone!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          if (poi.address != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    poi.address!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(poi.coordinates, 16.0),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Centrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Fermer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color _getPoiColor(PoiType type) {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return AppColors.primary;
      case PoiType.hospital:
        return AppColors.error;
      case PoiType.hotel:
        return AppColors.secondary;
      case PoiType.restaurant:
        return const Color(0xFFF77F00);
      case PoiType.hajjSite:
        return AppColors.accent;
      case PoiType.transport:
      case PoiType.airport:
        return const Color(0xFF6F4E37);
      default:
        return AppColors.textSecondary;
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
        return Icons.train;
      case PoiType.airport:
        return Icons.flight;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultLocation,
              zoom: _defaultZoom,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true,
            mapType: MapType.normal,
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),

          // Error overlay
          if (_error != null)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _error = null;
                            });
                            _loadPois();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Réessayer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Filter buttons at top
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tous', Icons.all_inclusive),
                  const SizedBox(width: 8),
                  _buildFilterChip('mosque', 'Mosquées', Icons.mosque),
                  const SizedBox(width: 8),
                  _buildFilterChip('hospital', 'Hôpitaux', Icons.local_hospital),
                  const SizedBox(width: 8),
                  _buildFilterChip('hotel', 'Hôtels', Icons.hotel),
                  const SizedBox(width: 8),
                  _buildFilterChip('restaurant', 'Restaurants', Icons.restaurant),
                  const SizedBox(width: 8),
                  _buildFilterChip('hajjSite', 'Sites Hajj', Icons.place),
                ],
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: () async {
                await _getCurrentLocation();
                if (_currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      16.0,
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // Emergency button
          Positioned(
            bottom: 100,
            right: 20,
            child: _buildActionButton(
              'Urgence',
              Icons.warning_rounded,
              AppColors.error,
              _sendEmergencySignal,
            ),
          ),

          // Call guide button
          Positioned(
            bottom: 100,
            right: 100,
            child: _buildActionButton(
              'Guide',
              Icons.phone_rounded,
              AppColors.accent,
              _callGuide,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _changeFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
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
              size: 18,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callGuide() async {
    try {
      await _poiService.callGuide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Guide appelé avec succès'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _sendEmergencySignal() async {
    // Show confirmation dialog first
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Signal d\'Urgence'),
          ],
        ),
        content: const Text(
          'Ceci enverra un signal d\'urgence à votre guide et aux contacts d\'urgence. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _poiService.triggerEmergency();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signal d\'urgence envoyé !'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}