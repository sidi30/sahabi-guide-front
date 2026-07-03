import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/passport_auth_models.dart';
import '../../data/repositories/passport_auth_repository_impl.dart';
import '../../domain/usecases/passport_auth_usecases.dart';

// Provider pour le repository
final passportAuthRepositoryProvider = Provider<PassportAuthRepository>((ref) {
  return sl<PassportAuthRepository>();
});

// Providers pour les use cases - Utilise GetIt directement pour éviter les doublons
final passportLoginUseCaseProvider = Provider<PassportLoginUseCase>((ref) {
  return sl<PassportLoginUseCase>();
});

final passportVerifyOtpUseCaseProvider = Provider<PassportVerifyOtpUseCase>((ref) {
  return sl<PassportVerifyOtpUseCase>();
});

final passportResendOtpUseCaseProvider = Provider<PassportResendOtpUseCase>((ref) {
  return sl<PassportResendOtpUseCase>();
});

final passportLogoutUseCaseProvider = Provider<PassportLogoutUseCase>((ref) {
  return sl<PassportLogoutUseCase>();
});

final getPilgrimProfileUseCaseProvider = Provider<GetPilgrimProfileUseCase>((ref) {
  return sl<GetPilgrimProfileUseCase>();
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return sl<CheckAuthStatusUseCase>();
});

// État d'authentification
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final PilgrimProfile? pilgrimProfile;
  final String? error;
  final String? passportNo;

  /// Vrai quand le serveur a renvoyé un 401 sur un token précédemment valide.
  /// Le routeur peut réagir pour forcer une reconnexion.
  final bool sessionExpired;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.pilgrimProfile,
    this.error,
    this.passportNo,
    this.sessionExpired = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    PilgrimProfile? pilgrimProfile,
    String? error,
    String? passportNo,
    bool? sessionExpired,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      pilgrimProfile: pilgrimProfile ?? this.pilgrimProfile,
      // error est assigné directement (pas de ?? this.error) afin que
      // copyWith(error: null) puisse réellement effacer l'erreur.
      error: error,
      passportNo: passportNo ?? this.passportNo,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}

// Notifier pour l'état d'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final PassportLoginUseCase loginUseCase;
  final PassportVerifyOtpUseCase verifyOtpUseCase;
  final PassportResendOtpUseCase resendOtpUseCase;
  final PassportLogoutUseCase logoutUseCase;
  final GetPilgrimProfileUseCase getPilgrimProfileUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  // Repository injecte pour les chemins telephone + suppression de compte
  // (pas de use case dedie : meme flux, on reste minimal).
  final PassportAuthRepository repository;

  AuthNotifier({
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.logoutUseCase,
    required this.getPilgrimProfileUseCase,
    required this.checkAuthStatusUseCase,
    required this.repository,
  }) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await checkAuthStatusUseCase();
      if (isAuthenticated) {
        final profile = await getPilgrimProfileUseCase();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          pilgrimProfile: profile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String passportNo) async {
    state = state.copyWith(isLoading: true, error: null);  // Auto-clear error
    try {
      final response = await loginUseCase(passportNo);
      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          passportNo: passportNo,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Vérifie l'OTP et retourne `true` si l'authentification a réussi.
  /// La page peut brancher directement sur ce résultat sans relire l'état
  /// (évite la course liée à un Future.delayed arbitraire).
  Future<bool> verifyOtp(String passportNo, String otpCode) async {
    if (kDebugMode) AppLogger.debug('[AuthNotifier] Début vérification OTP...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (kDebugMode) AppLogger.debug('[AuthNotifier] Appel verifyOtpUseCase...');
      final response = await verifyOtpUseCase(passportNo, otpCode);
      if (kDebugMode) AppLogger.debug('[AuthNotifier] Réponse reçue: success=${response.success}, token=${response.token != null}');

      if (response.success && response.token != null) {
        if (kDebugMode) AppLogger.info('[AuthNotifier] Authentification réussie ! Token présent.');
        // Authentification réussie - on définit l'état même si le profil échoue
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: response.token,
        );

        if (kDebugMode) AppLogger.debug('[AuthNotifier] Récupération du profil...');
        // Essayer de récupérer le profil (ne bloque pas l'authentification si ça échoue)
        try {
          final profile = await getPilgrimProfileUseCase();
          state = state.copyWith(pilgrimProfile: profile);
          if (kDebugMode) AppLogger.info('[AuthNotifier] Profil récupéré: ${profile?.fullName ?? "N/A"}');
        } catch (e) {
          AppLogger.warning('[AuthNotifier] Impossible de récupérer le profil: $e');
          // On continue quand même, l'authentification est valide
        }
        return true;
      } else {
        AppLogger.warning('[AuthNotifier] Échec auth: ${response.message}');
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('[AuthNotifier] Exception lors de la vérification OTP', error: e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> resendOtp(String passportNo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await resendOtpUseCase(passportNo);
      if (response.success) {
        state = state.copyWith(
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await logoutUseCase();
      state = const AuthState();
    } catch (e) {
      // Même en cas d'erreur, on nettoie l'état local
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // ── Auth par email (self-signup passwordless) ────────────────────────────

  /// Demande un code OTP par email. Retourne `true` si le code a été envoyé
  /// (crée le compte à la volée si l'email est nouveau).
  Future<bool> requestEmailCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await repository.requestEmailCode(email);
      if (response.success) {
        state = state.copyWith(isLoading: false, passportNo: null);
        return true;
      }
      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  /// Vérifie le code email et authentifie. Retourne `true` en cas de succès.
  Future<bool> verifyEmailCode(String email, String otpCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await repository.verifyEmailCode(email, otpCode);
      if (response.success && response.token != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: response.token,
        );
        try {
          final profile = await getPilgrimProfileUseCase(forceRefresh: true);
          state = state.copyWith(pilgrimProfile: profile);
        } catch (e) {
          AppLogger.warning('[AuthNotifier] Profil indisponible après login email: $e');
        }
        return true;
      }
      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> resendEmailCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await repository.resendEmailCode(email);
      state = state.copyWith(
        isLoading: false,
        error: response.success ? null : response.message,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Suppression de compte in-app ─────────────────────────────────────────

  /// Supprime définitivement le compte du porteur du token, puis réinitialise
  /// l'état local (déconnexion). Retourne `true` si la suppression a réussi.
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteAccount();
      state = const AuthState(); // non authentifié, session nettoyée
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  /// Appelé sur un 401 réseau : le token a déjà été effacé par DioClient.
  /// On bascule l'état en non authentifié + session expirée pour que le
  /// routeur force une reconnexion (au lieu d'écrans muets en échec).
  void handleSessionExpired() {
    if (!state.isAuthenticated && state.sessionExpired) return;
    state = const AuthState(sessionExpired: true);
  }
}

// Provider pour le notifier d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    loginUseCase: ref.watch(passportLoginUseCaseProvider),
    verifyOtpUseCase: ref.watch(passportVerifyOtpUseCaseProvider),
    resendOtpUseCase: ref.watch(passportResendOtpUseCaseProvider),
    logoutUseCase: ref.watch(passportLogoutUseCaseProvider),
    getPilgrimProfileUseCase: ref.watch(getPilgrimProfileUseCaseProvider),
    checkAuthStatusUseCase: ref.watch(checkAuthStatusUseCaseProvider),
    repository: ref.watch(passportAuthRepositoryProvider),
  );

  // Recovery sur 401 : DioClient efface le token puis nous notifie afin de
  // basculer en session expirée et forcer une reconnexion.
  final dioClient = sl<DioClient>();
  dioClient.onUnauthorized = notifier.handleSessionExpired;
  ref.onDispose(() => dioClient.onUnauthorized = null);

  return notifier;
});

// Providers utilitaires
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final pilgrimProfileProvider = Provider<PilgrimProfile?>((ref) {
  return ref.watch(authNotifierProvider).pilgrimProfile;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).token;
});
