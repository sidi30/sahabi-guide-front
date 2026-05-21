import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Service voix pour le copilote Hajj : STT (haoussa/français) + TTS.
///
/// - STT : utilise le moteur système Android (Google Speech). Hausa (ha-NG)
///   et Français (fr-FR) supportés si les paquets linguistiques sont installés
///   sur l'appareil.
/// - TTS : flutter_tts, avec fallback FR si la voix haoussa n'est pas dispo
///   (peu de TTS offrent le haoussa ; on parle alors en FR).
class VoiceService {
  final Logger logger;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttInitialized = false;
  bool _ttsInitialized = false;

  /// Callback externe declenche a chaque erreur STT (pour que l'UI affiche
  /// un message a l'utilisateur au lieu d'un echec silencieux).
  void Function(String errorMsg)? onSttError;

  VoiceService({required this.logger});

  /// Initialise STT + TTS. Idempotent.
  Future<void> initialize() async {
    if (!_sttInitialized) {
      try {
        _sttInitialized = await _speech.initialize(
          onError: (e) {
            logger.w('STT error: ${e.errorMsg}');
            onSttError?.call(e.errorMsg);
          },
          onStatus: (s) => logger.d('STT status: $s'),
        );
      } catch (e) {
        logger.w('STT init failed: $e');
        _sttInitialized = false;
        onSttError?.call(e.toString());
      }
    }
    if (!_ttsInitialized) {
      try {
        await _tts.awaitSpeakCompletion(true);
        await _tts.setSpeechRate(0.45);
        await _tts.setPitch(1.0);
        _ttsInitialized = true;
      } catch (e) {
        logger.w('TTS init failed: $e');
      }
    }
  }

  bool get isSttAvailable => _sttInitialized;
  bool get isListening => _speech.isListening;

  /// Locale pour STT selon la langue cible.
  String _sttLocale(String lang) => switch (lang) {
        'ha' => 'ha-NG',
        'ar' => 'ar-SA',
        _ => 'fr-FR',
      };

  /// Locale pour TTS ; retombe sur FR si la langue n'est pas dispo.
  Future<String> _ttsLocale(String lang) async {
    final desired = switch (lang) {
      'ha' => 'ha-NG',
      'ar' => 'ar-SA',
      _ => 'fr-FR',
    };
    try {
      final available = await _tts.isLanguageAvailable(desired);
      if (available == 1 || available == true) return desired;
    } catch (_) {}
    return 'fr-FR';
  }

  /// Démarre une écoute. Retourne la transcription finale via [onResult].
  Future<void> startListening({
    required String lang,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    await initialize();
    if (!_sttInitialized) {
      onResult('', true);
      return;
    }
    await _speech.listen(
      localeId: _sttLocale(lang),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(partialResults: true),
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  Future<void> cancelListening() async {
    if (_speech.isListening) await _speech.cancel();
  }

  /// Lit un texte à voix haute. N'échoue jamais silencieusement.
  Future<void> speak(String text, {String lang = 'fr'}) async {
    await initialize();
    if (!_ttsInitialized) return;
    try {
      final locale = await _ttsLocale(lang);
      await _tts.setLanguage(locale);
      await _tts.stop();
      // Retire les blocs "Texte arabe" / disclaimer pour la lecture (moins de bruit vocal)
      final cleaned = _prepareForSpeech(text);
      await _tts.speak(cleaned);
    } catch (e) {
      logger.w('TTS speak failed: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  String _prepareForSpeech(String text) {
    // Supprime la section "Texte arabe original" pour ne pas mal prononcer
    final cutMarkers = ['— Texte arabe', '— Addu\'o\'i a Larabci', 'ℹ️'];
    String s = text;
    for (final m in cutMarkers) {
      final idx = s.indexOf(m);
      if (idx > 0) s = s.substring(0, idx);
    }
    return s.trim();
  }

  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
  }
}
