import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/passport_auth_provider.dart';

/// Guard pour protéger les routes qui nécessitent une authentification
class AuthGuard {
  /// Vérifie si l'utilisateur est authentifié et redirige si nécessaire
  static String? checkAuth(BuildContext context, GoRouterState state, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    
    // Si l'utilisateur n'est pas authentifié, rediriger vers la page de connexion
    if (!authState.isAuthenticated) {
      return '/passport-login';
    }
    
    // Si authentifié, autoriser l'accès
    return null;
  }
  
  /// Liste des routes protégées (nécessitent une authentification pèlerin)
  /// Les autres routes sont accessibles aux visiteurs
  static const List<String> protectedRoutes = [
    '/profile',           // Profil utilisateur - données personnelles
    '/pilgrim-profile',   // Profil pèlerin détaillé - données personnelles
    '/alerts',            // Alertes - notifications personnelles
    '/emergency-contacts', // Contacts d'urgence - données personnelles
    '/bot-debug',         // Debug bot - admin seulement
  ];
  
  // Routes accessibles aux visiteurs (en lecture seule):
  // - /health - Informations santé générales (pas de données perso)
  // - /connectivity - Voir les offres eSIM (pas d'achat sans compte)
  // - /map - Carte interactive avec POI (lieux sacrés, services)
  
  /// Vérifie si une route nécessite une authentification
  static bool isProtectedRoute(String path) {
    return protectedRoutes.any((route) => path.startsWith(route));
  }
}

/// Provider pour accéder à l'état d'authentification dans les guards
final authGuardProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});




