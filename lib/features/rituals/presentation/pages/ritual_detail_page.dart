import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/services/audio_service.dart';
import '../../domain/usecases/get_rituals_usecase.dart';

final ritualDetailProvider =
    FutureProvider.family<RitualModel?, String>((ref, id) async {
  final useCase = sl<GetRitualsUseCase>();
  return await useCase.getRitualById(id);
});

class RitualDetailPage extends ConsumerStatefulWidget {
  final String ritualId;

  const RitualDetailPage({
    super.key,
    required this.ritualId,
  });

  @override
  ConsumerState<RitualDetailPage> createState() => _RitualDetailPageState();
}

class _RitualDetailPageState extends ConsumerState<RitualDetailPage> {
  bool _isPlaying = false;
  final AudioService _audioService = sl<AudioService>();

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  void _toggleAudio(String? audioPath) async {
    if (audioPath == null) return;

    try {
      if (_isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.playFromAssets(audioPath);
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur audio: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ritualAsync = ref.watch(ritualDetailProvider(widget.ritualId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du rituel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing
            },
          ),
        ],
      ),
      body: ritualAsync.when(
        data: (ritual) {
          if (ritual == null) {
            return const Center(
              child: Text('Rituel non trouvé'),
            );
          }
          return _buildRitualDetail(ritual);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(ritualDetailProvider(widget.ritualId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRitualDetail(RitualModel ritual) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getRitualColor(ritual.type)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          _getRitualIcon(ritual.type),
                          color: _getRitualColor(ritual.type),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ritual.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getRitualTypeText(ritual.type),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: _getRitualColor(ritual.type),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ritual.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Arabic Text (if available)
          if (ritual.arabicText != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Texte arabe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ritual.arabicText!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Arabic',
                              height: 2.0,
                            ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Transliteration (if available)
          if (ritual.transliteration != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translittération',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ritual.transliteration!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Translation (if available)
          if (ritual.translation != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traduction',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ritual.translation!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Audio Player (if available)
          if (ritual.audioPath != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _toggleAudio(ritual.audioPath),
                          icon:
                              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          label: Text(_isPlaying ? 'Pause' : 'Écouter'),
                        ),
                        const SizedBox(width: 16),
                        if (ritual.duration != null)
                          Text(
                            _formatDuration(ritual.duration!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      'Fréquence', _getFrequencyText(ritual.frequency)),
                  if (ritual.scheduledTime != null)
                    _buildDetailRow(
                      'Heure prévue',
                      '${ritual.scheduledTime!.hour.toString().padLeft(2, '0')}:${ritual.scheduledTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  if (ritual.duration != null)
                    _buildDetailRow('Durée', _formatDuration(ritual.duration!)),
                  _buildDetailRow('Priorité', '${ritual.priority}/5'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as completed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marqué comme terminé')),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Marquer comme terminé'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Color _getRitualColor(RitualType type) {
    switch (type) {
      case RitualType.prayer:
        return AppTheme.primaryColor;
      case RitualType.dua:
        return AppTheme.secondaryColor;
      case RitualType.dhikr:
        return AppTheme.accentColor;
      case RitualType.reading:
        return Colors.purple;
      case RitualType.charity:
        return Colors.green;
      case RitualType.fasting:
        return Colors.orange;
    }
  }

  IconData _getRitualIcon(RitualType type) {
    switch (type) {
      case RitualType.prayer:
        return Icons.schedule;
      case RitualType.dua:
        return Icons.book;
      case RitualType.dhikr:
        return Icons.favorite;
      case RitualType.reading:
        return Icons.menu_book;
      case RitualType.charity:
        return Icons.volunteer_activism;
      case RitualType.fasting:
        return Icons.no_meals;
    }
  }

  String _getRitualTypeText(RitualType type) {
    switch (type) {
      case RitualType.prayer:
        return 'Prière';
      case RitualType.dua:
        return 'Dua';
      case RitualType.dhikr:
        return 'Dhikr';
      case RitualType.reading:
        return 'Lecture';
      case RitualType.charity:
        return 'Charité';
      case RitualType.fasting:
        return 'Jeûne';
    }
  }

  String _getFrequencyText(RitualFrequency frequency) {
    switch (frequency) {
      case RitualFrequency.daily:
        return 'Quotidien';
      case RitualFrequency.weekly:
        return 'Hebdomadaire';
      case RitualFrequency.monthly:
        return 'Mensuel';
      case RitualFrequency.yearly:
        return 'Annuel';
      case RitualFrequency.occasional:
        return 'Occasionnel';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
