import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sahabi_guide/shared/constants/app_colors.dart';
import 'package:sahabi_guide/shared/providers/providers.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final index =
        _navigationItems.indexWhere((item) => item.route == currentRoute);
    if (index != -1 && index != _selectedIndex) {
      //ref.read(navigationIndexProvider.notifier).state = index;

      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_navigationItems[index].route);
  }

  String getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'My Hajj';
      case 1:
        return 'My Duas';
      case 2:
        return 'Map & Location';
      case 3:
        return 'Video Preparation';
      case 4:
        return 'Internet & eSIM';
      case 5:
        return 'My Health';
      case 6:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(getTitleByIndex(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
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
              backgroundColor: AppColors.surface,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primary,
                size: 28,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.textLight,
                size: 24,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.textLight,
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
            const VerticalDivider(
                thickness: 1, width: 1, color: AppColors.divider),
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
                              ? AppColors.primary.withValues(alpha: 0.1)
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
                                  ? AppColors.primary 
                                  : AppColors.textLight,
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
                                    ? AppColors.primary 
                                    : AppColors.textLight,
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
    );
  }
}
