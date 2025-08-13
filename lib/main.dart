import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sahabi_guide/features/profile/presentation/pages/profile_page.dart';
import 'package:sahabi_guide/features/video/presentation/pages/video_page.dart'
    show VideoPage;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection_container.dart';
import 'features/connectivity/presentation/pages/connectivity_page.dart' show ConnectivityPage;
import 'features/health/presentation/pages/health_page.dart';
import 'features/map/presentation/pages/map_page.dart' show MapPage;
import 'features/rituals/presentation/duas_screen.dart';
import 'shared/constants/app_colors.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/splash/presentation/splash_page.dart';
import 'shared/presentation/widgets/main_shell.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'l10n/app_localizations.dart';

// Simple placeholder widget for unimplemented screens
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title - Page en construction',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

// Application Routes
class AppRoutes {
  // Initial routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Main shell routes
  static const String home = '/home';
  static const String rituals = '/rituals';
  static const String map = '/map';
  static const String videos = '/videos';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Nested routes
  static const String timeline = '/rituals/timeline';
  static const String duas = '/rituals/duas';
  static const String health = '/health';
  static const String connectivity = '/connectivity';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create settings notifier and load initial settings
  final settingsNotifier = SettingsNotifier(prefs: prefs);
  await settingsNotifier.loadSettings();

  runApp(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith((ref) => settingsNotifier),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Keep router stable across rebuilds to avoid resetting navigation
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding Screen
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main Shell with Bottom Navigation - Wraps all main screens including home
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home Screen - Now wrapped in MainShell
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),

          // Rituals Section
          GoRoute(
            path: AppRoutes.rituals,
            redirect: (context, state) => AppRoutes.timeline,
          ),

          // duas 
          GoRoute(
            path: AppRoutes.duas,
            builder: (context, state) => const DuasScreen(),
          ),
          GoRoute(
            path: AppRoutes.health,
            builder: (context, state) => const HealthPage(),
          ),

          GoRoute(
            path: AppRoutes.connectivity,
            builder: (context, state) => const ConnectivityPage(),
          ),

          GoRoute(
            path: AppRoutes.timeline,
            builder: (context, state) => const TimelineScreen(),
          ),
          GoRoute(
            path: AppRoutes.duas,
            builder: (context, state) => const DuasScreen(),
          ),

          // Map Screen
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const MapPage(),
          ),

          // Videos Screen
          GoRoute(
            path: AppRoutes.videos,
            builder: (context, state) => const VideoPage(),
          ),

          // Profile Screen
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),

          // Settings Screen
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page non trouvée: ${state.uri.path}'),
      ),
    ),
  );

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.surfaceColor,
        error: AppColors.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.appBarText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.appBarIcon,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomNavBackground,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for theme changes
    final settings = ref.watch(settingsProvider);
    final currentThemeMode = settings.themeMode;
    final currentLocale = settings.locale.locale;

    // Use a Builder to ensure the theme updates without rebuilding the entire app
    return Builder(
      builder: (context) {
        // Convert AppThemeMode to ThemeMode
        final themeMode = switch (currentThemeMode) {
          AppThemeMode.dark => ThemeMode.dark,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.system =>
            Theme.of(context).platform == TargetPlatform.iOS
                //  || Theme.of(context).platform == TargetPlatform.macOS
                ? ThemeMode.system
                : ThemeMode.light,
        };

        return MaterialApp.router(
          title: 'Sahabi Guide',
          debugShowCheckedModeBanner: false,
          locale: currentLocale,
          themeMode: themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
          // Ensure the app updates when locale changes
          builder: (context, child) {
            // This makes the app update when the locale changes
            return Localizations.override(
              context: context,
              locale: currentLocale,
              child: child!,
            );
          },
        );
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String selectedRole = '';
  String selectedLanguage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A9D8F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Hajj Companion',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Your guide for a blessed and seamless pilgrimage.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'I am a...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildRoleButton(
                          icon: Icons.person,
                          title: 'Pilgrim',
                          isSelected: selectedRole == 'pilgrim',
                          onTap: () => setState(() => selectedRole = 'pilgrim'),
                        ),

                        const SizedBox(height: 12),

                        _buildRoleButton(
                          icon: Icons.people,
                          title: 'Guide',
                          isSelected: selectedRole == 'guide',
                          onTap: () => setState(() => selectedRole = 'guide'),
                        ),

                        const SizedBox(height: 30),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Language',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildLanguageButton(
                                icon: Icons.volume_up,
                                title: 'Hausa',
                                isSelected: selectedLanguage == 'hausa',
                                onTap: () =>
                                    setState(() => selectedLanguage = 'hausa'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildLanguageButton(
                                icon: Icons.volume_up,
                                title: 'Djerma',
                                isSelected: selectedLanguage == 'djerma',
                                onTap: () =>
                                    setState(() => selectedLanguage = 'djerma'),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: selectedRole.isNotEmpty &&
                                      selectedLanguage.isNotEmpty
                                  ? () => context.go(AppRoutes.home)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FC3F7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
              : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3557) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3557) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hajj Guide',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              icon: Icons.luggage,
              title: 'My Hajj',
              color: const Color(0xFF4FC3F7),
              onTap: () => context.push(AppRoutes.timeline),
            ),
            _buildMenuCard(
              icon: Icons.favorite_border,
              title: 'My Duas',
              color: const Color(0xFF4FC3F7),
              onTap: () => context.push(AppRoutes.duas),
            ),
            _buildMenuCard(
              icon: Icons.map_outlined,
              title: 'Map & Location',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran de la carte
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.play_circle_outline,
              title: 'Video\nPreparation',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran des vidéos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.favorite,
              title: 'My Health',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran de santé
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.account_circle_outlined,
              title: 'Profile &\nEmergency',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran de profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3557),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Hajj Timeline',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTimelineItem('Ihram', 'Enter the sacred state', true),
          _buildTimelineItem(
              'Tawaf al-Qudum', 'Arrival circumambulation', true),
          _buildTimelineItem('Sa\'i', 'Walking between hills', false),
          _buildTimelineItem('Day of Tarwiyah', 'Proceed to Mina', false),
          _buildTimelineItem('Day of Arafah', 'Stand at Mount Arafah', false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String description, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF2A9D8F) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D3557),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

