import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sahabi_guide/features/profile/presentation/pages/profile_page.dart';
import 'package:sahabi_guide/features/profile/presentation/pages/pilgrim_profile_page.dart';
import 'package:sahabi_guide/features/video/presentation/pages/video_page.dart'
    show VideoPage;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection_container.dart';
import 'core/router/auth_guard.dart';
import 'core/providers/language_provider.dart';
import 'core/services/language_service.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/pages/auth_choice_page.dart';
import 'features/auth/presentation/pages/passport_login_page.dart';
import 'features/auth/presentation/pages/passport_otp_verification_page.dart';
import 'features/auth/presentation/providers/passport_auth_provider.dart';
import 'features/connectivity/presentation/pages/connectivity_page.dart' show ConnectivityPage;
import 'features/health/presentation/pages/health_page.dart';
import 'features/connectivity/presentation/pages/connectivity_esim_page.dart';
import 'features/alerts/presentation/pages/alerts_page.dart';
import 'features/emergency_contacts/presentation/pages/emergency_contacts_page.dart';
import 'features/map/presentation/pages/google_map_page.dart' show GoogleMapPage;
import 'features/rituals/presentation/pages/ritual_detail_page.dart';
import 'features/rituals/presentation/pages/rituals_page.dart';
import 'features/rituals/presentation/pages/duas_modern_page.dart';
import 'shared/constants/app_colors.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'shared/presentation/pages/splash_page.dart';
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
  // ❌ onboarding supprimé - redirection directe vers auth-choice

  // Authentication routes
  static const String authChoice = '/auth-choice';
  static const String passportLogin = '/passport-login';
  static const String passportOtp = '/passport-otp';
  static const String testPassportLogin = '/test-passport-login';

  // Main shell routes
  static const String home = '/home';
  static const String rituals = '/rituals';
  static const String map = '/map';
  static const String videos = '/videos';
  static const String profile = '/profile';
  static const String pilgrimProfile = '/pilgrim-profile';
  static const String settings = '/settings';

  // Nested routes
  static const String timeline = '/rituals/timeline';
  static const String duas = '/rituals/duas';
  static const String ritualDetail = '/rituals/detail/:id';
  static const String health = '/health';
  static const String connectivity = '/connectivity';
  static const String alerts = '/alerts';
  static const String emergencyContacts = '/emergency-contacts';
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

  // Create language service
  final languageService = LanguageService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith((ref) => settingsNotifier),
        languageServiceProvider.overrideWithValue(languageService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  // Build router with auth guard support
  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        // Vérifier l'état d'authentification
        final isAuthenticated = ref.read(authNotifierProvider).isAuthenticated;
        final currentLocation = state.matchedLocation;
        
        // ✅ Si déjà authentifié et sur splash ou auth-choice, rediriger vers home
        if (isAuthenticated && (currentLocation == '/' || currentLocation == '/auth-choice')) {
          AppLogger.info('🔄 Utilisateur authentifié détecté, redirection vers /home');
          return '/home';
        }
        
        // Si l'utilisateur essaie d'accéder à une page protégée sans être authentifié
        if (!isAuthenticated && AuthGuard.isProtectedRoute(currentLocation)) {
          return '/passport-login';
        }
        
        // Pas de redirection nécessaire
        return null;
      },
      routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Choice Screen (page principale après splash)
      GoRoute(
        path: AppRoutes.authChoice,
        builder: (context, state) => const AuthChoicePage(),
      ),

      // Authentication routes
      GoRoute(
        path: AppRoutes.passportLogin,
        builder: (context, state) => const PassportLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.testPassportLogin,
        builder: (context, state) => const PassportLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.passportOtp,
        builder: (context, state) {
          final passportNo = state.extra as String? ?? '';
          return PassportOtpVerificationPage(passportNo: passportNo);
        },
      ),

      // Pilgrim Profile Screen (outside shell) - PROTÉGÉ
      GoRoute(
        path: AppRoutes.pilgrimProfile,
        builder: (context, state) => const PilgrimProfilePage(),
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

          // Data-backed timeline and duas
          GoRoute(
            path: AppRoutes.timeline,
            builder: (context, state) => const RitualsPage(),
          ),
          GoRoute(
            path: AppRoutes.duas,
            builder: (context, state) => const DuasModernPage(),
          ),

          // Ritual detail page
          GoRoute(
            path: AppRoutes.ritualDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return RitualDetailPage(ritualId: id);
            },
          ),

          // Other sections - PROTÉGÉES
          GoRoute(
            path: AppRoutes.health,
            builder: (context, state) => const HealthPage(),
          ),
          GoRoute(
            path: AppRoutes.connectivity,
            builder: (context, state) => const ConnectivityEsimPage(),
          ),
          GoRoute(
            path: AppRoutes.alerts,
            builder: (context, state) => const AlertsPage(),
          ),
          GoRoute(
            path: AppRoutes.emergencyContacts,
            builder: (context, state) => const EmergencyContactsPage(),
          ),

          // Map Screen - PROTÉGÉE
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const GoogleMapPage(),
          ),

          // Videos Screen
          GoRoute(
            path: AppRoutes.videos,
            builder: (context, state) => const VideoPage(),
          ),

          // Profile Screen - PROTÉGÉE
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
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
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
    // Watch for theme and language changes
    final settings = ref.watch(settingsProvider);
    final currentThemeMode = settings.themeMode;
    final locale = ref.watch(languageProvider);

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

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: MaterialApp.router(
            key: ValueKey(locale.languageCode), // Force rebuild avec animation
            title: 'Sahabi Guide',
            debugShowCheckedModeBanner: false,
            locale: locale,
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
          routerConfig: _buildRouter(ref),
          // Ensure the app updates when locale changes + support RTL
          builder: (context, child) {
            return Directionality(
              textDirection: LanguageService.getTextDirection(locale),
              child: Localizations.override(
                context: context,
                locale: locale,
                child: child!,
              ),
            );
          },
          ),
        );
      },
    );
  }
}

// Fin du fichier main.dart
// ✅ Toutes les pages ont été déplacées vers leurs propres fichiers
// ✅ auth_choice_page.dart est la seule page d'accueil
