import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/ritual_model.dart';
import '../providers/rituals_state_manager.dart';
import '../widgets/ritual_timeline_item.dart';
import '../widgets/ritual_progress_indicator.dart';

class RitualTimelinePage extends StatefulWidget {
  const RitualTimelinePage({super.key});

  @override
  State<RitualTimelinePage> createState() => _RitualTimelinePageState();
}

class _RitualTimelinePageState extends State<RitualTimelinePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RitualsStateManager>().loadRituals();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Rituels du Hadj',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<RitualsStateManager>(
            builder: (context, stateManager, child) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF1D3557)),
                onPressed: () => stateManager.loadRituals(),
              );
            },
          ),
        ],
      ),
      body: Consumer<RitualsStateManager>(
        builder: (context, stateManager, child) {
          if (stateManager.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
              ),
            );
          }

          if (stateManager.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stateManager.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => stateManager.loadRituals(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              RitualProgressIndicator(
                progress: stateManager.overallProgress,
                completedCount: stateManager.completedRituals.length,
                totalCount: stateManager.rituals.length,
              ),

              // Current active ritual card
              if (stateManager.currentActiveRitual != null)
                _buildActiveRitualCard(stateManager.currentActiveRitual!),

              // Timeline
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: stateManager.rituals.length,
                  itemBuilder: (context, index) {
                    final ritual = stateManager.rituals[index];
                    final isLast = index == stateManager.rituals.length - 1;
                    
                    return RitualTimelineItem(
                      ritual: ritual,
                      isLast: isLast,
                      onStartRitual: () => stateManager.startRitual(ritual.id),
                      onCompleteRitual: () => stateManager.markRitualAsCompleted(ritual.id),
                      onPlayAudio: () => _playRitualAudio(ritual),
                      onWatchVideo: () => _watchRitualVideo(ritual),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveRitualCard(RitualModel ritual) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rituel actuel',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ritual.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'EN COURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ritual.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<RitualsStateManager>().markRitualAsCompleted(ritual.id),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Marquer terminé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4FC3F7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (ritual.audioPaths.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _playRitualAudio(ritual),
                  icon: const Icon(Icons.headphones, size: 20),
                  label: const Text('Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _playRitualAudio(RitualModel ritual) {
    // Implementation for playing ritual audio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lecture audio pour: ${ritual.name}'),
        backgroundColor: const Color(0xFF4FC3F7),
      ),
    );
  }

  void _watchRitualVideo(RitualModel ritual) {
    // Implementation for watching ritual video
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture vidéo pour: ${ritual.name}'),
        backgroundColor: const Color(0xFF4FC3F7),
      ),
    );
  }
}