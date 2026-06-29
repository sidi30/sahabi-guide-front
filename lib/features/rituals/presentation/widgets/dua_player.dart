import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';

/// Lecteur de doua.
///
/// Deux modes :
///  - **Enregistrement réel** (audioPath en http/https) → [AudioService]
///    (just_audio) avec barre de progression et seek.
///  - **Synthèse vocale** (pas de fichier audio réel — cas actuel, les mp3
///    `assets/audio/...` ne sont pas embarqués) → [TtsService] lit le texte de
///    la doua dans la langue audio choisie (arabe, traduction fr/en, ou langue
///    africaine via le backend voix). Garantit que la doua est TOUJOURS
///    écoutable.
class DuaPlayer extends ConsumerStatefulWidget {
  final DuaModel dua;
  final VoidCallback onClose;

  const DuaPlayer({
    super.key,
    required this.dua,
    required this.onClose,
  });

  @override
  ConsumerState<DuaPlayer> createState() => _DuaPlayerState();
}

class _DuaPlayerState extends ConsumerState<DuaPlayer> {
  late final AudioService _audioService;
  late final TtsService _ttsService;
  bool _useTts = true;

  @override
  void initState() {
    super.initState();
    _audioService = sl<AudioService>();
    _ttsService = sl<TtsService>();
    _ttsService.onError = _showError;
    _initAudio();
  }

  Future<void> _initAudio() async {
    final audioLanguage = ref.read(settingsProvider).audioLanguage.code;
    final resolvedPath = widget.dua.getAudioPath(audioLanguage);
    // Un fichier audio réel = une URL http(s). Les chemins `assets/...` ne sont
    // pas embarqués → on synthétise le texte à la place.
    _useTts = !resolvedPath.startsWith('http');

    try {
      if (_useTts) {
        await _speakDua(audioLanguage);
      } else {
        await _audioService.playDua(widget.dua, language: audioLanguage);
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation de l\'audio', error: e);
    }
  }

  Future<void> _speakDua(String langCode) async {
    await _ttsService.speakDua(
      lang: langCode,
      arabicText: widget.dua.arabicText,
      translation: widget.dua.getTranslation(langCode),
      transliteration: widget.dua.transliteration,
      tag: widget.dua.id,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  @override
  void dispose() {
    _ttsService.onError = null;
    if (_useTts) {
      _ttsService.stop();
    } else {
      _audioService.stop(widget.dua);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _useTts ? _buildTtsControls() : _buildAudioFileControls(),
      ),
    );
  }

  // --- Mode synthèse vocale (TTS) ---
  Widget _buildTtsControls() {
    return AnimatedBuilder(
      animation: _ttsService,
      builder: (context, _) {
        final isSpeaking = _ttsService.isSpeaking &&
            _ttsService.currentTag == widget.dua.id;
        final isLoading = _ttsService.state == TtsState.loading;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dua.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.graphic_eq,
                            size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          isLoading ? 'Préparation…' : 'Lecture vocale',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : Icon(
                            isSpeaking
                                ? Icons.stop_circle
                                : Icons.play_circle,
                            size: 48,
                          ),
                    color: ref.colors.primary,
                    onPressed: isLoading
                        ? null
                        : () {
                            if (isSpeaking) {
                              _ttsService.stop();
                            } else {
                              _speakDua(
                                  ref.read(settingsProvider).audioLanguage.code);
                            }
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Mode fichier audio réel (just_audio) ---
  Widget _buildAudioFileControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Duration?>(
          stream: _audioService.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            if (duration.inSeconds <= 0) return const SizedBox.shrink();
            return StreamBuilder<Duration>(
              stream: _audioService.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final clamped =
                    position.inSeconds.clamp(0, duration.inSeconds).toDouble();
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: clamped,
                    max: duration.inSeconds.toDouble(),
                    activeColor: ref.colors.primary,
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) {
                      _audioService.seekTo(Duration(seconds: value.toInt()));
                    },
                  ),
                );
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dua.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<Duration>(
                      stream: _audioService.positionStream,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                          stream: _audioService.durationStream,
                          builder: (context, durationSnapshot) {
                            final duration =
                                durationSnapshot.data ?? Duration.zero;
                            return Text(
                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<PlayerState>(
                    stream: _audioService.playerStateStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      return IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          size: 48,
                        ),
                        color: ref.colors.primary,
                        onPressed: () {
                          if (isPlaying) {
                            _audioService.pause();
                          } else {
                            _audioService.resume();
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    color: Colors.grey[600],
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
