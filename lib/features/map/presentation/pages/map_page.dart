import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../data/models/makkah_location_model.dart';
import '../../data/datasources/makkah_locations_data_source.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final MakkahLocationsDataSource _locationsDataSource = MakkahLocationsDataSourceImpl();
  List<MakkahLocationModel> _locations = [];
  String _selectedFilter = 'all';
  bool _isSatelliteView = false;
  
  // Map tile URLs
  final String _mapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  final String _satelliteUrl = 'https://mt0.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _loadLocations() {
    setState(() {
      _locations = _selectedFilter == 'all'
          ? _locationsDataSource.getMakkahLocations()
          : _locationsDataSource.getLocationsByType(_selectedFilter);
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
      //     onPressed: () => context.pop(),
      //   ),
      //   title: const Text(
      //     'Pilgrim\'s Map',
      //     style: TextStyle(
      //       color: Color(0xFF1D3557),
      //       fontSize: 20,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: Stack(
        children: [
          // OpenStreetMap Container
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(21.4225, 39.8262), // Masjid al-Haram coordinates
              initialZoom: 12.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatelliteView ? _satelliteUrl : _mapUrl,
                userAgentPackageName: 'com.sahabi.guide',
              ),
              MarkerLayer(
                markers: _locations.map((location) => Marker(
                  width: 40.0,
                  height: 40.0,
                  point: location.coordinates,
                  child: GestureDetector(
                    onTap: () => _showLocationInfo(location),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getMarkerColor(location.type),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getMarkerIcon(location.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
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
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('holy_site', 'Holy Sites'),
                  const SizedBox(width: 8),
                  _buildFilterChip('mosque', 'Mosques'),
                  const SizedBox(width: 8),
                  _buildFilterChip('hospital', 'Hospitals'),
                  const SizedBox(width: 8),
                  _buildFilterChip('hajj_site', 'Hajj Sites'),
                ],
              ),
            ),
          ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                // Map type toggle button
                _buildMapTypeButton(),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.add, () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                }),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove, () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                }),
              ],
            ),
          ),

          // Floating Action Buttons - Positioned individually for better control
          Positioned(
            bottom: 100,
            right: 20,
            child: _buildFloatingActionButton(
              'Urgence',
              Icons.warning_rounded,
              AppColors.error,
              () => _showEmergencyDialog(context),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 100,
            child: _buildFloatingActionButton(
              'Guide',
              Icons.phone_rounded,
              AppColors.accent,
              () => _callGuide(context),
            ),
          ),
        ],
      ),
      //bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _changeFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A9D8F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2A9D8F) : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'mosque':
      case 'holy_site':
        return const Color(0xFF2A9D8F);
      case 'hospital':
        return Colors.red;
      case 'hajj_site':
        return const Color(0xFF457B9D);
      case 'hotel':
        return const Color(0xFFE63946);
      case 'transport':
        return const Color(0xFFF77F00);
      case 'airport':
        return const Color(0xFF6F4E37);
      case 'mountain':
      case 'cave':
        return const Color(0xFF8D5524);
      default:
        return const Color(0xFF1D3557);
    }
  }

  IconData _getMarkerIcon(String type) {
    switch (type) {
      case 'mosque':
      case 'holy_site':
        return Icons.mosque;
      case 'hospital':
        return Icons.local_hospital;
      case 'hajj_site':
        return Icons.place;
      case 'hotel':
        return Icons.hotel;
      case 'transport':
        return Icons.train;
      case 'airport':
        return Icons.flight;
      case 'mountain':
        return Icons.landscape;
      case 'cave':
        return Icons.terrain;
      default:
        return Icons.location_on;
    }
  }

  void _showLocationInfo(MakkahLocationModel location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMarkerColor(location.type),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getMarkerIcon(location.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                      Text(
                        location.nameArabic,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              location.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _mapController.move(location.coordinates, 16.0);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Center on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isSatelliteView ? Icons.map : Icons.satellite_alt,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isSatelliteView = !_isSatelliteView;
          });
        },
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildFloatingActionButton(
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
              color: color.withValues(alpha: 0.4),
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

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Signal d\'Urgence'),
          ],
        ),
        content: const Text(
          'Ceci enverra un signal d\'urgence à votre guide et aux contacts d\'urgence. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Signal d\'urgence envoyé !'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _callGuide(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appel de votre guide...'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

}
