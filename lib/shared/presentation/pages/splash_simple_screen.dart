import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../shared/services/storage_service.dart';

/// Écran de splash avec animation élégante
/// Affiche le logo avec des effets de pulsation et shimmer
class SplashSimpleScreen extends StatefulWidget {
  const SplashSimpleScreen({super.key});

  @override
  State<SplashSimpleScreen> createState() => _SplashSimpleScreenState();
}

class _SplashSimpleScreenState extends State<SplashSimpleScreen>
    with TickerProviderStateMixin {
  // Animation principale (fade + scale)
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Animation de pulsation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Animation de rotation pour le glow
  late AnimationController _glowController;

  // Animation du texte
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // Animation de l'indicateur de chargement
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Animation principale (fade-in + scale)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Animation de pulsation continue
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation de rotation pour l'effet glow
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Animation du texte (apparition décalée)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animation de l'indicateur de chargement
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  void _startAnimationSequence() async {
    // Démarrer l'animation principale
    _mainController.forward();

    // Après 400ms, démarrer la pulsation et le glow
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _pulseController.repeat(reverse: true);
    _glowController.repeat();

    // Après 600ms, afficher le texte
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _textController.forward();

    // Après 300ms, afficher l'indicateur de chargement
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _loadingController.repeat();

    // Attendre 1.6 secondes puis naviguer (durée optimale)
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    await _completeAndNavigate();
  }

  Future<void> _completeAndNavigate() async {
    if (!mounted) return;

    // Marquer que l'intro a été vue
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_shown', true);

    if (!mounted) return;

    debugPrint('✅ Animation splash terminée, navigation...');

    // Navigation vers l'écran approprié
    final storageService = sl<StorageService>();
    final authToken = await storageService.getSecurely('auth_token');
    final isVisitor = prefs.getBool('is_visitor') ?? false;

    // Phase pre-Hajj : login desactive. Tout le monde entre en visiteur.
    if (authToken == null && !isVisitor) {
      await prefs.setBool('is_visitor', true);
    }
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo avec animations
                _buildAnimatedLogo(),
                const SizedBox(height: 32),
                // Texte avec animation
                _buildAnimatedText(),
                const Spacer(flex: 2),
                // Indicateur de chargement
                _buildLoadingIndicator(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _pulseController,
        _glowController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value * _pulseAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Effet de glow rotatif
                _buildGlowEffect(),
                // Logo principal
                _buildLogo(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _glowController.value * 2 * math.pi,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  const Color(0xFF1D3557).withValues(alpha: 0.0),
                  const Color(0xFF457B9D).withValues(alpha: 0.15),
                  const Color(0xFFA8DADC).withValues(alpha: 0.25),
                  const Color(0xFF457B9D).withValues(alpha: 0.15),
                  const Color(0xFF1D3557).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D3557).withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF457B9D).withValues(alpha: 0.08),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            'assets/images/sahabi_logo_1024.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/sahabi_logo_512.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error2, stackTrace2) {
                  // Fallback icon
                  return Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D3557),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: _textSlideAnimation,
            child: Column(
              children: [
                // Titre principal
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF1D3557),
                      Color(0xFF457B9D),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'SahabiGuide',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sous-titre
                const Text(
                  'Votre compagnon pour le Hajj',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF457B9D),
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: SizedBox(
            width: 120,
            child: _AnimatedLoadingDots(
              controller: _loadingController,
            ),
          ),
        );
      },
    );
  }
}

/// Widget d'animation de points de chargement
class _AnimatedLoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedLoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = ((controller.value + delay) % 1.0);
            final scale = 0.5 + (math.sin(value * math.pi) * 0.5);
            final opacity = 0.3 + (math.sin(value * math.pi) * 0.7);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF457B9D).withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
