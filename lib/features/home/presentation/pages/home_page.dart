import 'dart:async';

import 'package:sahabi_guide/shared/presentation/widgets/profile_gender_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/location_change_coordinator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/prayer_times_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/presentation/widgets/skeleton_loader.dart';
import '../../../../shared/services/user_location_service.dart';
import '../../../../shared/widgets/location_picker_sheet.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';

final prayerScheduleProvider =
    FutureProvider.autoDispose<DailyPrayerSchedule>((ref) async {
  // autoDispose : les horaires sont ceux du JOUR courant — un provider épinglé
  // continuerait d'afficher ceux de la veille. Le timer recalcule au passage de
  // minuit si l'écran reste ouvert ; un timer échu en arrière-plan se déclenche
  // au resume de l'app (Dart le rattrape), couvrant aussi ce cas.
  final now = DateTime.now();
  final nextMidnight = DateTime(now.year, now.month, now.day + 1);
  final timer = Timer(
    nextMidnight.difference(now) + const Duration(seconds: 1),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);

  final service = sl<PrayerTimesService>();
  final schedule = await service.getTodaySchedule();
  // Schedule daily notifications once we have a schedule.
  // Fire-and-forget — no need to block the UI.
  unawaited(sl<NotificationService>().schedulePrayerNotifications(schedule));
  return schedule;
});

/// Applique un changement de position (horaires + notifications), puis
/// rafraîchit l'affichage.
Future<void> _refreshPrayerLocation(WidgetRef ref, {bool forceGps = false}) async {
  await LocationChangeCoordinator.apply(forceGps: forceGps);
  ref.invalidate(prayerScheduleProvider);
}

final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = sl<HomeRepository>();
  final results = await Future.wait([
    repository.getHomeMenuItems(),
    repository.getCurrentUser(),
  ]);

  return {
    'menuItems': results[0],
    'user': results[1],
  };
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeProvider);

    return Scaffold(
      body: homeData.when(
        data: (data) => _buildHomeContent(context, ref, data),
        loading: () => _buildHomeSkeleton(context),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.errorColor),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(homeProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    // Cast défensif : tolère une valeur absente / d'un type inattendu
    // (ex: réponse backend incomplète) au lieu de planter le rendu.
    final rawMenuItems = data['menuItems'];
    final menuItems = rawMenuItems is List
        ? rawMenuItems.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return RefreshIndicator(
      onRefresh: () async {
        // Recharge l'accueil + les horaires de prière ; on attend le refetch
        // pour garder l'indicateur visible jusqu'à la fin.
        ref.invalidate(prayerScheduleProvider);
        ref.invalidate(homeProvider);
        await ref.read(homeProvider.future);
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Badge de profil (homme/femme) — repère visible dès l'accueil
          const Align(
            alignment: Alignment.centerLeft,
            child: ProfileGenderBadge(),
          ),
          // Welcome Section - Différent selon authentification
          Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authNotifierProvider);

              if (authState.isAuthenticated) {
                return Column(
                  children: [
                    _buildWelcomeSection(context, ref, authState),
                    const SizedBox(height: 24),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildVisitorWelcomeSection(context, ref),
                    const SizedBox(height: 24),
                  ],
                );
              }
            },
          ),

          // Prayer Times Card (real schedule + next prayer)
          _buildPrayerTimesCard(context, ref),

          const SizedBox(height: 24),

          // Menu Grid
          Text(
            'Fonctionnalités',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

            const SizedBox(height: 16),

            _buildMenuGrid(context, ref, menuItems),
          ],
        ),
      ),
    );
  }

  /// Squelette de chargement de l'accueil (carte prière + grille) — remplace le
  /// spinner plein écran pour un ressenti plus fluide.
  Widget _buildHomeSkeleton(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau de bienvenue
            const SkeletonBox(
              height: 120,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            const SizedBox(height: 24),
            // Carte des horaires de prière
            const SkeletonBox(
              height: 150,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(height: 24),
            const SkeletonBox(width: 180, height: 24),
            const SizedBox(height: 16),
            // Grille de fonctionnalités
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: List.generate(
                6,
                (_) => const SkeletonBox(
                  height: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorWelcomeSection(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.9),
            colors.secondary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue sur',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    Text(
                      'SahabiGuide',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explorez notre guide du Hajj et de la Omra',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.explore,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/email-login'),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Petit message chaleureux qui change chaque jour (déterministe : même
  /// message toute la journée, un nouveau le lendemain). Indexé sur le jour de
  /// l'année pour tourner sur toute la liste au fil des jours. Sans emoji
  /// (cohérence icônes vectorielles).
  static const List<String> _blessings = [
    'Que la paix soit avec vous',
    'Qu\'Allah facilite votre journée',
    'Qu\'Allah accepte vos efforts',
    'Chaque pas vous rapproche de Lui',
    'Votre intention est déjà une récompense',
    'Qu\'Allah illumine votre chemin',
    'Un cœur reconnaissant est un cœur comblé',
    'La patience est la clé de la sérénité',
    'Qu\'Allah exauce vos invocations',
    'Prenez soin de vous, vous êtes attendu',
    'Que ce jour vous soit béni',
    'Avancez en confiance, Il est avec vous',
    'Gardez le sourire, la miséricorde est proche',
    'Qu\'Allah préserve votre santé et votre foi',
  ];

  String _dailyBlessing(DateTime now) {
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays; // 0..365
    return _blessings[dayOfYear % _blessings.length];
  }

  Widget _buildWelcomeSection(BuildContext context, WidgetRef ref, AuthState authState) {
    final colors = ref.colors;
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 17) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    // Récupérer le prénom depuis le profil du pèlerin authentifié
    final firstName = authState.pilgrimProfile?.firstName ??
                     authState.pilgrimProfile?.fullName?.split(' ').first ??
                     'Pèlerin';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
                Text(
                  firstName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dailyBlessing(now),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCard(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: scheduleAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Row(
            children: [
              Icon(Icons.location_off, color: context.errorColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Géolocalisation indisponible. Horaires non calculés.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final changed = await LocationPickerSheet.show(context);
                  if (changed) await _refreshPrayerLocation(ref);
                },
                child: const Text('Choisir un lieu'),
              ),
            ],
          ),
          data: (schedule) {
            final current = schedule.current;
            final next = schedule.next;
            final remaining = next == null
                ? '--'
                : _formatRemaining(next.time.difference(DateTime.now()));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prières d\'aujourd\'hui',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualiser ma position',
                      icon: const Icon(Icons.gps_fixed, size: 20),
                      color: colors.primary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await _refreshPrayerLocation(ref, forceGps: true);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Position et horaires actualisés'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  _formatFrenchDate(schedule.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: 10),
                _buildLocationRow(context, ref, schedule),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prière actuelle',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.textSecondaryColor,
                                    ),
                          ),
                          Text(
                            current?.displayName ?? '—',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            current?.formattedTime ?? '--:--',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prochaine prière',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.textSecondaryColor,
                                    ),
                          ),
                          Text(
                            next?.displayName ?? '—',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            next == null ? '--' : 'dans $remaining',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colors.secondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPrayerStrip(context, ref, schedule),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Ligne « d'où viennent ces horaires » : lieu, fraîcheur, fuseau du lieu.
  /// Tapable pour changer de position (GPS ou lieu choisi).
  Widget _buildLocationRow(
      BuildContext context, WidgetRef ref, DailyPrayerSchedule schedule) {
    final loc = schedule.location;
    final approximate = schedule.isFallbackLocation;

    final String label;
    switch (loc.source) {
      case LocationSource.manual:
        label = loc.placeName ?? 'Lieu choisi';
        break;
      case LocationSource.gps:
      case LocationSource.cachedGps:
        label = loc.placeName ?? 'Ma position';
        break;
      case LocationSource.fallback:
        label = 'La Mecque (par défaut)';
        break;
    }

    final String hint;
    switch (loc.source) {
      case LocationSource.manual:
        hint = 'Lieu choisi manuellement';
        break;
      case LocationSource.gps:
        hint = 'GPS · à l\'instant';
        break;
      case LocationSource.cachedGps:
        hint = 'GPS · ${_formatAge(loc.age)}';
        break;
      case LocationSource.fallback:
        hint = 'Position indisponible — horaires approximatifs';
        break;
    }

    final color = approximate ? context.warningColor : context.textSecondaryColor;

    return InkWell(
      onTap: () async {
        final changed = await LocationPickerSheet.show(context);
        if (changed) await _refreshPrayerLocation(ref);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              approximate ? Icons.location_off : Icons.place_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (schedule.timeZoneDiffersFromDevice) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: context.infoColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'heure locale ${schedule.utcOffsetLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: context.infoColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    hint,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  /// Les 5 prières du jour d'un coup d'œil, la prochaine mise en évidence.
  Widget _buildPrayerStrip(
      BuildContext context, WidgetRef ref, DailyPrayerSchedule schedule) {
    final colors = ref.colors;
    final next = schedule.next;

    return Row(
      children: schedule.prayers.map((p) {
        final isNext = next != null && p.name == next.name;
        final isPast = p.time.isBefore(DateTime.now()) && !isNext;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: isNext
                  ? colors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isNext
                    ? colors.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  p.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isPast
                            ? context.textSecondaryColor
                            : context.textPrimaryColor,
                        fontWeight:
                            isNext ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.formattedTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isNext
                            ? colors.primary
                            : (isPast
                                ? context.textSecondaryColor
                                : context.textPrimaryColor),
                        fontWeight:
                            isNext ? FontWeight.bold : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  static const List<String> _frDays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];

  static const List<String> _frMonths = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  String _formatFrenchDate(DateTime d) =>
      '${_frDays[d.weekday - 1]} ${d.day} ${_frMonths[d.month - 1]} ${d.year}';

  String _formatAge(Duration d) {
    if (d.inMinutes < 2) return 'à l\'instant';
    if (d.inMinutes < 60) return 'il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'il y a ${d.inHours} h';
    return 'il y a ${d.inDays} j';
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return '0 min';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }

  Widget _buildMenuGrid(
      BuildContext context, WidgetRef ref, List<Map<String, dynamic>> menuItems) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(context, item);
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> item) {
    final color =
        Color(int.parse(item['color'].substring(1), radix: 16) + 0xFF000000);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          final route = item['route'] as String;
          // Pages de détail (drill-down depuis l'accueil) : push() pour
          // obtenir une flèche retour automatique. Les routes-onglets de la
          // bottom nav (rituels, carte…) restent en go() (remplacement).
          const detailRoutes = {
            '/health',
            '/connectivity',
            '/profile',
            '/rituals/duas',
            '/dhikr',
            '/bot',
          };
          if (detailRoutes.contains(route)) {
            context.push(route);
          } else {
            context.go(route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getIconData(item['icon']),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  item['subtitle'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'schedule':
        return Icons.schedule;
      case 'book':
        return Icons.book;
      case 'location_on':
        return Icons.location_on;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'person':
        return Icons.person;
      case 'wifi':
        return Icons.wifi;
      case 'touch_app':
        return Icons.touch_app;
      case 'smart_toy':
        return Icons.smart_toy;
      default:
        return Icons.help_outline;
    }
  }
}

