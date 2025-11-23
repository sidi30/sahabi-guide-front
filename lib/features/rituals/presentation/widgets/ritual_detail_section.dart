import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../shared/models/ritual_model.dart';

class RitualDetailSection extends StatefulWidget {
  final RitualModel ritual;
  final String audioLanguage;
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onWatchVideo;

  const RitualDetailSection({
    super.key,
    required this.ritual,
    required this.audioLanguage,
    this.onMarkAsCompleted,
    this.onWatchVideo,
  });

  @override
  State<RitualDetailSection> createState() => _RitualDetailSectionState();
}

class _RitualDetailSectionState extends State<RitualDetailSection> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _hasReadExplanation = false;
  bool _hasWatchedVideo = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playExplanation() async {
    try {
      final audioPath = widget.ritual.getAudioPath(widget.audioLanguage);
      if (audioPath != null && audioPath.isNotEmpty) {
        await _setSource(audioPath);
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
          _hasReadExplanation = true;
        });

        // Écouter la fin de la lecture
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      } else {
        _showMessage('Aucun fichier audio disponible pour cette langue');
      }
    } catch (e) {
      _showMessage('Erreur lors de la lecture audio: $e');
    }
  }

  Future<void> _pauseExplanation() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _watchVideo() {
    setState(() {
      _hasWatchedVideo = true;
    });
    widget.onWatchVideo?.call();
  }

  void _markAsCompleted() {
    widget.onMarkAsCompleted?.call();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get _canMarkAsCompleted {
    return widget.ritual.status != RitualStatus.completed &&
        widget.ritual.status != RitualStatus.overdue &&
        (_hasReadExplanation || _hasWatchedVideo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4FC3F7),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Explication détaillée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Explication complète du rituel
          _buildExplanationSection(),
          const SizedBox(height: 20),

          // Boutons audio et vidéo
          _buildMediaButtons(),
          const SizedBox(height: 20),

          // Bouton "Marquer comme fait"
          _buildMarkAsCompletedButton(),
        ],
      ),
    );
  }

  Widget _buildExplanationSection() {
    final steps = _getImportantSteps();
    final info = _getPracticalInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description principale
        Text(
          _getDetailedExplanation(),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // Étapes importantes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    color: Color(0xFF4FC3F7),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Étapes importantes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3F7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Informations pratiques
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Conseils pratiques',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...info.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButtons() {
    return Row(
      children: [
        // Bouton Audio
        Expanded(
          child: _buildMediaButton(
            icon: _isPlaying ? Icons.pause : Icons.play_arrow,
            label: _isPlaying ? 'Pause' : 'Écouter l\'explication',
            color: const Color(0xFF4FC3F7),
            onPressed: _isPlaying ? _pauseExplanation : _playExplanation,
            isEnabled: widget.ritual.hasAudio,
          ),
        ),
        const SizedBox(width: 12),

        // Bouton Vidéo
        Expanded(
          child: _buildMediaButton(
            icon: Icons.play_circle_outline,
            label: 'Regarder la vidéo',
            color: const Color(0xFF8B5CF6),
            onPressed: _watchVideo,
            isEnabled: widget.ritual.getVideoUrl(widget.audioLanguage) != null,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        foregroundColor: isEnabled ? color : Colors.grey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMarkAsCompletedButton() {
    final isCompleted = widget.ritual.status == RitualStatus.completed;
    final isOverdue = widget.ritual.status == RitualStatus.overdue;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canMarkAsCompleted ? _markAsCompleted : null,
        icon: Icon(
          isCompleted ? Icons.check_circle : Icons.check_circle_outline,
          size: 24,
        ),
        label: Text(
          isCompleted
              ? '✅ Rituel accompli'
              : isOverdue
                  ? '❌ Rituel manqué'
                  : 'Marquer comme accompli',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : isOverdue
                  ? Colors.grey.withValues(alpha: 0.1)
                  : _canMarkAsCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
          foregroundColor: isCompleted
              ? const Color(0xFF10B981)
              : isOverdue
                  ? Colors.grey
                  : _canMarkAsCompleted
                      ? const Color(0xFF10B981)
                      : Colors.grey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  String _getDetailedExplanation() {
    // Retourne juste le texte, le formatage sera géré par _buildExplanationSection
    switch (widget.ritual.name.toLowerCase()) {
      case 'tawaf':
        return 'Le Tawaf consiste à faire 7 tours complets autour de la Kaaba dans le sens inverse des aiguilles d\'une montre.';
      case 'sa\'i':
        return 'Le Sa\'i consiste à marcher 7 fois entre les collines de Safa et Marwa pour commémorer le parcours de Hajar.';
      case 'wuquf à arafat':
        return 'Le Wuquf à Arafat est le pilier principal du Hadj, obligatoire le 9ème jour de Dhul Hijjah.';
      default:
        return 'Ce rituel fait partie intégrante du Hadj. Suivez attentivement les instructions.';
    }
  }

  List<String> _getImportantSteps() {
    switch (widget.ritual.name.toLowerCase()) {
      case 'tawaf':
        return [
          'Commencer au niveau de la Pierre Noire (Hajar al-Aswad)',
          'Faire 7 tours complets dans le sens inverse des aiguilles',
          'Réciter "Bismillah Allahu Akbar" à chaque passage',
          'Terminer chaque tour au niveau de la Pierre Noire',
          'Maintenir la pureté rituelle (wudu) pendant tout le Tawaf',
        ];
      case 'sa\'i':
        return [
          'Commencer par la colline de Safa en récitant des invocations',
          'Marcher vers Marwa en récitant "Subhan Allah"',
          'Faire 7 allers-retours complets (Safa→Marwa = 1)',
          'Courir légèrement entre les piliers verts (hommes uniquement)',
          'Réciter des invocations spécifiques à chaque sommet',
        ];
      case 'wuquf à arafat':
        return [
          'Arriver à Arafat avant le coucher du soleil',
          'Rester dans la plaine jusqu\'au coucher du soleil',
          'Réciter des invocations, douas et istighfar',
          'Éviter de dormir pendant cette période sacrée',
          'Partir après le coucher du soleil vers Muzdalifah',
        ];
      default:
        return [
          'Maintenez votre pureté rituelle (wudu)',
          'Récitez des invocations sincères',
          'Respectez les autres pèlerins',
          'Suivez les instructions des autorités religieuses',
        ];
    }
  }

  Map<String, String> _getPracticalInfo() {
    switch (widget.ritual.name.toLowerCase()) {
      case 'tawaf':
        return {
          'Durée': '30-45 minutes',
          'Conseil': 'Restez hydraté',
          'Focus': 'Concentration sur les invocations',
        };
      case 'sa\'i':
        return {
          'Durée': '20-30 minutes',
          'Distance': 'Environ 3,5 km',
          'Conseil': 'Portez des chaussures confortables',
        };
      case 'wuquf à arafat':
        return {
          'Durée': 'Lever au coucher du soleil (~12h)',
          'Importance': 'Pilier principal du Hadj',
          'Conseil': 'Emportez eau et parasol',
        };
      default:
        return {
          'Conseil': 'Suivez votre guide',
          'Focus': 'Sincérité et dévotion',
        };
    }
  }

  Future<void> _setSource(String path) async {
    final source = path.trim();
    if (source.startsWith('http')) {
      await _audioPlayer.setUrl(source);
    } else if (source.startsWith('gs://')) {
      await _audioPlayer.setUrl(_convertGsToHttps(source));
    } else {
      await _audioPlayer.setAsset(source);
    }
  }

  String _convertGsToHttps(String gsPath) {
    final sanitized = gsPath.replaceFirst('gs://', '');
    final parts = sanitized.split('/');
    final bucket = parts.first;
    final objectPath = parts.skip(1).join('/');
    return 'https://storage.googleapis.com/$bucket/$objectPath';
  }
}
