import 'package:flutter/material.dart';

import 'sos_button.dart';
import 'sos_status_banner.dart';

/// Couche SOS des écrans principaux : le bouton d'appel au secours et le
/// bandeau d'état du dernier envoi.
///
/// À placer comme enfant direct d'un [Stack] occupant le corps de l'écran
/// (elle renvoie un [Positioned]). Les zones vides ne captent pas les touchers :
/// le contenu dessous (carte, listes) reste utilisable.
class SosOverlay extends StatelessWidget {
  const SosOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: SosStatusBanner()),
          // Bas-gauche : symétrique du bouton assistant (bas-droite) et hors
          // des barres d'action existantes.
          Positioned(left: 16, bottom: 24, child: SosFloatingButton()),
        ],
      ),
    );
  }
}
