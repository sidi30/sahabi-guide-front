import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'voice_remote_api.dart';

/// Langues prises en charge par le moteur TTS *embarqué* (flutter_tts) de
/// façon fiable. Pour celles-ci on garde la synthèse on-device.
const Set<String> kOnDeviceVoiceLangs = {'fr', 'ar', 'en'};

/// Langues africaines pour lesquelles l'appareil n'a (presque) jamais de voix
/// TTS : on passe par le microservice backend (SeamlessM4T v2).
const Set<String> kBackendVoiceLangs = {'ha', 'dje', 'yo', 'sw', 'wo', 'bm'};

/// Service voix pour le copilote Hajj : STT + TTS multilingue.
///
/// - TTS langues {fr, ar, en} : flutter_tts (on-device), fiable.
/// - TTS langues africaines {ha, dje, yo, sw, wo, bm} : backend /tts ->
///   octets WAV joués via just_audio. PLUS de repli silencieux en français :
///   si le backend échoue, on log + on notifie via [onTtsError].
/// - STT {fr, ar, en} : speech_to_text on-device.
/// - STT langues africaines : préfère le backend /asr si une locale on-device
///   n'est pas disponible (nécessite l'enregistrement audio — voir TODO).
class VoiceService {
  final Logger logger;

  /// Client backend voix. Optionnel : si absent, le service retombe sur le
  /// comportement on-device uniquement (et signale l'indisponibilité pour les
  /// langues africaines au lieu de parler en français).
  final VoiceRemoteApi? remoteApi;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool _sttInitialized = false;
  bool _ttsInitialized = false;

  /// Callback externe déclenché à chaque erreur STT (pour que l'UI affiche un
  /// message à l'utilisateur au lieu d'un échec silencieux).
  void Function(String errorMsg)? onSttError;

  /// Callback externe déclenché quand la synthèse vocale échoue (par ex. le
  /// backend voix est indisponible pour une langue africaine). Permet à l'UI
  /// de prévenir l'utilisateur plutôt que de rester muet.
  void Function(String errorMsg)? onTtsError;

  VoiceService({required this.logger, this.remoteApi});

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
        // iOS : categorie `playback` + instance partagee, sinon la voix est
        // coupee par l'interrupteur silencieux du telephone.
        if (Platform.isIOS) {
          // `defaultToSpeaker` est INVALIDE avec `playback` (throw natif avale
          // par le plugin -> session inactive -> aucun son). Garder seulement
          // `mixWithOthers`.
          final shared = await _tts.setSharedInstance(true);
          final cat = await _tts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
            IosTextToSpeechAudioMode.defaultMode,
          );
          if (shared != 1 || cat != 1) {
            logger.w('VoiceService iOS audio session NON applique '
                '(shared=$shared, category=$cat)');
          }
        }
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

  /// Locale pour STT selon la langue cible. Renvoie `null` si aucune locale
  /// on-device réelle n'existe pour cette langue (pour ne PAS écouter en
  /// français par erreur sur une langue africaine non gérée).
  String? _sttLocale(String lang) => switch (lang) {
        'ha' => 'ha-NG',
        'ar' => 'ar-SA',
        'en' => 'en-US',
        'fr' => 'fr-FR',
        _ => null,
      };

  /// Locale pour TTS on-device (uniquement pour {fr, ar, en}).
  Future<String> _ttsLocale(String lang) async {
    final desired = switch (lang) {
      'ar' => 'ar-SA',
      'en' => 'en-US',
      _ => 'fr-FR',
    };
    try {
      final available = await _tts.isLanguageAvailable(desired);
      if (available == 1 || available == true) return desired;
    } catch (_) {}
    return 'fr-FR';
  }

  /// Démarre une écoute on-device. Retourne la transcription via [onResult].
  ///
  /// Pour les langues africaines (ha, dje, yo, sw, wo, bm), la reconnaissance
  /// on-device n'est en général PAS disponible. On tente quand même la locale
  /// correspondante ; si rien n'est capté, l'UI peut basculer vers le backend
  /// /asr via [transcribeRemote] une fois l'enregistrement audio implémenté.
  ///
  /// TODO(voice): ajouter un package d'enregistrement (`record`) pour capturer
  /// l'audio et appeler `remoteApi.asr(bytes, lang)` pour les langues
  /// africaines. Aucune dépendance d'enregistrement n'est présente dans
  /// pubspec.yaml aujourd'hui ; on conserve donc le STT on-device et on câble
  /// la méthode [transcribeRemote] pour usage ultérieur.
  Future<void> startListening({
    required String lang,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    await initialize();
    if (!_sttInitialized) {
      onResult('', true);
      return;
    }
    final localeId = _sttLocale(lang);
    // Pas de locale on-device réelle (typiquement une langue africaine servie
    // uniquement par le backend) : on NE capture PAS en français par défaut,
    // on prévient l'utilisateur et on s'arrête.
    if (localeId == null) {
      logger.w(
          'STT: no on-device locale for "$lang" — not falling back to fr-FR');
      onSttError?.call(
          'Reconnaissance vocale indisponible pour cette langue, saisissez votre question.');
      onResult('', true);
      return;
    }
    await _speech.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  Future<void> cancelListening() async {
    if (_speech.isListening) await _speech.cancel();
  }

  /// Transcription distante (backend /asr) à partir d'octets audio déjà
  /// enregistrés. Renvoie le texte ou `null`. Prévu pour les langues africaines
  /// quand l'enregistrement audio sera disponible (voir TODO dans
  /// [startListening]).
  Future<String?> transcribeRemote(Uint8List audioBytes, String lang) async {
    if (remoteApi == null) {
      logger.w('transcribeRemote: no remoteApi configured');
      return null;
    }
    return remoteApi!.asr(audioBytes, lang);
  }

  /// Lit un texte à voix haute. N'échoue jamais silencieusement.
  ///
  /// - {fr, ar, en} -> flutter_tts on-device.
  /// - {ha, dje, yo, sw, wo, bm} -> backend /tts (octets WAV) joués via
  ///   just_audio. Si le backend échoue, on log + on notifie [onTtsError]
  ///   (PLUS de repli silencieux en français).
  Future<void> speak(String text, {String lang = 'fr'}) async {
    await initialize();
    final cleaned = _prepareForSpeech(text);
    if (cleaned.isEmpty) return;

    if (kBackendVoiceLangs.contains(lang)) {
      await _speakBackend(cleaned, lang);
      return;
    }
    await _speakOnDevice(cleaned, lang);
  }

  /// TTS on-device via flutter_tts ({fr, ar, en}).
  Future<void> _speakOnDevice(String cleaned, String lang) async {
    if (!_ttsInitialized) return;
    try {
      final locale = await _ttsLocale(lang);
      await _tts.setLanguage(locale);
      await _tts.stop();
      await _tts.speak(cleaned);
    } catch (e) {
      logger.w('TTS on-device speak failed: $e');
      onTtsError?.call(e.toString());
    }
  }

  /// TTS distant via le backend voix ({ha, dje, yo, sw, wo, bm}).
  Future<void> _speakBackend(String cleaned, String lang) async {
    if (remoteApi == null) {
      final msg = 'Voix « $lang » indisponible (service voix non configuré).';
      logger.w(msg);
      onTtsError?.call(msg);
      return;
    }
    try {
      // Coupe une éventuelle lecture en cours (on-device ou distante).
      await stopSpeaking();
      final bytes = await remoteApi!.tts(cleaned, lang);
      if (bytes == null || bytes.isEmpty) {
        final msg =
            'Synthèse vocale « $lang » indisponible pour le moment (serveur).';
        logger.w(msg);
        onTtsError?.call(msg);
        return;
      }
      await _player.setAudioSource(_BytesAudioSource(bytes));
      await _player.play();
    } catch (e) {
      logger.w('TTS backend speak failed ($lang): $e');
      onTtsError?.call(e.toString());
    }
  }

  /// Speak-to-speak : transforme un audio source en audio cible via /s2s et le
  /// joue. Prévu pour un usage futur (traduction vocale temps quasi réel).
  /// Renvoie `true` si la lecture a démarré.
  Future<bool> speakToSpeak(
    Uint8List audioBytes,
    String src,
    String tgt,
  ) async {
    if (remoteApi == null) {
      logger.w('speakToSpeak: no remoteApi configured');
      onTtsError?.call('Service voix non configuré.');
      return false;
    }
    try {
      await stopSpeaking();
      final bytes = await remoteApi!.s2s(audioBytes, src, tgt);
      if (bytes == null || bytes.isEmpty) {
        onTtsError?.call('Conversion vocale indisponible (serveur).');
        return false;
      }
      await _player.setAudioSource(_BytesAudioSource(bytes));
      await _player.play();
      return true;
    } catch (e) {
      logger.w('speakToSpeak failed: $e');
      onTtsError?.call(e.toString());
      return false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await _player.stop();
    } catch (_) {}
  }

  /// Ne garde que le corps principal à lire à voix haute : on coupe le bloc
  /// arabe original (mal prononcé par une voix non-arabe) et le disclaimer.
  /// Mêmes marqueurs que [BotMessageBubble._splitContent], avec `idx >= 0`
  /// pour aussi couper un marqueur situé en tout début de chaîne.
  String _prepareForSpeech(String text) {
    // Marqueurs de coupe alignés sur le découpage visuel de la bulle :
    //  - bloc arabe original ('— Texte arabe' / "— Addu'o'i a Larabci")
    //  - disclaimer ('ℹ️')
    const cutMarkers = ['— Texte arabe', "— Addu'o'i a Larabci", 'ℹ️'];
    String s = text;
    for (final m in cutMarkers) {
      final idx = s.indexOf(m);
      if (idx >= 0) s = s.substring(0, idx);
    }
    return s.trim();
  }

  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
    try {
      _player.dispose();
    } catch (_) {}
  }
}

/// Source audio just_audio à partir d'octets en mémoire (WAV renvoyé par le
/// backend /tts ou /s2s).
class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;

  _BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(Uint8List.sublistView(_bytes, start, end)),
      contentType: 'audio/wav',
    );
  }
}
