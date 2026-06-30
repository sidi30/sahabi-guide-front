import 'dart:async';

import 'package:sahabi_guide/shared/presentation/widgets/profile_gender_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/prayer_times_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';

final prayerScheduleProvider =
    FutureProvider<DailyPrayerSchedule>((ref) async {
  final service = sl<PrayerTimesService>();
  final schedule = await service.getTodaySchedule();
  // Schedule daily notifications once we have a schedule.
  // Fire-and-forget — no need to block the UI.
  unawaited(sl<NotificationService>().schedulePrayerNotifications(schedule));
  return schedule;
});

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
        loading: () => const Center(child: CircularProgressIndicator()),
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

    return SingleChildScrollView(
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
                  onPressed: () => context.push('/passport-login'),
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
                  'Que la paix soit avec vous',
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
                    Text(
                      'Prières d\'aujourd\'hui',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
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
              ],
            );
          },
        ),
      ),
    );
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

