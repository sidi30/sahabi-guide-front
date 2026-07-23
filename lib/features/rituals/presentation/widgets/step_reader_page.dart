import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/tts_service.dart';
import '../../data/rite_images.dart';
import 'video_player_widget.dart';

/// Lecteur « comme un livre » d'un rite : une étape par page, texte en GRAND,
/// images en plein écran zoomables, écoute audio (voix homme/femme), et une page
/// de fin pour marquer le rite accompli. Ouvert au tap sur une étape.
class StepReaderPage extends StatefulWidget {
  final String ritualName;
  final String ritualDescription;
  final List<String> steps;
  final List<RiteImage> images;
  final String? videoUrl;
  final int initialIndex;

  /// Langue de lecture audio (fr/en/ar/...).
  final String audioLanguage;

  /// 'MALE' / 'FEMALE' : choisit la voix (homme/femme) pour l'écoute.
  final String? gender;

  /// Rite déjà accompli ? (état initial du bouton de la page de fin)
  final bool isCompleted;

  /// Bascule « accompli / non accompli » du rite (progression on-device + serveur).
  final VoidCallback? onToggleCompleted;

  const StepReaderPage({
    super.key,
    required this.ritualName,
    required this.ritualDescription,
    required this.steps,
    required this.images,
    required this.videoUrl,
    required this.audioLanguage,
    this.gender,
    this.isCompleted = false,
    this.onToggleCompleted,
    this.initialIndex = 0,
  });

  @override
  State<StepReaderPage> createState() => _StepReaderPageState();
}

class _StepReaderPageState extends State<StepReaderPage> {
  late final PageController _controller;
  final TtsService _tts = sl<TtsService>();
  late int _index;
  late bool _done;

  // Lecture audio en continu (écoute) : lit l'étape courante puis enchaîne.
  bool _audioOn = false;
  int _audioTarget = -1; // page visée par la boucle audio (anti-yank au swipe)

  static const _accents = <Color>[
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFFD97706),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
  ];

  @override
  void initState() {
    super.initState();
    _done = widget.isCompleted;
    _index = widget.initialIndex.clamp(0, _pageCount - 1);
    _controller = PageController(initialPage: _index);
    _tts.addListener(_onTts);
    _tts.onError = _snack;
  }

  @override
  void dispose() {
    _audioOn = false;
    _tts.removeListener(_onTts);
    if (_tts.currentTag == _ttsTag) _tts.stop();
    _tts.onError = null;
    _controller.dispose();
    super.dispose();
  }

  String get _ttsTag => 'reader:${widget.ritualName}';
  void _onTts() {
    if (mounted) setState(() {});
  }

  bool get _hasVideoPage =>
      widget.videoUrl != null && widget.videoUrl!.isNotEmpty;
  int get _stepCount => widget.steps.length;
  // pages = étapes + (vidéo ?) + page de fin
  int get _pageCount => _stepCount + (_hasVideoPage ? 1 : 0) + 1;
  int get _finishIndex => _pageCount - 1;
  bool get _isStepPage => _index < _stepCount;

  Color _accent(int i) => _accents[i % _accents.length];

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _pageCount - 1);
    _controller.animateToPage(next,
        duration: const Duration(milliseconds: 260), curve: Curves.easeInOut);
  }

  void _openImages(int startAt) {
    if (widget.images.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          FullscreenImageViewer(images: widget.images, initialIndex: startAt),
    ));
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  // --- Écoute audio ---------------------------------------------------------

  bool get _isSpeaking => _tts.isSpeaking && _tts.currentTag == _ttsTag;

  Future<void> _toggleAudio() async {
    if (_audioOn || _isSpeaking) {
      await _stopAudio();
    } else {
      // Démarrer depuis l'étape courante (ou la 1re si on est sur vidéo/fin).
      await _startAudioFrom(_isStepPage ? _index : 0);
    }
  }

  Future<void> _stopAudio() async {
    _audioOn = false;
    await _tts.stop();
    if (mounted) setState(() {});
  }

  /// Lit l'étape [from], puis enchaîne automatiquement les étapes suivantes.
  Future<void> _startAudioFrom(int from) async {
    _audioOn = true;
    if (mounted) setState(() {});
    for (int p = from; p < _stepCount && _audioOn && mounted; p++) {
      _audioTarget = p;
      if (_index != p) {
        await _controller.animateToPage(p,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut);
      }
      if (!_audioOn || !mounted) break;
      await _tts.speak(widget.steps[p],
          lang: widget.audioLanguage,
          tag: _ttsTag,
          gender: widget.gender,
          natural: true);
      // _tts.speak attend la fin de l'énoncé (voix serveur ou on-device).
      if (!_audioOn || !mounted) break;
    }
    _audioOn = false;
    _audioTarget = -1;
    if (mounted) setState(() {});
  }

  Future<void> _readOne(int i) async {
    await _stopAudio();
    await _tts.speak(widget.steps[i],
        lang: widget.audioLanguage,
        tag: _ttsTag,
        gender: widget.gender,
        natural: true);
  }

  void _onPageChanged(int i) {
    // Swipe manuel pendant l'écoute continue -> on arrête (évite le « yank »).
    if (_audioOn && i != _audioTarget) {
      _audioOn = false;
      _tts.stop();
    }
    setState(() => _index = i);
  }

  void _exit() {
    _audioOn = false;
    _tts.stop();
    Navigator.of(context).maybePop();
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        _audioOn = false;
        _tts.stop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1D3557),
          elevation: 0.5,
          leading: IconButton(
            tooltip: 'Fermer',
            icon: const Icon(Icons.close),
            onPressed: _exit,
          ),
          title: Text(
            widget.ritualName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          actions: [
            // Écouter / arrêter (voix homme/femme selon le profil)
            IconButton(
              tooltip: (_audioOn || _isSpeaking) ? 'Arrêter l\'écoute' : 'Écouter',
              icon: Icon((_audioOn || _isSpeaking)
                  ? Icons.stop_circle
                  : Icons.headset),
              onPressed: _toggleAudio,
            ),
            if (widget.images.isNotEmpty)
              IconButton(
                tooltip: 'Voir les images en grand',
                icon: const Icon(Icons.photo_library_outlined),
                onPressed: () => _openImages(0),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onPageChanged,
                itemCount: _pageCount,
                itemBuilder: (context, i) {
                  if (i == _finishIndex) return _buildFinishPage();
                  if (_hasVideoPage && i == _stepCount) return _buildVideoPage();
                  return _buildStepPage(i);
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage(int i) {
    final accent = _accent(i);
    final img = _imageForStep(i);
    final speakingThis = _isSpeaking && (_audioTarget == i || _audioTarget == -1);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Text('Étape ${i + 1} sur $_stepCount',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accent)),
            ],
          ),
          const SizedBox(height: 16),

          // Bouton écouter cette étape
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: speakingThis ? _stopAudio : () => _readOne(i),
              icon: Icon(speakingThis ? Icons.stop : Icons.volume_up,
                  size: 20, color: accent),
              label: Text(speakingThis ? 'Arrêter' : 'Écouter cette étape',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.08),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (img != null) ...[
            _buildStepImage(img),
            const SizedBox(height: 20),
          ],

          SelectableText(
            widget.steps[i],
            style: const TextStyle(
              fontSize: 20,
              height: 1.7,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepImage(RiteImage img) {
    final idx = widget.images.indexOf(img);
    return GestureDetector(
      onTap: () => _openImages(idx < 0 ? 0 : idx),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(
                img.asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey, size: 48)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Agrandir',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_fill, color: Color(0xFF8B5CF6), size: 28),
              SizedBox(width: 10),
              Text('Vidéo du rite',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3557))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Regarde la démonstration en vidéo pour bien comprendre.',
              style: TextStyle(
                  fontSize: 15, color: Color(0xFF6B7280), height: 1.5)),
          const SizedBox(height: 20),
          VideoPlayerWidget(
              videoUrl: widget.videoUrl, ritualName: widget.ritualName),
        ],
      ),
    );
  }

  /// Page de fin : félicite, permet de marquer accompli (en grand) et de sortir.
  Widget _buildFinishPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: (_done ? const Color(0xFF10B981) : const Color(0xFF1D3557))
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _done ? Icons.verified : Icons.emoji_events,
                size: 52,
                color: _done ? const Color(0xFF10B981) : const Color(0xFF1D3557),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _done ? 'Rite accompli' : 'Lecture terminée',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557)),
          ),
          const SizedBox(height: 12),
          Text(
            _done
                ? 'Bravo ! Tu as marqué « ${widget.ritualName} » comme accompli.'
                : 'Tu as parcouru toutes les étapes de « ${widget.ritualName} ». '
                    'Tu peux le marquer comme accompli, ou revenir à la liste.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, color: Color(0xFF4B5563), height: 1.6),
          ),
          const SizedBox(height: 32),

          // Marquer comme accompli — EN GRAND
          SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _onFinishToggle,
              icon: Icon(
                  _done ? Icons.check_circle : Icons.check_circle_outline,
                  size: 26),
              label: Text(
                _done ? 'Accompli — appuyer pour annuler' : 'Marquer comme accompli',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _done
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : const Color(0xFF10B981),
                foregroundColor:
                    _done ? const Color(0xFF065F46) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Retour à la liste des rites
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _exit,
              icon: const Icon(Icons.list_alt, size: 22),
              label: const Text('Revenir à la liste des rites',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1D3557),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFinishToggle() {
    widget.onToggleCompleted?.call();
    setState(() => _done = !_done);
    if (_done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${widget.ritualName} marqué comme accompli'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildBottomBar() {
    final isFirst = _index == 0;
    final isLast = _index == _pageCount - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          // QUITTER — toujours visible, à portée de pouce, sur CHAQUE page.
          TextButton.icon(
            onPressed: _exit,
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Quitter',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_pageCount, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          active ? _accent(_index) : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Précédent',
            onPressed: isFirst ? null : () => _go(-1),
            icon: Icon(Icons.chevron_left,
                size: 30,
                color: isFirst ? const Color(0xFFCBD5E1) : _accent(_index)),
          ),
          IconButton(
            tooltip: isLast ? 'Fin' : 'Suivant',
            onPressed: isLast ? null : () => _go(1),
            icon: Icon(Icons.chevron_right,
                size: 30,
                color: isLast ? const Color(0xFFCBD5E1) : _accent(_index)),
          ),
        ],
      ),
    );
  }

  /// Image qui correspond le mieux au texte de l'étape (mot-clé de la légende).
  /// Sinon, pour un rite mono-image, on la montre en appui visuel.
  RiteImage? _imageForStep(int i) {
    if (widget.images.isEmpty) return null;
    final text = widget.steps[i].toLowerCase();
    for (final im in widget.images) {
      final words = im.caption
          .toLowerCase()
          .replaceAll(RegExp(r"[^a-zàâäéèêëîïôöùûüç' ]"), ' ')
          .split(' ')
          .where((w) => w.length > 3)
          .toList();
      if (words.any((w) => text.contains(w))) return im;
    }
    if (widget.images.length == 1) return widget.images.first;
    return null;
  }
}

/// Visionneuse d'images plein écran : pincer pour zoomer, glisser pour naviguer.
class FullscreenImageViewer extends StatefulWidget {
  final List<RiteImage> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_index + 1} / ${widget.images.length}',
            style: const TextStyle(fontSize: 15)),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: widget.images.length,
              itemBuilder: (context, i) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Image.asset(
                      widget.images[i].asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white38,
                          size: 64),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            color: Colors.black,
            child: Text(
              widget.images[_index].caption,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
