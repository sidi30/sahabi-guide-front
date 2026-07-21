import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../duas/domain/repositories/duas_repository.dart';
import '../../domain/usecases/get_rituals_usecase.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../../features/auth/presentation/providers/passport_auth_provider.dart';
import '../widgets/ritual_timeline_item.dart';
import '../services/ritual_service.dart';
import '../providers/local_progress_provider.dart';
import '../../../../shared/presentation/widgets/profile_gender_badge.dart';
import '../../../../shared/presentation/widgets/skeleton_loader.dart';
import '../widgets/menses_guidance_banner.dart';
import 'dua_detail_page.dart';

final ritualsProvider = FutureProvider.autoDispose<List<RitualModel>>((ref) async {
  ref.keepAlive(); // Keep data when switching tabs
  final useCase = sl<GetRitualsUseCase>();
  final settings = ref.watch(settingsProvider);
  // Récupérer l'ID utilisateur depuis le profil pour filtrer par type de pèlerinage (Hajj/Omra)
  final profile = ref.watch(pilgrimProfileProvider);
  final userId = profile?.id;

  // Genre : pour un compte, le backend le déduit du userId. Pour un anonyme (pas de
  // compte), on l'envoie depuis le choix fait à la connexion (settings.gender, qui
  // reflète la préférence 'pilgrim_gender'). Réactif : un changement déclenche un refetch.
  String? gender = profile?.gender;
  if (gender == null || gender.isEmpty || gender == 'UNSPECIFIED') {
    gender = settings.gender;
  }

  // Langue d'affichage des étapes (résolues côté serveur).
  final lang = settings.locale.locale.languageCode;

  // Le cache Hive n'est pas indexé par genre : si un genre est connu, on force le
  // refetch pour ne pas servir un contenu commun mis en cache avant le choix.
  final hasGender = gender != null && gender.isNotEmpty && gender != 'UNSPECIFIED';

  return await useCase(
    forceRefresh: hasGender,
    userId: userId,
    gender: gender,
    lang: lang,
  );
});

// Provider pour les douas - utilise le bon type DuaModel
final duasProvider = FutureProvider.autoDispose<List<DuaModel>>((ref) async {
  // Pas de keepAlive ici : on laisse autoDispose jouer pour que les douas
  // se rafraîchissent après une synchro (sinon le provider resterait épinglé).
  final repository = sl<DuasRepository>();
  final duas = await repository.getDuas();
  if (duas.isEmpty) {
    AppLogger.debug('DuasProvider: backend returned empty list');
  }
  return duas;
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
    final colors = ref.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showDuasOnly ? 'Douas' : 'Rituels'),
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        bottom: widget.showDuasOnly
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: colors.textOnPrimary,
                unselectedLabelColor: colors.textOnPrimary.withValues(alpha: 0.7),
                indicatorColor: colors.textOnPrimary,
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

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8),
          child: ProfileGenderBadge(),
        ),
        const MensesGuidanceBanner(),
        Expanded(
          child: ritualsAsync.when(
            data: (rituals) => _buildTimelineView(rituals, 'Aucun rituel trouvé'),
            loading: () => const SkeletonList(),
            error: (error, stack) => _buildErrorWidget(error),
          ),
        ),
      ],
    );
  }

  Widget _buildDuasTab() {
    final duasAsync = ref.watch(duasProvider);

    return duasAsync.when(
      data: (duas) => _buildDuasList(duas, 'Aucune dua trouvée'),
      loading: () => const SkeletonList(),
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ritualsProvider);
        await ref.read(ritualsProvider.future);
      },
      child: Container(
      color: const Color(0xFFF8F9FA),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedRituals.length,
        itemBuilder: (context, index) {
          final ritual = sortedRituals[index];
          final isLast = index == sortedRituals.length - 1;
          final settings = ref.watch(settingsProvider);
          final audioLanguage = settings.audioLanguage.code;
          final isDone = ref.watch(localProgressProvider).isRitualDone(ritual.id);

          return RitualTimelineItem(
            ritual: ritual,
            isLast: isLast,
            audioLanguage: audioLanguage,
            isDone: isDone,
            onMarkAsCompleted: () => _markAsCompleted(ritual),
          );
        },
      ),
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
          final isRead = ref.watch(localProgressProvider).isDuaRead(dua.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            color: isRead ? const Color(0xFFECFDF5) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isRead
                  ? const BorderSide(color: Color(0xFF10B981), width: 1.5)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isRead ? const Color(0xFF10B981) : ref.colors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isRead ? Icons.check_circle : Icons.menu_book,
                  color: isRead ? const Color(0xFF10B981) : ref.colors.primary,
                ),
              ),
              title: Text(
                dua.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isRead ? const Color(0xFF065F46) : null,
                ),
              ),
              subtitle: Text(
                dua.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Bascule rapide "lu / non lu" sans ouvrir le détail.
              trailing: IconButton(
                icon: Icon(
                  isRead ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isRead ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                ),
                tooltip: isRead ? 'Marquer non lu' : 'Marquer lu',
                onPressed: () =>
                    ref.read(localProgressProvider.notifier).toggleDua(dua.id),
              ),
              onTap: () {
                // Ouvrir le détail marque la doua comme lue.
                ref.read(localProgressProvider.notifier).setDuaRead(dua.id, true);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DuaDetailPage(dua: dua),
                  ),
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
      // Bascule l'état local (persistant, marche aussi pour les visiteurs).
      final wasDone = ref.read(localProgressProvider).isRitualDone(ritual.id);
      await ref.read(localProgressProvider.notifier).toggleRitual(ritual.id);
      if (!wasDone) {
        await _ritualService.markAsCompleted(ritual); // notif prochain rite
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasDone
                ? '↩️ ${ritual.name} : marquage annulé'
                : '✅ ${ritual.name} marqué comme accompli'),
            backgroundColor:
                wasDone ? const Color(0xFF6B7280) : const Color(0xFF10B981),
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
