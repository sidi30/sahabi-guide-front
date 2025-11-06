import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bot_provider.dart';

/// Widget de debug pour tester le système GPS
/// Permet de visualiser le contexte actuel et les lieux saints
class GpsDebugPanel extends ConsumerWidget {
  const GpsDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextService = ref.watch(contextServiceProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'GPS DEBUG PANEL',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          
          // Lieux saints avec coordonnées
          const Text(
            '📍 Lieux saints disponibles :',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          
          ...contextService.getAllHolyPlaces().map((place) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        place.nameAr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${place.latitude.toStringAsFixed(4)}, Lon: ${place.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Rayon: ${place.radiusKm} km',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          )),
          
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          
          // Instructions
          const Text(
            '🧪 Pour tester :',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '1. Émulateur Android : Extended Controls (⋯) > Location\n'
            '2. Simulateur iOS : Features > Location > Custom Location\n'
            '3. Entrez les coordonnées ci-dessus\n'
            '4. Redémarrez le bot pour voir les changements',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton pour afficher le panel de debug GPS
class GpsDebugButton extends StatelessWidget {
  const GpsDebugButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.my_location, size: 20),
      tooltip: 'Debug GPS',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: const GpsDebugPanel(),
          ),
        );
      },
    );
  }
}

