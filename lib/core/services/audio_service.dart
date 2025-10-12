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
  String _currentLanguage = 'fr';
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

  // Stream subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioService() {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((playerState) {
      switch (playerState) {
        case PlayerState.playing:
          _state = AudioState.playing;
          break;
        case PlayerState.paused:
          _state = AudioState.paused;
          break;
        case PlayerState.stopped:
          _state = AudioState.stopped;
          break;
        case PlayerState.completed:
          if (_isLooping) {
            _restartAudio();
          } else {
            _state = AudioState.stopped;
            _position = Duration.zero;
          }
          break;
        case PlayerState.disposed:
          _state = AudioState.stopped;
          break;
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
        throw Exception('Aucun fichier audio disponible pour la langue $selectedLanguage');
      }

      _currentDua = dua;
      _currentLanguage = selectedLanguage;

      await _audioPlayer.setAsset(audioPath);
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

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de la pause: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de la reprise: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _position = Duration.zero;
      _currentDua = null;
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Erreur lors de l\'arrêt: ${e.toString()}';
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

  void toggleLoop() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
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
}
