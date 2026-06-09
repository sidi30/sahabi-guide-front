import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/audio_service.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _audioService = sl<AudioService>();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Démarrer la lecture automatiquement.
      // La lecture résout le chemin via dua.getAudioPath(language)
      // (= audioPaths[language] ?? audioPath) : on garde donc l'auto-play
      // dès que ce chemin résolu est non vide.
      final audioLanguage = ref.read(settingsProvider).audioLanguage.code;
      final resolvedPath = widget.dua.getAudioPath(audioLanguage);
      if (resolvedPath.isNotEmpty) {
        await _audioService.playDua(widget.dua, language: audioLanguage);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de l\'audio: $e');
    }
  }

  @override
  void dispose() {
    _audioService.stop(widget.dua);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar : rebuild localisé sur position/durée uniquement
            StreamBuilder<Duration?>(
              stream: _audioService.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                if (duration.inSeconds <= 0) return const SizedBox.shrink();
                return StreamBuilder<Duration>(
                  stream: _audioService.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final clamped = position.inSeconds
                        .clamp(0, duration.inSeconds)
                        .toDouble();
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
                  // Dua info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dua.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<Duration>(
                          stream: _audioService.positionStream,
                          builder: (context, positionSnapshot) {
                            final position =
                                positionSnapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration?>(
                              stream: _audioService.durationStream,
                              builder: (context, durationSnapshot) {
                                final duration =
                                    durationSnapshot.data ?? Duration.zero;
                                return Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<PlayerState>(
                        stream: _audioService.playerStateStream,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data?.playing ?? false;
                          return IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
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
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
