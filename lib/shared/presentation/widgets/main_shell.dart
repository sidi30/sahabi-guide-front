import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../features/bot/presentation/widgets/draggable_bot_button.dart';
import '../../../features/sos/presentation/widgets/sos_overlay.dart';

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// Coquille principale (bottom nav + rail) au-dessus d'un
/// [StatefulNavigationShell] : chaque onglet est une branche dont le Navigator
/// reste vivant (IndexedStack). Passer de la Carte à l'Accueil puis revenir ne
/// réinitialise donc plus GoogleMap / le GPS ni ne refetch l'Accueil.
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Accueil',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: 'Rituels',
      route: '/rituals',
    ),
    NavigationItem(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      label: 'Carte',
      route: '/map',
    ),
    NavigationItem(
      icon: Icons.video_library_outlined,
      selectedIcon: Icons.video_library,
      label: 'Vidéos',
      route: '/videos',
    ),
    // Profil cache en phase pre-Hajj : pas de vrai profil utilisateur tant
    // que le login passeport n'est pas reactive.
  ];

  void _onDestinationSelected(int index) {
    if (index != navigationShell.currentIndex) {
      HapticFeedback.selectionClick();
    }
    // goBranch conserve l'état de chaque branche. Re-toucher l'onglet courant
    // (initialLocation:true) le ramène à sa racine, comportement standard.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  /// Libellé localisé de l'onglet de navigation (barre du bas + rail).
  /// Sans ceci, les labels codés en dur ('Accueil'...) restaient en français
  /// même en mode haoussa/anglais/arabe.
  String _navLabel(BuildContext context, int index) {
    final t = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return t.nav_home;
      case 1:
        return t.nav_rituals;
      case 2:
        return t.nav_map;
      case 3:
        return t.nav_videos;
      default:
        return '';
    }
  }

  String getTitleByIndex(BuildContext context, int index) {
    final t = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return t.appTitle;
      case 1:
        return t.nav_rituals;
      case 2:
        return t.nav_map;
      case 3:
        return t.nav_videos;
      case 4:
        return t.nav_profile;
      default:
        return t.appTitle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = navigationShell.currentIndex;
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Logo Sahabi + Titre
        title: Row(
          children: [
            // Logo Sahabi (discret et professionnel)
            Semantics(
              label: AppLocalizations.of(context)!.accessibility_logo,
              child: Image.asset(
                'assets/favicon/web-app-manifest-logo-192x192.png',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback avec apple-touch-icon
                  return Image.asset(
                    'assets/favicon/apple-touch-icon.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error2, stackTrace2) {
                      return const Icon(Icons.location_on, size: 24);
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Titre
            Expanded(
              child: Text(getTitleByIndex(context, selectedIndex)),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: AppLocalizations.of(context)!.accessibility_settings_button,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              // Écran plein (navigateur racine) avec flèche retour automatique.
              onPressed: () => context.push('/settings'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Row(
        children: [
          // Navigation Rail for larger screens
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: ref.colors.surface,
              selectedIconTheme: IconThemeData(
                color: ref.colors.primary,
                size: 28,
              ),
              selectedLabelTextStyle: TextStyle(
                color: ref.colors.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedIconTheme: IconThemeData(
                color: ref.colors.textLight,
                size: 24,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: ref.colors.textLight,
              ),
              destinations: _navigationItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(_navLabel(context, _navigationItems.indexOf(item))),
                    ),
                  )
                  .toList(),
            ),
          // Divider for navigation rail
          if (isLargeScreen)
            VerticalDivider(
                thickness: 1, width: 1, color: ref.colors.divider),
          // Main content — branche active (Navigator conservé par branche)
          Expanded(child: navigationShell),
        ],
          ),
          // Assistant flottant déplaçable/rangeable : présent sur les 4 onglets
          // principaux (les pages plein écran poussées au-dessus le masquent).
          const DraggableBotButton(),
          // Appel au secours : joignable en un geste depuis Accueil, Rituels,
          // Carte et Vidéos. Absent des écrans d'authentification, qui ne
          // passent pas par cette coquille.
          const SosOverlay(),
        ],
      ),
      // Bottom Navigation for mobile
      bottomNavigationBar: isLargeScreen
          ? null
          : SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                decoration: BoxDecoration(
                  color: ref.colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ref.colors.divider.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ref.colors.shadow.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_navigationItems.length, (index) {
                        final item = _navigationItems[index];
                        final isSelected = selectedIndex == index;

                        return Expanded(
                          child: Semantics(
                            label: _navLabel(context, index),
                            button: true,
                            selected: isSelected,
                            child: InkWell(
                              onTap: () => _onDestinationSelected(index),
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                constraints: const BoxConstraints(minHeight: 52),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ref.colors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isSelected ? item.selectedIcon : item.icon,
                                      size: 24,
                                      color: isSelected
                                          ? ref.colors.textOnPrimary
                                          : ref.colors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _navLabel(context, index),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? ref.colors.textOnPrimary
                                            : ref.colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
