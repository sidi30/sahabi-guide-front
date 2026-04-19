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
  GoRouter? _router;
  VoidCallback? _routerListener;

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
    _refreshCurrentRoute();
    _updateSelectedIndex();

    // S'abonner une fois au routerDelegate pour rebuild a chaque navigation.
    // Sans cela, MainShell ne "voit" pas les changements de route interne
    // (ShellRoute ne declenche pas didChangeDependencies sur chaque push).
    final router = GoRouter.of(context);
    if (_router != router) {
      _router?.routerDelegate.removeListener(_routerListener ?? () {});
      _router = router;
      _routerListener = () {
        if (!mounted) return;
        setState(_refreshCurrentRoute);
      };
      router.routerDelegate.addListener(_routerListener!);
    }
  }

  void _refreshCurrentRoute() {
    try {
      _currentRoute = GoRouter.of(context)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;
    } catch (_) {
      _currentRoute = '';
    }
  }

  @override
  void dispose() {
    if (_router != null && _routerListener != null) {
      _router!.routerDelegate.removeListener(_routerListener!);
    }
    super.dispose();
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
      // Bouton flottant du bot : visible UNIQUEMENT sur les onglets
      // principaux (Accueil/Rituels/Carte/Videos/Profil). Cache partout
      // ailleurs — y compris /bot, /settings, /profile/details, etc.
      floatingActionButton: ListenableBuilder(
        listenable: GoRouter.of(context).routeInformationProvider,
        builder: (context, _) {
          final path = GoRouter.of(context)
              .routeInformationProvider
              .value
              .uri
              .path;
          const mainTabs = {'/home', '/rituals', '/map', '/videos', '/profile'};
          final visible = mainTabs.contains(path);
          debugPrint('[MainShell] path="$path" fab=$visible');
          return visible ? const FloatingBotButton() : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Détermine si le bouton bot doit être affiché. _currentRoute est
  /// rafraichi a chaque navigation via le listener du routerDelegate.
  bool _shouldShowBotButton() {
    return !_currentRoute.startsWith('/bot');
  }
}
