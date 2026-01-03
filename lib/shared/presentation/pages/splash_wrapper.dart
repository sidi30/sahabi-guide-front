import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/config/splash_config.dart';
import '../../../shared/services/storage_service.dart';
import 'splash_video_screen.dart';
import 'splash_simple_screen.dart';

/// Wrapper intelligent - vérifie si la vidéo a déjà été vue
/// Affiche la vidéo uniquement au PREMIER lancement
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isChecking = true;
  bool _shouldShowVideo = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenIntro = prefs.getBool('intro_video_shown') ?? false;

      if (!mounted) return;

      if (SplashConfig.debugLogs) {
        debugPrint('🎬 Splash - Première connexion: ${!hasSeenIntro}');
        debugPrint('🎬 Splash - Type configuré: ${SplashConfig.currentType}');
      }

      if (hasSeenIntro) {
        // Intro déjà vue, rediriger directement
        if (SplashConfig.debugLogs) {
          debugPrint('✅ Splash - Intro déjà vue, redirection immédiate');
        }
        await _navigateToNextScreen();
      } else {
        // Première fois, montrer l'intro (vidéo ou simple)
        if (SplashConfig.debugLogs) {
          debugPrint('🎬 Splash - Première connexion détectée, affichage intro');
        }
        setState(() {
          _shouldShowVideo = true;
          _isChecking = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur vérification première connexion: $e');
      // En cas d'erreur, ne pas montrer l'intro
      if (mounted) {
        await _navigateToNextScreen();
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      final storageService = sl<StorageService>();
      final authToken = await storageService.getSecurely('auth_token');

      if (!mounted) return;

      if (authToken == null) {
        context.go('/auth-choice');
      } else {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('❌ Erreur navigation: $e');
      if (mounted) {
        context.go('/auth-choice');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Écran blanc pendant la vérification (très rapide)
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox.shrink(),
        ),
      );
    }

    if (_shouldShowVideo) {
      // Première fois : montrer l'intro (vidéo ou simple selon config)
      switch (SplashConfig.currentType) {
        case SplashType.video:
          return const SplashVideoScreen();
        case SplashType.simple:
          return const SplashSimpleScreen();
      }
    }

    // Ne devrait jamais arriver ici (navigation déjà effectuée)
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}






