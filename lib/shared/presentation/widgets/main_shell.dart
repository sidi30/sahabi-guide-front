import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../features/bot/presentation/widgets/floating_bot_button.dart';

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

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;
  String _currentRoute = '';

  final List<NavigationItem> _navigationItems = const [
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
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profil',
      route: '/profile',
    ),
  ];

  void _updateSelectedIndex() {
    try {
      // Use GoRouter.of instead of GoRouterState.of to avoid hot reload issues
      final router = GoRouter.of(context);
      final currentRoute = router.routerDelegate.currentConfiguration.uri.toString();
      
      final index = _navigationItems.indexWhere((item) => currentRoute.startsWith(item.route));
      
      if (index != -1 && index != _selectedIndex) {
        setState(() {
          _selectedIndex = index;
        });
      }
    } catch (e) {
      // Safely handle cases where router state is not yet available
      // This can happen during hot reload or initial widget build
      debugPrint('⚠️ Router state not available: $e');
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_navigationItems[index].route);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mettre à jour la route actuelle
    try {
      _currentRoute = GoRouterState.of(context).uri.path;
    } catch (e) {
      _currentRoute = '';
    }
    // Mettre à jour l'index de navigation sélectionné
    _updateSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text(getTitleByIndex(context, _selectedIndex)),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: AppLocalizations.of(context)!.accessibility_settings_button,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.go('/settings'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail for larger screens
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
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
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
          // Divider for navigation rail
          if (isLargeScreen)
            VerticalDivider(
                thickness: 1, width: 1, color: ref.colors.divider),
          // Main content
          Expanded(child: widget.child),
        ],
      ),
      // Bottom Navigation for mobile
      bottomNavigationBar: isLargeScreen
          ? null
          : Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navigationItems.length, (index) {
                    final item = _navigationItems[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () => _onDestinationSelected(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ref.colors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              size: 22,
                              color: isSelected
                                  ? ref.colors.textOnPrimary
                                  : ref.colors.textLight,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? ref.colors.textOnPrimary
                                    : ref.colors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
      // Bouton flottant du bot (masqué sur la page bot elle-même)
      floatingActionButton: _shouldShowBotButton()
          ? const FloatingBotButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Détermine si le bouton bot doit être affiché
  bool _shouldShowBotButton() {
    // Masquer le bouton sur toutes les pages bot (/bot, /bot/settings, etc.)
    return !_currentRoute.startsWith('/bot');
  }
}
