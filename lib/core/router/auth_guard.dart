import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/passport_auth_provider.dart';

/// Garde de routes : approche whitelist.
///
/// Seules les routes explicitement listees dans `publicRoutes` sont
/// accessibles sans connexion. Tout le reste necessite une authentification
/// (pelerin via passeport) ou un mode visiteur (`is_visitor` SharedPref).
///
/// Pages publiques en lecture seule :
///  - Rituels du Hajj (timeline + detail)
///  - Douas / invocations
///  - Copilote IA Hajj (chat)
///  - Carte interactive + POIs (lieux saints, services)
///  - Splash / auth-choice / login / visitor registration
class AuthGuard {
  /// Routes accessibles sans authentification (lecture seule, contenu pedagogique).
  static const List<String> publicRoutes = [
    '/',
    '/auth-choice',
    '/passport-login',
    '/passport-otp',
    '/test-passport-login',
    '/visitor-registration',
    '/rituals',
    '/bot',
    '/map',
  ];

  /// Prefixes publics (pour routes dynamiques type `/rituals/detail/:id`).
  static const List<String> publicPrefixes = [
    '/rituals/',
  ];

  /// Verifie si une route est publique (accessible sans auth).
  static bool isPublicRoute(String path) {
    if (publicRoutes.contains(path)) return true;
    return publicPrefixes.any(path.startsWith);
  }

  /// Pour back-compat : route protegee = non publique.
  static bool isProtectedRoute(String path) => !isPublicRoute(path);

  /// Redirige vers /passport-login si la route demandee est protegee
  /// et que l'utilisateur n'est pas authentifie.
  static String? checkAuth(BuildContext context, GoRouterState state, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated && isProtectedRoute(state.matchedLocation)) {
      return '/passport-login';
    }
    return null;
  }
}

/// Provider pour acceder a l'etat d'authentification dans les guards.
final authGuardProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});
