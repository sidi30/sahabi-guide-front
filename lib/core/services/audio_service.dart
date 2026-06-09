import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../shared/models/dua_model.dart';

enum AudioState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class AudioService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioState _state = AudioState.stopped;
  DuaModel? _currentDua;
  String _currentLanguage = 'en';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLooping = false;
  String? _errorMessage;

  // Getters
  AudioState get state => _state;
  DuaModel? get currentDua => _currentDua;
  String get currentLanguage => _currentLanguage;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLooping => _isLooping;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _state == AudioState.playing;
  bool get isPaused => _state == AudioState.paused;
  bool get isLoading => _state == AudioState.loading;

  // Expose streams for direct access
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // Stream subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioService() {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Listen to position changes
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    // Listen to player state changes
    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _state = AudioState.playing;
      } else if (playerState.processingState == ProcessingState.completed) {
        if (_isLooping) {
          _restartAudio();
        } else {
          _state = AudioState.stopped;
          _position = Duration.zero;
        }
      } else if (playerState.processingState == ProcessingState.idle) {
        _state = AudioState.stopped;
      } else {
        _state = AudioState.paused;
      }
      notifyListeners();
    });
  }

  Future<void> playDua(DuaModel dua, {String? language}) async {
    try {
      _state = AudioState.loading;
      _errorMessage = null;
      notifyListeners();

      final selectedLanguage = language ?? _currentLanguage;
      final audioPath = dua.getAudioPath(selectedLanguage);

      if (audioPath.isEmpty) {
        throw Exception(
            'Aucun fichier audio disponible pour la langue $selectedLanguage');
      }

      _currentDua = dua;
      _currentLanguage = selectedLanguage;

      await _setSource(audioPath);
      await _audioPlayer.play();

      // Update play count
      _currentDua = dua.copyWith(
        playCount: dua.playCount + 1,
        lastPlayedAt: DateTime.now(),
      );
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de la lecture: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de la pause: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de la reprise: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Arrête la lecture courante.
  ///
  /// Si [dua] est fourni et qu'une autre doua est en cours de lecture
  /// (cas d'un consommateur disposé alors qu'un autre joue déjà), on ne
  /// touche pas à la lecture en cours. Sinon on arrête et on remet l'état
  /// à [AudioState.stopped] pour que le getter [isPlaying] ne soit pas périmé.
  Future<void> stop([DuaModel? dua]) async {
    // Ne pas couper une lecture démarrée ailleurs.
    if (dua != null && _currentDua != null && _currentDua!.id != dua.id) {
      return;
    }
    try {
      await _audioPlayer.stop();
      _state = AudioState.stopped;
      _position = Duration.zero;
      _currentDua = null;
      notifyListeners();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de l\'arrêt: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> playFromAssets(String assetPath) async {
    try {
      _state = AudioState.loading;
      _errorMessage = null;
      notifyListeners();

      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de la lecture: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors du positionnement: ${e.toString()}';
      notifyListeners();
    }
  }

  // Alias for seekTo
  Future<void> seek(Duration position) async {
    await seekTo(position);
  }

  // Play method for generic audio playback
  Future<void> play([String? audioPath]) async {
    if (audioPath != null) {
      await playFromAssets(audioPath);
    } else {
      await resume();
    }
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = _normalizeLanguage(language);
    notifyListeners();
  }

  Future<void> _restartAudio() async {
    if (_currentDua != null) {
      await playDua(_currentDua!);
    }
  }

  // Format duration for display
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Get progress percentage
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _setSource(String path) async {
    final source = path.trim();
    if (source.startsWith('http')) {
      await _audioPlayer.setUrl(source);
    } else if (source.startsWith('gs://')) {
      final httpsUrl = _convertGsToHttps(source);
      await _audioPlayer.setUrl(httpsUrl);
    } else {
      await _audioPlayer.setAsset(source);
    }
  }

  static String _normalizeLanguage(String? code) {
    if (code == null || code.isEmpty) return 'en';
    final lower = code.toLowerCase();
    if (lower.startsWith('en') || lower.contains('english')) return 'en';
    if (lower.startsWith('fr') || lower.contains('franc')) return 'fr';
    if (lower.startsWith('ar') || lower.contains('arab')) return 'ar';
    if (lower.startsWith('ha') || lower.contains('hausa')) return 'ha';
    if (lower == 'za' ||
        lower == 'zr' ||
        lower == 'dje' ||
        lower.contains('zarma') ||
        lower.contains('djerma')) {
      return 'dje';
    }
    return lower;
  }

  String _convertGsToHttps(String gsPath) {
    final sanitized = gsPath.replaceFirst('gs://', '');
    final parts = sanitized.split('/');
    final bucket = parts.first;
    final objectPath = parts.skip(1).join('/');
    return 'https://storage.googleapis.com/$bucket/$objectPath';
  }
}
