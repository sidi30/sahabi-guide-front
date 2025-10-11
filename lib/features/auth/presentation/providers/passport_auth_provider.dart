import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/passport_auth_models.dart';
import '../../data/repositories/passport_auth_repository_impl.dart';
import '../../domain/usecases/passport_auth_usecases.dart';

// Provider pour le repository
final passportAuthRepositoryProvider = Provider<PassportAuthRepository>((ref) {
  return sl<PassportAuthRepository>();
});

// Provider pour les use cases
final passportLoginUseCaseProvider = Provider<PassportLoginUseCase>((ref) {
  final repository = ref.watch(passportAuthRepositoryProvider);
  return PassportLoginUseCase(repository);
});

final passportVerifyOtpUseCaseProvider = Provider<PassportVerifyOtpUseCase>((ref) {
  final repository = ref.watch(passportAuthRepositoryProvider);
  return PassportVerifyOtpUseCase(repository);
});

final passportResendOtpUseCaseProvider = Provider<PassportResendOtpUseCase>((ref) {
  final repository = ref.watch(passportAuthRepositoryProvider);
  return PassportResendOtpUseCase(repository);
});

final passportLogoutUseCaseProvider = Provider<PassportLogoutUseCase>((ref) {
  final repository = ref.watch(passportAuthRepositoryProvider);
  return PassportLogoutUseCase(repository);
});

final getPilgrimProfileUseCaseProvider = Provider<GetPilgrimProfileUseCase>((ref) {
  final repository = ref.watch(passportAuthRepositoryProvider);
  return GetPilgrimProfileUseCase(repository);
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.watch(passportAuthRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
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
    state = state.copyWith(isLoading: true, error: null);
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await verifyOtpUseCase(passportNo, otpCode);
      if (response.success && response.token != null) {
        final profile = await getPilgrimProfileUseCase();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: response.token,
          pilgrimProfile: profile,
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
