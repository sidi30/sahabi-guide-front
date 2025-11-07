import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';

/// Écran de splash vidéo qui s'affiche au premier lancement
/// Utilise les vidéos disponibles dans assets/video/
class SplashVideoScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashVideoScreen({
    super.key,
    required this.onComplete,
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
    
    widget.onComplete();
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
      backgroundColor: Colors.black,
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
          
          // Bouton Skip en haut à droite
          if (_isInitialized && !_hasError)
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
    // Vidéo en plein écran (couvre tout l'écran)
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo Sahabi pendant le chargement
        Semantics(
          label: AppLocalizations.of(context)!.accessibility_logo,
          child: Image.asset(
            'assets/images/sahabi logo.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.mosque,
                size: 80,
                color: Colors.white,
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          label: AppLocalizations.of(context)!.accessibility_loading,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.splash_loading,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo Sahabi en cas d'erreur
        Image.asset(
          'assets/images/sahabi logo.png',
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.mosque,
              size: 100,
              color: Colors.white,
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


