import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../../domain/usecases/get_rituals_usecase.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../widgets/ritual_timeline_item.dart';
import '../services/ritual_service.dart';

final ritualsProvider = FutureProvider<List<RitualModel>>((ref) async {
  final useCase = sl<GetRitualsUseCase>();
  return await useCase();
});

// Provider pour les douas - utilise le bon type DuaModel
final duasProvider = FutureProvider<List<DuaModel>>((ref) async {
  final repository = sl<RitualsRepository>();
  return await repository.getDuas();
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
  late RitualService _ritualService;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showDuasOnly ? 1 : 0,
    );
    _ritualService = RitualService();
    _ritualService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ritualService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showDuasOnly ? 'Douas' : 'Rituels'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: widget.showDuasOnly
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
                indicatorColor: AppColors.white,
                indicatorWeight: 3,
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
      data: (rituals) => _buildTimelineView(rituals, 'Aucun rituel trouvé'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildDuasTab() {
    final duasAsync = ref.watch(duasProvider);

    return duasAsync.when(
      data: (duas) => _buildDuasList(duas, 'Aucune dua trouvée'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildTimelineView(List<RitualModel> rituals, String emptyMessage) {
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

    // Trier les rituels par ordre chronologique
    final sortedRituals = List<RitualModel>.from(rituals)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedRituals.length,
        itemBuilder: (context, index) {
          final ritual = sortedRituals[index];
          final isLast = index == sortedRituals.length - 1;
          final settings = ref.watch(settingsProvider);
          final audioLanguage = settings.audioLanguage.name.toLowerCase();
          
          return RitualTimelineItem(
            ritual: ritual,
            isLast: isLast,
            audioLanguage: audioLanguage,
            onMarkAsCompleted: () => _markAsCompleted(ritual),
          );
        },
      ),
    );
  }

  Widget _buildDuasList(List<DuaModel> duas, String emptyMessage) {
    if (duas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
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

    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: duas.length,
        itemBuilder: (context, index) {
          final dua = duas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                dua.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                dua.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to dua details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Détails de: ${dua.title}')),
                );
              },
            ),
          );
        },
      ),
    );
  }


  Future<void> _markAsCompleted(RitualModel ritual) async {
    try {
      await _ritualService.markAsCompleted(ritual);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${ritual.name} marqué comme accompli'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
}