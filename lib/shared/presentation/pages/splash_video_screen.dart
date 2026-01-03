import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/config/splash_config.dart';
import '../../../shared/services/storage_service.dart';

/// Écran de splash vidéo qui s'affiche au premier lancement
/// Utilise les vidéos disponibles dans assets/video/
class SplashVideoScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const SplashVideoScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Charger la vidéo depuis assets
      // Utilise la mascotte animée
      _controller = VideoPlayerController.asset('assets/video/mascott-anime.mp4');
      
      await _controller.initialize();
      
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
      });
      
      // Démarrer la lecture
      await _controller.play();
      
      // Écouter la fin de la vidéo
      _controller.addListener(_checkVideoProgress);
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement de la vidéo: $e');
      setState(() {
        _hasError = true;
      });
      // Si erreur, attendre 2 secondes puis passer à l'écran suivant
      Future.delayed(const Duration(seconds: 2), _completeIntro);
    }
  }

  void _checkVideoProgress() {
    if (_controller.value.position >= _controller.value.duration) {
      _completeIntro();
    }
  }

  Future<void> _completeIntro() async {
    if (!mounted) return;
    
    // Marquer que la vidéo d'intro a été vue
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_video_shown', true);
    
    // Appeler onComplete si fourni, sinon naviguer directement
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      // Navigation automatique vers auth-choice ou home
      if (mounted) {
        // Vérifier si l'utilisateur est connecté
        final storageService = sl<StorageService>();
        final authToken = await storageService.getSecurely('auth_token');
        
        if (authToken == null) {
          context.go('/auth-choice');
        } else {
          context.go('/home');
        }
      }
    }
  }

  void _skipVideo() {
    _completeIntro();
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Forcer le mode portrait pour la vidéo
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: Colors.white, // Blanc au lieu de noir pour une meilleure transition
      body: Stack(
        children: [
          // Vidéo ou fallback
          Center(
            child: _hasError
                ? _buildErrorFallback()
                : _isInitialized
                    ? _buildVideoPlayer()
                    : _buildLoadingIndicator(),
          ),
          
          // Bouton Skip en haut à droite (si activé dans la config)
          if (_isInitialized && !_hasError && SplashConfig.enableSkipButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: SafeArea(
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(context)!.splash_skip,
                  child: TextButton(
                    onPressed: _skipVideo,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.splash_skip,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Vidéo en plein écran avec aspect ratio correct (évite le flou)
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    // Logo en haute qualité pendant le chargement (évite l'écran noir)
    return Center(
      child: Image.asset(
        'assets/images/sahabi_logo_1024.png',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          // Fallback simple
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo Sahabi en haute résolution (1024x1024 au lieu de 192x192)
        Image.asset(
          'assets/images/sahabi_logo_1024.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high, // Qualité maximale
          errorBuilder: (context, error, stackTrace) {
            // Fallback : essayer la version 512
            return Image.asset(
              'assets/images/sahabi_logo_512.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error2, stackTrace2) {
                // Dernier fallback : icône générique
                return Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D5D4E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 100,
                    color: Colors.white,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Votre compagnon pour le Hajj',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 48),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }
}


