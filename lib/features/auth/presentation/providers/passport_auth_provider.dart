import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
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

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.pilgrimProfile,
    this.error,
    this.passportNo,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    PilgrimProfile? pilgrimProfile,
    String? error,
    String? passportNo,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      pilgrimProfile: pilgrimProfile ?? this.pilgrimProfile,
      error: error ?? this.error,
      passportNo: passportNo ?? this.passportNo,
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

  AuthNotifier({
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.logoutUseCase,
    required this.getPilgrimProfileUseCase,
    required this.checkAuthStatusUseCase,
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

  Future<void> verifyOtp(String passportNo, String otpCode) async {
    AppLogger.debug('[AuthNotifier] Début vérification OTP...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      AppLogger.debug('[AuthNotifier] Appel verifyOtpUseCase...');
      final response = await verifyOtpUseCase(passportNo, otpCode);
      AppLogger.debug('[AuthNotifier] Réponse reçue: success=${response.success}, token=${response.token != null}');

      if (response.success && response.token != null) {
        AppLogger.info('[AuthNotifier] Authentification réussie ! Token présent.');
        // Authentification réussie - on définit l'état même si le profil échoue
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: response.token,
        );

        AppLogger.debug('[AuthNotifier] Récupération du profil...');
        // Essayer de récupérer le profil (ne bloque pas l'authentification si ça échoue)
        try {
          final profile = await getPilgrimProfileUseCase();
          state = state.copyWith(pilgrimProfile: profile);
          AppLogger.info('[AuthNotifier] Profil récupéré: ${profile?.fullName ?? "N/A"}');
        } catch (e) {
          AppLogger.warning('[AuthNotifier] Impossible de récupérer le profil: $e');
          // On continue quand même, l'authentification est valide
        }
      } else {
        AppLogger.warning('[AuthNotifier] Échec auth: ${response.message}');
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      AppLogger.error('[AuthNotifier] Exception lors de la vérification OTP', error: e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
}

// Provider pour le notifier d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(passportLoginUseCaseProvider),
    verifyOtpUseCase: ref.watch(passportVerifyOtpUseCaseProvider),
    resendOtpUseCase: ref.watch(passportResendOtpUseCaseProvider),
    logoutUseCase: ref.watch(passportLogoutUseCaseProvider),
    getPilgrimProfileUseCase: ref.watch(getPilgrimProfileUseCaseProvider),
    checkAuthStatusUseCase: ref.watch(checkAuthStatusUseCaseProvider),
  );
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
