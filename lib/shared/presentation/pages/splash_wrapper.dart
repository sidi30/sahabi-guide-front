import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_video_screen.dart';
import 'splash_page.dart';

/// Wrapper qui décide d'afficher la vidéo d'intro ou le splash normal
/// - Au premier lancement : vidéo d'intro
/// - Lancements suivants : splash normal
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool? _shouldShowVideo;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenVideo = prefs.getBool('intro_video_shown') ?? false;
    
    setState(() {
      // Montrer la vidéo seulement si pas encore vue
      _shouldShowVideo = !hasSeenVideo;
    });
  }

  void _onVideoComplete() {
    setState(() {
      _shouldShowVideo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Attendre que la vérification soit terminée
    if (_shouldShowVideo == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Afficher la vidéo ou le splash normal
    if (_shouldShowVideo!) {
      return SplashVideoScreen(
        onComplete: _onVideoComplete,
      );
    } else {
      return const SplashPage();
    }
  }
}






