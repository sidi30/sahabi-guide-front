import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/services/storage_service.dart';
import 'splash_simple_screen.dart';

/// Écran de splash intelligent avec animation élégante
/// Affiche uniquement lors de la première connexion
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isChecking = true;
  bool _shouldShowSplash = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenIntro = prefs.getBool('intro_shown') ?? false;

      if (!mounted) return;

      if (hasSeenIntro) {
        // Intro déjà vue, rediriger directement
        await _navigateToNextScreen();
      } else {
        // Première fois, montrer l'animation splash
        setState(() {
          _shouldShowSplash = true;
          _isChecking = false;
        });
      }
    } catch (e) {
      AppLogger.error('❌ Erreur vérification première connexion', error: e);
      // En cas d'erreur, rediriger directement
      if (mounted) {
        await _navigateToNextScreen();
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final storageService = sl<StorageService>();
      final authToken = await storageService.getSecurely('auth_token');
      final isVisitor = prefs.getBool('is_visitor') ?? false;

      // Phase pre-Hajj : login desactive. Tout le monde entre en visiteur.
      // - Pelerin auth (cas rare en dev) -> /home avec acces complet
      // - Tout le reste -> visiteur automatique -> /home
      if (authToken == null && !isVisitor) {
        await prefs.setBool('is_visitor', true);
      }
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      AppLogger.error('❌ Erreur navigation', error: e);
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

    if (_shouldShowSplash) {
      // Première fois : montrer l'animation élégante
      return const SplashSimpleScreen();
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






