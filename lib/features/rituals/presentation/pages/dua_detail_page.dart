import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../shared/models/dua_model.dart';

/// Detail d'une dua avec lecture audio arabe lente (TTS) pour la prononciation,
/// translitteration (si dispo) et traduction francaise.
class DuaDetailPage extends StatefulWidget {
  final DuaModel dua;

  const DuaDetailPage({super.key, required this.dua});

  @override
  State<DuaDetailPage> createState() => _DuaDetailPageState();
}

class _DuaDetailPageState extends State<DuaDetailPage> {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _ttsReady = false;
  bool _useAudioFile = false;

  static const double _slowRate = 0.35;

  @override
  void initState() {
    super.initState();
    _init();
  }

  String? _resolveAudioUrl() {
    final candidates = <String?>[
      widget.dua.audioPaths['ar'],
      widget.dua.audioPaths['fr'],
      widget.dua.audioPath,
    ];
    for (final url in candidates) {
      if (url == null) continue;
      final trimmed = url.trim();
      if (trimmed.isEmpty) continue;
      // just_audio ne sait pas lire gs:// : ces stubs Cloud Storage sont ignores
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
    }
    return null;
  }

  Future<void> _init() async {
    final audioUrl = _resolveAudioUrl();
    if (audioUrl != null) {
      _useAudioFile = true;
      _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        final playing = state.playing && state.processingState != ProcessingState.completed;
        if (_isPlaying != playing) setState(() => _isPlaying = playing);
      });
      try {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.setSpeed(0.85); // legerement ralenti pour memorisation
        if (mounted) await _audioPlayer.play();
        return;
      } catch (_) {
        _useAudioFile = false;
        // basculer sur TTS
      }
    }
    await _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(_slowRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      String locale = 'ar-SA';
      try {
        final available = await _tts.isLanguageAvailable('ar-SA');
        if (available != true) {
          locale = 'ar';
          final fallback = await _tts.isLanguageAvailable('ar');
          if (fallback != true) {
            locale = 'fr-FR';
          }
        }
      } catch (_) {
        locale = 'ar';
      }
      await _tts.setLanguage(locale);

      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isPlaying = false);
      });

      _ttsReady = true;
      if (mounted) {
        await _speak();
      }
    } catch (_) {
      _ttsReady = false;
    }
  }

  Future<void> _speak() async {
    if (_useAudioFile) {
      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      } catch (_) {}
      return;
    }
    if (!_ttsReady) return;
    final text = widget.dua.arabicText.trim();
    if (text.isEmpty) return;
    await _tts.stop();
    if (!mounted) return;
    setState(() => _isPlaying = true);
    await _tts.setSpeechRate(_slowRate);
    await _tts.speak(text);
  }

  Future<void> _stop() async {
    if (_useAudioFile) {
      await _audioPlayer.stop();
    } else {
      await _tts.stop();
    }
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dua = widget.dua;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dua'),
        backgroundColor: const Color(0xFF1B5E3F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte arabe
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0C97A), width: 1),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  dua.arabicText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 2.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B5E3F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton lecture
            ElevatedButton.icon(
              onPressed: _isPlaying ? _stop : _speak,
              icon: Icon(_isPlaying ? Icons.stop_circle : Icons.volume_up),
              label: Text(
                _isPlaying
                    ? 'Arrêter la lecture'
                    : 'Écouter la prononciation',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E3F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _useAudioFile
                  ? 'Récitation audio ralentie pour la mémorisation'
                  : 'Lecture vocale en arabe (installer un pack TTS arabe sur Android pour le son)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Translitteration (si dispo)
            if (dua.transliteration.trim().isNotEmpty) ...[
              _SectionLabel(text: 'Translittération'),
              const SizedBox(height: 8),
              Text(
                dua.transliteration,
                style: const TextStyle(
                  fontSize: 17,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF455A64),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Traduction francaise
            _SectionLabel(text: 'Traduction française'),
            const SizedBox(height: 8),
            Text(
              dua.translation,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF263238),
                height: 1.55,
              ),
            ),

            // Tags / metadonnees
            if (dua.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: dua.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: const Color(0xFFE8F5E9),
                          labelStyle:
                              const TextStyle(color: Color(0xFF1B5E3F)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Color(0xFF1B5E3F),
      ),
    );
  }
}
