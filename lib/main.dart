import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahabi_guide/features/profile/presentation/pages/profile_page.dart';
import 'package:sahabi_guide/features/profile/presentation/pages/pilgrim_profile_page.dart';
import 'package:sahabi_guide/features/video/presentation/pages/video_page.dart'
    show VideoPage;
import 'package:sahabi_guide/features/bot/presentation/pages/bot_chat_page.dart';
import 'package:sahabi_guide/features/bot/presentation/pages/bot_debug_page.dart';
import 'package:sahabi_guide/features/dhikr/presentation/pages/dhikr_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection_container.dart';
import 'core/router/auth_guard.dart';
import 'core/utils/app_logger.dart';
import 'core/providers/language_provider.dart';
import 'core/services/language_service.dart';
import 'features/auth/presentation/pages/auth_choice_page.dart';
import 'features/auth/presentation/pages/passport_login_page.dart';
import 'features/auth/presentation/pages/passport_otp_verification_page.dart';
import 'features/auth/presentation/pages/visitor_registration_page.dart';
import 'features/auth/presentation/providers/passport_auth_provider.dart';
import 'features/health/presentation/pages/health_page.dart';
import 'features/connectivity/presentation/pages/connectivity_esim_page.dart';
import 'features/alerts/presentation/pages/alerts_page.dart';
import 'features/emergency_contacts/presentation/pages/emergency_contacts_page.dart';
import 'features/map/presentation/pages/google_map_page.dart' show GoogleMapPage;
import 'features/rituals/presentation/pages/ritual_detail_page.dart';
import 'features/rituals/presentation/pages/rituals_page.dart';
import 'features/rituals/presentation/pages/duas_modern_page.dart';
import 'core/theme/theme.dart';
import 'core/theme/app_color_schemes.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
// import 'shared/presentation/pages/splash_page.dart';  // ❌ Non utilisé
import 'shared/presentation/pages/splash_wrapper.dart';
import 'shared/presentation/widgets/main_shell.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'l10n/app_localizations.dart';
import 'l10n/fallback_material_localizations.dart';

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
  static const String visitorRegistration = '/visitor-registration';

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
  static const String bot = '/bot';
  static const String botDebug = '/bot-debug';
  static const String dhikr = '/dhikr';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable network fetch — NotoSans is bundled in assets/fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // INITIALISATION COMPLÈTE AVANT LE DÉMARRAGE
  // Nécessaire pour que GetIt soit prêt avant l'utilisation
  
  // 1. SharedPreferences (très rapide)
  final prefs = await SharedPreferences.getInstance();

  // 2. Services légers
  final settingsNotifier = SettingsNotifier(prefs: prefs);
  final languageService = LanguageService(prefs);

  // 3. Initialiser TOUTES les dépendances GetIt (critique pour l'auth)
  //    ⚠️ Hive.initFlutter() est appelé dans initializeDependencies()
  try {
    await initializeDependencies();
    AppLogger.debug('✅ Dépendances GetIt initialisées (Hive inclus)');
  } catch (e) {
    AppLogger.error('❌ Erreur initialisation GetIt', error: e);
  }

  // 4. Charger les settings
  try {
    await settingsNotifier.loadSettings();
    AppLogger.debug('✅ Settings chargés');
  } catch (e) {
    AppLogger.error('⚠️ Erreur chargement settings', error: e);
  }

  // Lancer l'app
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

/// Pont entre un Riverpod listenable et le `refreshListenable` de GoRouter.
/// Notifie le routeur à chaque changement d'état d'authentification afin de
/// re-déclencher la logique de redirection (login / logout / session expirée).
class _AuthRouterRefreshNotifier extends ChangeNotifier {
  _AuthRouterRefreshNotifier(this._ref) {
    _removeListener = _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.sessionExpired != next.sessionExpired) {
          notifyListeners();
        }
      },
    ).close;
  }

  final Ref _ref;
  late final VoidCallback _removeListener;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
}

final _authRouterRefreshProvider = Provider<_AuthRouterRefreshNotifier>((ref) {
  final notifier = _AuthRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Le routeur est construit une seule fois et réutilisé entre les rebuilds
  // (locale/thème via AnimatedSwitcher) pour ne pas perdre l'état de navigation.
  late final GoRouter _router = _buildRouter();

  // Build router with auth guard support
  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: MyApp.navigatorKey,
      initialLocation: AppRoutes.splash,
      // Re-déclenche redirect quand l'auth change (login/logout/401).
      refreshListenable: ref.read(_authRouterRefreshProvider),
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);
        final isAuthenticated = authState.isAuthenticated;
        final currentLocation = state.matchedLocation;

        // Session expirée (401) : renvoyer vers le login passeport pour
        // permettre une reconnexion plutôt qu'un écran muet.
        if (authState.sessionExpired &&
            AuthGuard.isProtectedRoute(currentLocation)) {
          return AppRoutes.passportLogin;
        }

        // Phase pre-Hajj : login desactive. Toutes les pages publiques sauf
        // les pages de profil personnel (qui dependent d'un JWT reel).
        if (!isAuthenticated && AuthGuard.isProtectedRoute(currentLocation)) {
          // Renvoie sur /home plutot que /passport-login pour ne pas bloquer
          // la decouverte (le login n'est plus accessible en phase pre-Hajj).
          return '/home';
        }
        return null;
      },
      routes: [
      // Splash Screen (avec vidéo au premier lancement)
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashWrapper(),
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
      GoRoute(
        path: AppRoutes.visitorRegistration,
        builder: (context, state) => const VisitorRegistrationPage(),
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

          // Dhikr Counter Screen
          GoRoute(
            path: AppRoutes.dhikr,
            builder: (context, state) => const DhikrPage(),
          ),

          // Bot Screen
          GoRoute(
            path: AppRoutes.bot,
            builder: (context, state) => const BotChatPage(),
          ),
          
          // Bot Debug Screen (pour diagnostics)
          GoRoute(
            path: AppRoutes.botDebug,
            builder: (context, state) => const BotDebugPage(),
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

  /// Obtenir le thème clair basé sur le schéma de couleurs sélectionné
  ThemeData _buildLightTheme(AppColorScheme colors) {
    return AppTheme.lightTheme(colors);
  }

  /// Obtenir le thème sombre basé sur le schéma de couleurs sélectionné
  ThemeData _buildDarkTheme(AppColorScheme colors) {
    return AppTheme.darkTheme(colors);
  }

  @override
  Widget build(BuildContext context) {
    // Watch for theme and language changes
    final settings = ref.watch(settingsProvider);
    final currentThemeMode = settings.themeMode;
    final colorScheme = settings.currentColorScheme;
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

        // MaterialApp.router se reconstruit en place lors d'un changement de
        // locale/thème : pas d'AnimatedSwitcher/ValueKey (qui forcerait un
        // second MaterialApp.router → double Navigator/Overlay et risque de
        // collision sur le navigatorKey partagé). L'instance GoRouter
        // (`_router`, late final) reste stable, l'état de navigation survit.
        return MaterialApp.router(
          title: 'Sahabi Guide',
          debugShowCheckedModeBanner: false,
          locale: locale,
          themeMode: themeMode,
          theme: _buildLightTheme(colorScheme),
          darkTheme: _buildDarkTheme(colorScheme),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Repli Material/Widgets/Cupertino en anglais POUR le haoussa (`ha`),
            // non fourni par flutter_localizations. Placé AVANT les délégués
            // globaux : pour `ha` il l'emporte, pour fr/en/ar il se désiste.
            ...haFallbackLocalizationsDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
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
        );
      },
    );
  }
}

// Fin du fichier main.dart
// ✅ Toutes les pages ont été déplacées vers leurs propres fichiers
// ✅ auth_choice_page.dart est la seule page d'accueil
