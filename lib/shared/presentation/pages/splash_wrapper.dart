import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_video_screen.dart';
import 'splash_page.dart';

/// Wrapper qui décide d'afficher la vidéo d'intro ou le splash normal
/// OPTIMISÉ : Affichage instantané du splash, vidéo optionnelle
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _shouldShowVideo = false;

  @override
  void initState() {
    super.initState();
    // Vérifier en arrière-plan (non bloquant)
    _checkFirstLaunchAsync();
  }

  Future<void> _checkFirstLaunchAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenVideo = prefs.getBool('intro_video_shown') ?? false;
      
      // Montrer la vidéo seulement au TOUT PREMIER lancement
      // Les lancements suivants vont directement au splash page
      if (!hasSeenVideo && mounted) {
        setState(() {
          _shouldShowVideo = true;
        });
      }
    } catch (e) {
      // En cas d'erreur, ne pas bloquer, continuer sans vidéo
      debugPrint('Erreur vérification vidéo intro: $e');
    }
  }

  void _onVideoComplete() {
    if (mounted) {
      setState(() {
        _shouldShowVideo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMISATION : Afficher immédiatement le splash, 
    // pas de loading inutile
    if (_shouldShowVideo) {
      return SplashVideoScreen(
        onComplete: _onVideoComplete,
      );
    }
    
    // Par défaut : splash page rapide
    return const SplashPage();
  }
}






