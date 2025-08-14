import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(21.3891, 39.8579), // Coordonnées de la Mecque
    zoom: 14,
  );

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('kaaba'),
      position: LatLng(21.4225, 39.8262), // Kaaba
      infoWindow: InfoWindow(title: 'Al-Masjid al-Haram'),
    ),
    const Marker(
      markerId: MarkerId('arafat'),
      position: LatLng(21.3642, 39.9668), // Mont Arafat
      infoWindow: InfoWindow(title: 'Mont Arafat'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Lieux Saints'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D3557)),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Centrer sur la position actuelle de l'utilisateur
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Centrage sur votre position...')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'emergency',
                  onPressed: () {
                    // TODO: Implémenter l'appel d'urgence
                    _showEmergencyOptions(context);
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.emergency, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'current_location',
                  onPressed: () {
                    // TODO: Centrer sur la position actuelle
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Color(0xFF1D3557)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Options d\'urgence',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildEmergencyButton(
              context,
              'Appeler les secours',
              Icons.emergency,
              Colors.red,
              () {
                // TODO: Implémenter l'appel d'urgence
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appel d\'urgence effectué')),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildEmergencyButton(
              context,
              'Trouver l\'hôpital le plus proche',
              Icons.local_hospital,
              const Color(0xFF1D3557),
              () {
                // TODO: Afficher les hôpitaux proches
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recherche d\'hôpitaux à proximité...')),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildEmergencyButton(
              context,
              'Contacter l\'ambassade',
              Icons.contact_phone,
              const Color(0xFF2A9D8F),
              () {
                // TODO: Afficher les contacts de l'ambassade
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ouverture des contacts de l\'ambassade...')),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
