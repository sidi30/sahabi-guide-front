import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/bot/data/services/voice_remote_api.dart';
import '../utils/app_logger.dart';

/// État de lecture vocale exposé à l'UI.
enum TtsState { idle, loading, speaking, error }

/// Service de synthèse vocale (text-to-speech) réutilisable pour lire à voix
/// haute les douas, l'explication des rituels et les réponses de l'assistant.
///
/// Deux moteurs :
///  - {fr, ar, en} : [FlutterTts] **on-device** (fiable, hors-ligne).
///  - {ha, dje, yo, sw, wo, bm} : microservice voix backend (SeamlessM4T) via
///    [VoiceRemoteApi]. Renvoie des octets WAV joués par [just_audio]. Si le
///    backend est indisponible, on bascule sur la voix arabe on-device pour le
///    texte arabe (les douas restent audibles) et on signale via [onError].
///
/// Contrairement aux mp3 pré-enregistrés (absents du bundle), le TTS garantit
/// qu'une doua / explication est TOUJOURS lisible au moins en fr/ar/en.
class TtsService extends ChangeNotifier {
  TtsService({this.remoteApi});

  /// Optionnel : client backend voix pour les langues africaines.
  final VoiceRemoteApi? remoteApi;

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  TtsState _state = TtsState.idle;
  String? _errorMessage;

  /// Identifiant logique du contenu en cours de lecture (ex: id de la doua /
  /// du rituel). Permet à l'UI de savoir QUEL élément parle.
  String? _currentTag;

  TtsState get state => _state;
  bool get isSpeaking => _state == TtsState.speaking || _state == TtsState.loading;
  String? get errorMessage => _errorMessage;
  String? get currentTag => _currentTag;

  /// Langues africaines servies par le backend voix.
  static const Set<String> backendLangs = {'ha', 'dje', 'yo', 'sw', 'wo', 'bm'};

  /// Callback UI déclenché à chaque échec (jamais d'échec silencieux).
  void Function(String message)? onError;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    try {
      // iOS : sans session audio en categorie `playback`, AVSpeechSynthesizer
      // joue sous la categorie par defaut (ambient) que l'interrupteur
      // silencieux du telephone COUPE -> aucun son. On force playback +
      // partage de l'instance pour parler meme en mode silencieux.
      if (Platform.isIOS) {
        // ATTENTION : ne PAS mettre `defaultToSpeaker` ici — cette option n'est
        // valide qu'avec `playAndRecord` ; combinee a `playback` elle fait
        // ECHOUER setCategory cote natif (le plugin avale l'erreur) -> la
        // session reste inactive -> AUCUN son (toute l'app). On garde donc
        // seulement `mixWithOthers`.
        final shared = await _tts.setSharedInstance(true);
        final cat = await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
          IosTextToSpeechAudioMode.defaultMode,
        );
        if (shared != 1 || cat != 1) {
          AppLogger.debug('TtsService iOS audio session NON applique '
              '(shared=$shared, category=$cat)');
        }
      }
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _tts.setCompletionHandler(() {
        _setState(TtsState.idle);
        _currentTag = null;
      });
      _tts.setCancelHandler(() {
        _setState(TtsState.idle);
        _currentTag = null;
      });
      _tts.setErrorHandler((msg) {
        _errorMessage = msg?.toString();
        _setState(TtsState.error);
        onError?.call(_errorMessage ?? 'Erreur de synthèse vocale');
        _currentTag = null;
      });
      _player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          _setState(TtsState.idle);
          _currentTag = null;
        }
      });
      _initialized = true;
    } catch (e) {
      AppLogger.error('TtsService init failed', error: e);
    }
  }

  void _setState(TtsState s) {
    _state = s;
    notifyListeners();
  }

  /// Locale on-device pour une langue donnée, avec repli fr-FR.
  Future<String> _onDeviceLocale(String lang) async {
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

  /// Lit [text] à voix haute dans la langue [lang] (code canonique fr/ar/en/
  /// ha/dje/...). [tag] identifie l'élément lu pour l'UI.
  /// [gender] ('MALE'/'FEMALE') choisit une voix homme/femme quand la plateforme
  /// l'expose, et ajuste le timbre (pitch) pour une distinction fiable partout.
  Future<void> speak(String text,
      {required String lang, String? tag, String? gender}) async {
    await _ensureInit();
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    await stop();
    _currentTag = tag;
    _errorMessage = null;

    if (backendLangs.contains(lang)) {
      await _speakBackend(cleaned, lang);
      return;
    }
    await _speakOnDevice(cleaned, lang, gender: gender);
  }

  Future<void> _speakOnDevice(String text, String lang, {String? gender}) async {
    try {
      _setState(TtsState.speaking);
      final locale = await _onDeviceLocale(lang);
      await _tts.setLanguage(locale);
      await _applyGenderVoice(locale, gender);
      await _tts.speak(text);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TtsState.error);
      onError?.call('Lecture vocale impossible: $e');
    }
  }

  /// Sélectionne une voix homme/femme de meilleure qualité pour [locale] et règle
  /// le timbre. Le pitch garantit une voix clairement masculine/féminine même
  /// quand la plateforme n'étiquette pas le genre des voix. Une voix « enhanced /
  /// premium / neural / network » est préférée pour un rendu moins robotique.
  Future<void> _applyGenderVoice(String locale, String? gender) async {
    final wantFemale = gender == 'FEMALE';
    final wantMale = gender == 'MALE';
    // 1) Timbre : garantie cross-plateforme d'une voix H/F distincte.
    //    Femme = plus aigu, homme = plus grave, neutre = 1.0.
    try {
      await _tts.setPitch(wantFemale ? 1.18 : (wantMale ? 0.88 : 1.0));
    } catch (_) {}
    if (gender == null) return;

    // 2) Voix : si la plateforme liste des voix, choisir la meilleure du bon
    //    genre (champ 'gender' quand présent) et de meilleure qualité.
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      final langPrefix = locale.split('-').first.toLowerCase();
      final candidates = voices
          .whereType<Map>()
          .where((v) => (v['locale'] ?? '')
              .toString()
              .toLowerCase()
              .startsWith(langPrefix))
          .toList();
      if (candidates.isEmpty) return;

      Map? best;
      int bestScore = -1;
      for (final v in candidates) {
        final name = (v['name'] ?? '').toString().toLowerCase();
        final g = (v['gender'] ?? '').toString().toLowerCase();
        int score = 0;
        final wantG = wantFemale ? 'female' : 'male';
        if (g == wantG) {
          score += 5; // genre confirmé par la plateforme
        } else if (g.isNotEmpty) {
          continue; // genre connu mais opposé -> écarter
        }
        // qualité (moins robotique)
        if (name.contains('enhanced') ||
            name.contains('premium') ||
            name.contains('neural') ||
            name.contains('network')) {
          score += 3;
        } else if (name.contains('local')) {
          score += 1;
        }
        if (score > bestScore) {
          best = v;
          bestScore = score;
        }
      }
      if (best != null && bestScore >= 0) {
        await _tts.setVoice({
          'name': best['name'].toString(),
          'locale': best['locale'].toString(),
        });
      }
    } catch (_) {
      // getVoices/setVoice non supporté -> le pitch suffit à distinguer H/F.
    }
  }

  /// TTS distant (langues africaines). [arabicFallback] permet, si le backend
  /// échoue, de lire au moins le texte arabe original avec la voix arabe
  /// on-device plutôt que de rester muet.
  Future<void> _speakBackend(String text, String lang,
      {String? arabicFallback}) async {
    if (remoteApi == null) {
      _failBackend(lang, arabicFallback);
      return;
    }
    try {
      _setState(TtsState.loading);
      final bytes = await remoteApi!.tts(text, lang);
      if (bytes == null || bytes.isEmpty) {
        await _failBackend(lang, arabicFallback);
        return;
      }
      await _player.setAudioSource(_BytesAudioSource(bytes));
      _setState(TtsState.speaking);
      await _player.play();
    } catch (e) {
      await _failBackend(lang, arabicFallback, error: e.toString());
    }
  }

  Future<void> _failBackend(String lang, String? arabicFallback,
      {String? error}) async {
    final msg = error ??
        'Voix « $lang » indisponible pour le moment (service vocal hors ligne).';
    _errorMessage = msg;
    onError?.call(msg);
    // Repli : lire le texte arabe avec la voix arabe on-device si fourni.
    if (arabicFallback != null && arabicFallback.trim().isNotEmpty) {
      await _speakOnDevice(arabicFallback, 'ar');
    } else {
      _setState(TtsState.error);
    }
  }

  /// Lit une doua : choisit la meilleure source de texte selon la langue.
  /// - langue arabe : lit le texte arabe.
  /// - autre langue on-device : lit la traduction dans cette langue (à défaut
  ///   la translittération, à défaut l'arabe).
  /// - langue africaine : envoie la traduction au backend, repli arabe.
  Future<void> speakDua({
    required String lang,
    required String arabicText,
    String? translation,
    String? transliteration,
    String? tag,
  }) async {
    await _ensureInit();
    await stop();
    _currentTag = tag;
    _errorMessage = null;

    if (backendLangs.contains(lang)) {
      final body = (translation != null && translation.trim().isNotEmpty)
          ? translation
          : (transliteration ?? arabicText);
      await _speakBackend(body, lang, arabicFallback: arabicText);
      return;
    }

    final String body;
    if (lang == 'ar') {
      body = arabicText;
    } else if (translation != null && translation.trim().isNotEmpty) {
      body = translation;
    } else if (transliteration != null && transliteration.trim().isNotEmpty) {
      body = transliteration;
    } else {
      body = arabicText;
    }
    await _speakOnDevice(body, lang);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await _player.stop();
    } catch (_) {}
    _setState(TtsState.idle);
    _currentTag = null;
  }

  @override
  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
    _player.dispose();
    super.dispose();
  }
}

/// Source audio just_audio à partir d'octets WAV en mémoire (backend /tts).
class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this._bytes);

  final Uint8List _bytes;

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
