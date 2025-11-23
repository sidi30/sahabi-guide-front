import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
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
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioService = sl<AudioService>();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Écouter les changements de position
      _audioService.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });

      // Écouter les changements de durée
      _audioService.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() => _duration = duration);
        }
      });

      // Écouter l'état du lecteur
      _audioService.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      // Démarrer la lecture automatiquement
      if (widget.dua.audioPath.isNotEmpty) {
        final audioLanguage = ref.read(settingsProvider).audioLanguage.code;
        await _audioService.playDua(widget.dua, language: audioLanguage);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de l\'audio: $e');
    }
  }

  @override
  void dispose() {
    _audioService.stop();
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
            // Progress bar
            if (_duration.inSeconds > 0)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.grey[300],
                  onChanged: (value) {
                    _audioService.seekTo(Duration(seconds: value.toInt()));
                  },
                ),
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
                        Text(
                          '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle : Icons.play_circle,
                          size: 48,
                        ),
                        color: AppColors.primary,
                        onPressed: () {
                          if (_isPlaying) {
                            _audioService.pause();
                          } else {
                            _audioService.resume();
                          }
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
