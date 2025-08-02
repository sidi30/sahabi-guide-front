import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _audioPlayer;
  
  AudioService(this._audioPlayer);

  AudioPlayer get player => _audioPlayer;

  // Play audio from assets
  Future<void> playFromAssets(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  // Play audio from URL
  Future<void> playFromUrl(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play audio from URL: $e');
    }
  }

  // Pause audio
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume audio
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  // Stop audio
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Set playback speed
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  // Get current position
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  // Get duration
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // Get player state
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // Check if playing
  bool get isPlaying => _audioPlayer.playing;

  // Get current position
  Duration get currentPosition => _audioPlayer.position;

  // Get duration
  Duration? get duration => _audioPlayer.duration;

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }

  // Set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioPlayer.setLoopMode(loopMode);
  }

  // Create playlist
  Future<void> setPlaylist(List<String> assetPaths) async {
    final playlist = ConcatenatingAudioSource(
      children: assetPaths
          .map((path) => AudioSource.asset(path))
          .toList(),
    );
    await _audioPlayer.setAudioSource(playlist);
  }

  // Next track
  Future<void> next() async {
    await _audioPlayer.seekToNext();
  }

  // Previous track
  Future<void> previous() async {
    await _audioPlayer.seekToPrevious();
  }
}
