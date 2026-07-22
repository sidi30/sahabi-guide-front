import 'package:flutter/material.dart';
import '../../data/rite_images.dart';
import 'video_player_widget.dart';

/// Lecteur « comme un livre » d'un rite : une étape par page, texte en GRAND,
/// images en plein écran zoomables, et la vidéo accessible. Ouvert au tap sur une
/// étape. Objectif : lecture confortable sur mobile (fini le tout petit serré).
class StepReaderPage extends StatefulWidget {
  final String ritualName;
  final String ritualDescription;
  final List<String> steps;
  final List<RiteImage> images;
  final String? videoUrl;
  final int initialIndex;

  const StepReaderPage({
    super.key,
    required this.ritualName,
    required this.ritualDescription,
    required this.steps,
    required this.images,
    required this.videoUrl,
    this.initialIndex = 0,
  });

  @override
  State<StepReaderPage> createState() => _StepReaderPageState();
}

class _StepReaderPageState extends State<StepReaderPage> {
  late final PageController _controller;
  late int _index;

  // Couleurs par numéro d'étape (lecture facilitée).
  static const _accents = <Color>[
    Color(0xFF2563EB), // bleu
    Color(0xFF059669), // vert
    Color(0xFF7C3AED), // violet
    Color(0xFFD97706), // ambre
    Color(0xFF0891B2), // cyan
    Color(0xFFDB2777), // rose
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _pageCount - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pages = une par étape (+ une page vidéo à la fin si une vidéo existe).
  bool get _hasVideoPage =>
      widget.videoUrl != null && widget.videoUrl!.isNotEmpty;
  int get _stepCount => widget.steps.length;
  int get _pageCount => _stepCount + (_hasVideoPage ? 1 : 0);

  Color _accent(int i) => _accents[i % _accents.length];

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _pageCount - 1);
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  void _openImages(int startAt) {
    if (widget.images.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => FullscreenImageViewer(
        images: widget.images,
        initialIndex: startAt,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        elevation: 0.5,
        title: Text(
          widget.ritualName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
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
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _pageCount,
              itemBuilder: (context, i) {
                if (_hasVideoPage && i == _pageCount - 1) {
                  return _buildVideoPage();
                }
                return _buildStepPage(i);
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepPage(int i) {
    final accent = _accent(i);
    // Image liée à cette étape (meilleure correspondance par mot-clé), sinon
    // la 1re image du rite pour garder un visuel. Rien si le rite n'a pas d'image.
    final img = _imageForStep(i);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge « Étape N sur M »
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Étape ${i + 1} sur $_stepCount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Image de la section, en grand, tap = plein écran zoomable.
          if (img != null) ...[
            _buildStepImage(img, accent),
            const SizedBox(height: 20),
          ],

          // Texte de l'étape en GRAND (lecture confortable).
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

  Widget _buildStepImage(RiteImage img, Color accent) {
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
                        color: Colors.grey, size: 48),
                  ),
                ),
              ),
            ),
            // Indice « appuyer pour agrandir »
            Container(
              margin: const EdgeInsets.all(10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              Text(
                'Vidéo du rite',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Regarde la démonstration en vidéo pour bien comprendre.',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 20),
          VideoPlayerWidget(
            videoUrl: widget.videoUrl,
            ritualName: widget.ritualName,
          ),
        ],
      ),
    );
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
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _navButton(
            icon: Icons.chevron_left,
            label: 'Précédent',
            enabled: !isFirst,
            onTap: () => _go(-1),
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
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? _accent(_index)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
          _navButton(
            icon: Icons.chevron_right,
            label: 'Suivant',
            enabled: !isLast,
            onTap: () => _go(1),
            trailingIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool trailingIcon = false,
  }) {
    final color = enabled ? _accent(_index) : const Color(0xFF9CA3AF);
    final children = <Widget>[
      if (!trailingIcon) Icon(icon, color: color, size: 22),
      Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      if (trailingIcon) Icon(icon, color: color, size: 22),
    ];
    return TextButton(
      onPressed: enabled ? onTap : null,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  /// Choisit l'image qui correspond le mieux au texte de l'étape (mot-clé de la
  /// légende présent dans le texte). Sinon, pour un rite mono-image, on la montre.
  RiteImage? _imageForStep(int i) {
    if (widget.images.isEmpty) return null;
    final text = widget.steps[i].toLowerCase();
    for (final im in widget.images) {
      // mots significatifs de la légende (>3 lettres)
      final words = im.caption
          .toLowerCase()
          .replaceAll(RegExp(r"[^a-zàâäéèêëîïôöùûüç' ]"), ' ')
          .split(' ')
          .where((w) => w.length > 3)
          .toList();
      if (words.any((w) => text.contains(w))) return im;
    }
    // Une seule image dispo → la montrer sur chaque page (visuel d'appui).
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
                        size: 64,
                      ),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
