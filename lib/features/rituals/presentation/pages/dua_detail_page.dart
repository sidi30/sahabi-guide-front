import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _arabicTtsAvailable = false;

  static const double _slowRate = 0.35;

  bool _markedRead = false;

  Future<void> _markAsRead() async {
    if (_markedRead) return;
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _markedRead = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dua comptabilisée ✓'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
        // Pas d'auto-play : attend l'action user.
        if (mounted) setState(() {});
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

      // Vérifie strictement la dispo d'un pack arabe. Pas de fallback fr-FR :
      // lire du texte arabe avec une voix française produit du son incompréhensible.
      String? arabicLocale;
      try {
        if (await _tts.isLanguageAvailable('ar-SA') == true) {
          arabicLocale = 'ar-SA';
        } else if (await _tts.isLanguageAvailable('ar') == true) {
          arabicLocale = 'ar';
        }
      } catch (_) {
        arabicLocale = null;
      }

      if (arabicLocale == null) {
        _arabicTtsAvailable = false;
        _ttsReady = false;
        if (mounted) setState(() {});
        return;
      }

      await _tts.setLanguage(arabicLocale);

      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isPlaying = false);
      });

      _arabicTtsAvailable = true;
      _ttsReady = true;
      // Pas d'auto-play : attend l'action user.
      if (mounted) setState(() {});
    } catch (_) {
      _arabicTtsAvailable = false;
      _ttsReady = false;
      if (mounted) setState(() {});
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

            // Bouton lecture (désactivé si aucun audio dispo)
            Builder(builder: (_) {
              final canPlay = _useAudioFile || _arabicTtsAvailable;
              return ElevatedButton.icon(
                onPressed: !canPlay
                    ? null
                    : (_isPlaying ? _stop : _speak),
                icon: Icon(_isPlaying ? Icons.stop_circle : Icons.volume_up),
                label: Text(
                  _isPlaying
                      ? 'Arrêter la lecture'
                      : 'Écouter la prononciation',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E3F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (_useAudioFile)
              Text(
                'Récitation audio ralentie pour la mémorisation',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else if (_arabicTtsAvailable)
              Text(
                'Lecture vocale en arabe via le moteur TTS de l\'appareil',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE69C)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Audio arabe indisponible. Installe un pack vocal arabe '
                        'dans les réglages système (Android : Paramètres > Langues '
                        '> Sortie vocale > moteur de Google > Installer arabe).',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Translitteration (si dispo)
            if (dua.transliteration.trim().isNotEmpty) ...[
              const _SectionLabel(text: 'Translittération'),
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
            const _SectionLabel(text: 'Traduction française'),
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

            const SizedBox(height: 32),

            // Mark as read button — comptabilise dans dashboard
            ElevatedButton.icon(
              onPressed: _markedRead ? null : _markAsRead,
              icon: Icon(
                _markedRead ? Icons.check_circle : Icons.task_alt,
              ),
              label: Text(
                _markedRead ? 'Comptabilisée ✓' : 'J\'ai récité cette dua',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _markedRead
                    ? Colors.green.shade100
                    : const Color(0xFF1B5E3F),
                foregroundColor:
                    _markedRead ? Colors.green.shade800 : Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
