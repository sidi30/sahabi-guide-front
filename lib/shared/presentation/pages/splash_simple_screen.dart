import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../shared/services/storage_service.dart';

/// Alternative SIMPLE au splash vidéo
/// Affiche juste le logo avec animation fade-in
/// Plus stable, plus rapide, sans dépendance vidéo
class SplashSimpleScreen extends StatefulWidget {
  const SplashSimpleScreen({super.key});

  @override
  State<SplashSimpleScreen> createState() => _SplashSimpleScreenState();
}

class _SplashSimpleScreenState extends State<SplashSimpleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation fade-in + scale
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Marquer comme vu et naviguer après 2.5 secondes
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;

      // Marquer que l'intro a été vue
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('intro_video_shown', true);

      if (!mounted) return;

      // Navigation
      final storageService = sl<StorageService>();
      final authToken = await storageService.getSecurely('auth_token');

      if (!mounted) return;

      if (authToken == null) {
        context.go('/auth-choice');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo en haute qualité
                    Image.asset(
                      'assets/images/sahabi_logo_1024.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/sahabi_logo_512.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SahabiGuide',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D3557),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre compagnon pour le Hajj',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF457B9D),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

