import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'voice_remote_api.dart';

/// Langues pour lesquelles un repli TTS *embarqué* (flutter_tts) existe et est
/// fiable hors-ligne. Sert UNIQUEMENT de filet de secours quand le serveur de
/// voix naturelle est injoignable (offline / timeout). Le Hausa n'en fait PAS
/// partie : aucune voix on-device fiable → si le serveur échoue, on prévient
/// l'utilisateur (voix indisponible hors-ligne) plutôt que de parler en fr.
const Set<String> kOnDeviceFallbackLangs = {'fr', 'ar', 'en'};

/// Langues servies en PRIORITÉ par le microservice voix backend (voix CPU
/// naturelle : Piper pour fr/en/ar, MMS pour ha + langues africaines). On
/// route ces langues vers le serveur ; pour fr/ar/en on retombe sur le TTS
/// on-device si le serveur échoue (voir [kOnDeviceFallbackLangs]).
const Set<String> kServerVoiceLangs = {
  'fr', 'en', 'ar', 'ha', // les 4 langues principales -> voix serveur naturelle
  'dje', 'yo', 'sw', 'wo', 'bm', // langues africaines (serveur uniquement)
};

/// Service voix pour le copilote Hajj : STT + TTS multilingue.
///
/// - TTS : « voix naturelle d'abord ». Toutes les [kServerVoiceLangs]
///   (fr/en/ar/ha + langues africaines) passent par le backend /tts (voix CPU
///   naturelle Piper/MMS) -> octets WAV joués via just_audio. Pour fr/ar/en, si
///   le serveur est injoignable, on retombe sur flutter_tts on-device
///   ([kOnDeviceFallbackLangs]) ; pour le Hausa (pas de voix on-device fiable),
///   on notifie [onTtsError] (« voix indisponible hors-ligne ») au lieu de
///   parler dans la mauvaise langue.
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

  /// Chemin du dernier fichier WAV temporaire écrit pour la lecture serveur.
  /// On le supprime au mieux avant d'en écrire un nouveau et dans [dispose]
  /// pour éviter d'accumuler des fichiers dans le cache temporaire.
  String? _lastTtsTempPath;

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
        // Débit du repli on-device relevé de 0.45 -> 0.52 : un poil plus
        // rapide, moins « robotique ». Le pitch reste neutre (1.0).
        await _tts.setSpeechRate(0.52);
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
  /// Stratégie « voix naturelle d'abord » :
  /// - {fr, en, ar, ha, dje, yo, sw, wo, bm} ([kServerVoiceLangs]) -> on tente
  ///   d'abord le backend /tts (octets WAV, voix CPU naturelle Piper/MMS) joué
  ///   via just_audio.
  /// - Si le serveur échoue/est injoignable ET que la langue a un repli
  ///   on-device fiable ({fr, ar, en} = [kOnDeviceFallbackLangs]), on bascule
  ///   sur flutter_tts (hors-ligne).
  /// - Sinon (ex : Hausa offline), on notifie [onTtsError] (« voix indisponible
  ///   hors-ligne ») au lieu de rester muet ou de parler dans la mauvaise langue.
  Future<void> speak(String text, {String lang = 'fr'}) async {
    await initialize();
    final cleaned = _prepareForSpeech(text);
    if (cleaned.isEmpty) return;

    if (kServerVoiceLangs.contains(lang)) {
      final ok = await _speakBackend(cleaned, lang);
      if (ok) return;
      // Le serveur n'a pas pu jouer la voix naturelle : repli on-device si
      // disponible pour cette langue.
      if (kOnDeviceFallbackLangs.contains(lang)) {
        await _speakOnDevice(cleaned, lang);
      } else {
        // Pas de repli (ex : Hausa) : message clair plutôt que muet.
        onTtsError?.call(
            'Voix indisponible hors-ligne pour cette langue. Réessayez en ligne.');
      }
      return;
    }
    // Langue sans route serveur connue : on tente le on-device.
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

  /// TTS distant via le backend voix (voix naturelle, toutes [kServerVoiceLangs]).
  ///
  /// Retourne `true` si la lecture a démarré, `false` si le serveur est
  /// injoignable / a renvoyé un flux vide. En cas d'échec réseau (octets vides)
  /// on NE notifie PAS [onTtsError] ici : c'est l'appelant ([speak]) qui décide
  /// de retomber sur le TTS on-device ou d'afficher un message d'indisponibilité.
  /// En revanche, si on a bien REÇU des octets mais que la LECTURE plante, on
  /// remonte l'erreur concrète via [onTtsError] pour diagnostic.
  Future<bool> _speakBackend(String cleaned, String lang) async {
    if (remoteApi == null) {
      logger.w('TTS backend: no remoteApi configured for "$lang"');
      return false;
    }
    Uint8List? bytes;
    try {
      // Coupe une éventuelle lecture en cours (on-device ou distante).
      await stopSpeaking();
      bytes = await remoteApi!.tts(cleaned, lang);
    } catch (e) {
      // Échec réseau / serveur -> repli géré par l'appelant.
      logger.w('TTS backend fetch failed ($lang): $e');
      return false;
    }
    if (bytes == null || bytes.isEmpty) {
      logger.w('TTS backend returned empty audio for "$lang"');
      return false;
    }
    logger.d('TTS backend: received ${bytes.length} bytes for "$lang"');
    try {
      await _playWavBytes(bytes);
      return true;
    } catch (e, st) {
      // On a de l'audio valide mais la LECTURE a échoué : c'est exactement le
      // symptôme « son nul, pas d'erreur ». On remonte le message réel pour ne
      // PAS rester silencieux, et on signale à l'appelant que ça a échoué afin
      // qu'il tente le repli on-device si disponible.
      logger.e('TTS backend playback failed ($lang)', error: e, stackTrace: st);
      onTtsError?.call('Lecture audio échouée : $e');
      return false;
    }
  }

  /// Écrit les octets WAV dans un fichier temporaire et les joue via just_audio.
  ///
  /// La lecture en mémoire (`StreamAudioSource`) décode régulièrement en SILENCE
  /// sur iOS pour du WAV PCM16 ; la lecture par fichier est la voie fiable.
  /// On (re)active la session audio juste avant la lecture (iOS peut l'avoir
  /// désactivée après une session STT / une interruption), sinon aucun son ne
  /// sort même avec un fichier valide.
  Future<void> _playWavBytes(Uint8List bytes) async {
    // 1) Réactive la session audio (catégorie playback) juste avant de jouer.
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
    } catch (e) {
      logger.w('AudioSession.setActive(true) failed (continuing): $e');
    }

    // 2) Nettoie le précédent fichier temporaire au mieux.
    await _cleanupLastTtsTemp();

    // 3) Écrit le WAV sur disque.
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    _lastTtsTempPath = path;
    logger.d('TTS playback: wrote ${bytes.length} bytes -> $path');

    // 4) Charge le fichier puis joue. `play()` se résout à la FIN de la lecture.
    await _player.setFilePath(path);
    logger.d('TTS playback: player loaded, duration=${_player.duration}');
    await _player.play();
    logger.d('TTS playback: finished');
  }

  /// Supprime au mieux le dernier fichier WAV temporaire. N'échoue jamais.
  Future<void> _cleanupLastTtsTemp() async {
    final path = _lastTtsTempPath;
    if (path == null) return;
    _lastTtsTempPath = null;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Best-effort : ignore (fichier verrouillé, déjà supprimé, etc.).
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
      await _playWavBytes(bytes);
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
    // Retire les emojis / icônes (🕋 💡 📿 ✅ ℹ️ …) pour que la voix ne les
    // prononce PAS ("ampoule", "kaaba"...). On vise les blocs Unicode emoji,
    // symboles divers, dingbats, drapeaux et sélecteurs de variation.
    final emoji = RegExp(
      r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2300}-\u{23FF}\u{2B00}-\u{2BFF}\u{2190}-\u{21FF}\u{1F1E6}-\u{1F1FF}\u{FE00}-\u{FE0F}\u{2139}\u{20E3}\u{200D}]',
      unicode: true,
    );
    s = s.replaceAll(emoji, '');
    // Recompacte les espaces laissés par les icônes retirées.
    s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    return s.trim();
  }

  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
    try {
      _player.dispose();
    } catch (_) {}
    // Nettoyage best-effort du dernier fichier WAV temporaire.
    unawaited(_cleanupLastTtsTemp());
  }
}
