import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../domain/usecases/get_rituals_usecase.dart';

final ritualsProvider = FutureProvider<List<RitualModel>>((ref) async {
  final useCase = sl<GetRitualsUseCase>();
  return await useCase();
});

final duasProvider = FutureProvider<List<RitualModel>>((ref) async {
  final useCase = sl<GetRitualsUseCase>();
  return await useCase.getDuas();
});

class RitualsPage extends ConsumerStatefulWidget {
  final bool showDuasOnly;
  
  const RitualsPage({
    super.key,
    this.showDuasOnly = false,
  });

  @override
  ConsumerState<RitualsPage> createState() => _RitualsPageState();
}

class _RitualsPageState extends ConsumerState<RitualsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showDuasOnly ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showDuasOnly ? 'Douas' : 'Rituels'),
        bottom: widget.showDuasOnly ? null : TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Rituels', icon: Icon(Icons.schedule)),
            Tab(text: 'Douas', icon: Icon(Icons.book)),
          ],
        ),
      ),
      body: widget.showDuasOnly
          ? _buildDuasTab()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRitualsTab(),
                _buildDuasTab(),
              ],
            ),
    );
  }

  Widget _buildRitualsTab() {
    final ritualsAsync = ref.watch(ritualsProvider);

    return ritualsAsync.when(
      data: (rituals) => _buildRitualsList(rituals, 'Aucun rituel trouvé'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildDuasTab() {
    final duasAsync = ref.watch(duasProvider);

    return duasAsync.when(
      data: (duas) => _buildRitualsList(duas, 'Aucune dua trouvée'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildRitualsList(List<RitualModel> rituals, String emptyMessage) {
    if (rituals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rituals.length,
      itemBuilder: (context, index) {
        final ritual = rituals[index];
        return _buildRitualCard(ritual);
      },
    );
  }

  Widget _buildRitualCard(RitualModel ritual) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/rituals/detail/${ritual.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getRitualColor(ritual.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _getRitualIcon(ritual.type),
                      color: _getRitualColor(ritual.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ritual.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ritual.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (ritual.scheduledTime != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ritual.scheduledTime!.hour.toString().padLeft(2, '0')}:${ritual.scheduledTime!.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRitualColor(ritual.type),
                          ),
                        ),
                        Text(
                          _getFrequencyText(ritual.frequency),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              if (ritual.duration != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(ritual.duration!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (ritual.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: ritual.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
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
            'Erreur: $error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(ritualsProvider);
              ref.invalidate(duasProvider);
            },
            child: const Text('Réessayer'),
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
