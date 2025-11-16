import 'package:flutter/material.dart';
import 'splash_video_screen.dart';

/// Wrapper simplifié - affiche directement la vidéo de splash
/// Plus de page intermédiaire bleue
class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Afficher directement la vidéo de splash
    return const SplashVideoScreen();
  }
}






