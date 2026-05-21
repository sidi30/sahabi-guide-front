import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lecteur vidéo pour les tutoriels rituels.
///
/// Trois modes :
///   1. URL placeholder (seed `mock_xxx`)        → carte « bientôt disponible »
///   2. URL YouTube avec ID 11 caractères        → carte avec miniature YouTube
///      + 1 tap pour ouvrir l'app YouTube (ou navigateur)
///   3. URL recherche YouTube ou autre           → bouton « Voir sur YouTube »
class VideoPlayerWidget extends StatelessWidget {
  final String? videoUrl;
  final String ritualName;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.ritualName,
  });

  bool _isPlaceholder(String? url) {
    if (url == null || url.isEmpty) return true;
    return url.contains('mock_') || url.contains('placeholder');
  }

  bool _isSearchUrl(String? url) {
    if (url == null) return false;
    return url.contains('/results?') || url.contains('search_query=');
  }

  /// Extrait l'ID 11-caractères depuis tous les formats YouTube courants
  /// (watch?v=, youtu.be/, embed/, shorts/). Retourne null sinon.
  String? _extractYouTubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    final regex = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([A-Za-z0-9_-]{11})',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  String _thumbnailUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  Future<void> _openExternally(BuildContext context) async {
    final url = videoUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);

    final id = _extractYouTubeId(url);
    if (id != null) {
      final appUri = Uri.parse('vnd.youtube:$id');
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir YouTube.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaceholder(videoUrl)) {
      return _buildPlaceholderCard();
    }
    final id = _extractYouTubeId(videoUrl);
    if (id != null) {
      return _buildThumbnailCard(context, id);
    }
    return _buildExternalLinkCard(context);
  }

  Widget _buildThumbnailCard(BuildContext context, String videoId) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openExternally(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    _thumbnailUrl(videoId),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildThumbPlaceholder(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _buildThumbPlaceholder(),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.video_library, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tutoriel vidéo : $ritualName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildExternalLinkCard(BuildContext context) {
    final isSearch = _isSearchUrl(videoUrl);
    final label =
        isSearch ? 'Voir les tutoriels sur YouTube' : 'Ouvrir la vidéo';
    final subtitle = isSearch
        ? 'Plusieurs tutoriels « $ritualName » sont disponibles sur YouTube.'
        : 'Lire dans l\'app YouTube ou le navigateur.';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openExternally(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Card(
      elevation: 0,
      color: Colors.orange.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.video_library_outlined,
                color: Colors.orange.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vidéo bientôt disponible',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Un tutoriel vidéo pour « $ritualName » sera ajouté prochainement.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
