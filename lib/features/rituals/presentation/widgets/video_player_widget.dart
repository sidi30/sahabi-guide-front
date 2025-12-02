import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget pour lire les vidéos YouTube liées aux rituels
/// Utilise url_launcher pour ouvrir la vidéo dans l'app YouTube ou le navigateur
class VideoPlayerWidget extends StatelessWidget {
  final String? videoUrl;
  final String ritualName;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.ritualName,
  });

  /// Extrait l'ID de la vidéo YouTube depuis l'URL
  String? _extractYouTubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\?\/]+)',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Génère l'URL de la miniature YouTube
  String? _getThumbnailUrl(String? videoId) {
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  /// Ouvre la vidéo YouTube
  Future<void> _playVideo(BuildContext context) async {
    if (videoUrl == null || videoUrl!.isEmpty) {
      _showErrorSnackbar(context, 'Aucune vidéo disponible pour ce rituel.');
      return;
    }

    final uri = Uri.parse(videoUrl!);

    try {
      // Essayer d'ouvrir dans l'app YouTube (Android)
      final youtubeAppUri = Uri.parse(
        'vnd.youtube:${_extractYouTubeId(videoUrl!)}',
      );

      if (await canLaunchUrl(youtubeAppUri)) {
        await launchUrl(youtubeAppUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(uri)) {
        // Fallback: ouvrir dans le navigateur
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar(
          context,
          'Impossible d\'ouvrir la vidéo. Vérifiez que YouTube est installé.',
        );
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Erreur lors de l\'ouverture de la vidéo: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return _buildNoVideoCard(context);
    }

    final videoId = _extractYouTubeId(videoUrl!);
    final thumbnailUrl = _getThumbnailUrl(videoId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _playVideo(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Miniature de la vidéo
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderThumbnail();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildPlaceholderThumbnail();
                          },
                        )
                      : _buildPlaceholderThumbnail(),
                ),
                // Bouton Play
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.all(12.0),
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

  Widget _buildPlaceholderThumbnail() {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildNoVideoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.videocam_off, color: Colors.grey[400], size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune vidéo disponible pour ce rituel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
