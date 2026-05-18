import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/passport_auth_provider.dart';

/// Garde de routes : approche whitelist permissive.
///
/// Phase de pre-Hajj : le login est desactive temporairement. Toutes les
/// pages sont accessibles librement pour decouverte. Seules les pages de
/// profil personnel restent fermees (elles dependent de donnees JWT).
///
/// A reactiver completement quand commence la saison du Hajj.
class AuthGuard {
  /// Routes qui restent fermees sans authentification reelle (passeport).
  /// Tout le reste est public.
  static const List<String> protectedRoutes = [
    '/profile',
    '/pilgrim-profile',
  ];

  /// Verifie si une route necessite une authentification reelle.
  static bool isProtectedRoute(String path) {
    return protectedRoutes.any((route) => path.startsWith(route));
  }

  /// Pour back-compat.
  static bool isPublicRoute(String path) => !isProtectedRoute(path);

  /// Redirige vers /home si la route est fermee et l'utilisateur non authentifie.
  /// (On evite /passport-login pour ne pas bloquer la decouverte.)
  static String? checkAuth(BuildContext context, GoRouterState state, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated && isProtectedRoute(state.matchedLocation)) {
      return '/home';
    }
    return null;
  }
}

/// Provider pour acceder a l'etat d'authentification dans les guards.
final authGuardProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});
