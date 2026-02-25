import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/notification_snackbar.dart';

final passportLoginProvider = StateNotifierProvider<PassportLoginNotifier, PassportLoginState>((ref) {
  return PassportLoginNotifier(sl<AuthService>());
});

class PassportLoginPage extends ConsumerStatefulWidget {
  const PassportLoginPage({super.key});

  @override
  ConsumerState<PassportLoginPage> createState() => _PassportLoginPageState();
}

class _PassportLoginPageState extends ConsumerState<PassportLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passportController = TextEditingController();

  @override
  void dispose() {
    _passportController.dispose();
    super.dispose();
  }

  void _loginWithPassport() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(passportLoginProvider.notifier);
      await notifier.loginWithPassport(_passportController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(passportLoginProvider);

    ref.listen<PassportLoginState>(passportLoginProvider, (previous, next) {
      if (next.requiresOtp) {
        context.push('/passport-otp', extra: _passportController.text);
      } else if (next.isSuccess) {
        context.go(AppConstants.homeRoute);
      } else if (next.errorMessage != null) {
        if (next.isPassportNotFound) {
          // Afficher une boîte de dialogue pour passeport non enregistré
          NotificationService.showErrorDialog(
            context,
            title: 'Inscription requise',
            message: next.errorMessage ?? 'Vous n\'êtes pas inscrit. Rapprochez-vous de votre agence ou contactez-nous.',
            actionText: 'Compris',
          );
        } else {
          // Afficher une notification pour les autres erreurs
          NotificationService.showError(context, next.errorMessage!);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Logo Sahabi
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/favicon/web-app-manifest-logo-192x192.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/favicon/apple-touch-icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Icon(
                              Icons.location_on,
                              size: 50,
                              color: ref.colors.primary,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Connexion par Passeport',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ref.colors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Entrez votre numéro de passeport pour vous connecter',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ref.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Passport Number Field
                TextFormField(
                  controller: _passportController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de passeport',
                    hintText: 'Entrez votre numéro de passeport',
                    prefixIcon: Icon(Icons.document_scanner_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Numéro de passeport requis';
                    }
                    if (value.length < 6) {
                      return 'Le numéro de passeport doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: loginState.isLoading ? null : _loginWithPassport,
                  child: loginState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Se connecter'),
                ),

                const SizedBox(height: 24),

                // Info Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ref.colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: ref.colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Information',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Un code de vérification sera envoyé par SMS après la saisie de votre numéro de passeport.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Option pour accéder sans connexion
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text(
                      'Accéder sans se connecter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
  }
}

class PassportLoginNotifier extends StateNotifier<PassportLoginState> {
  final AuthService _authService;

  PassportLoginNotifier(this._authService) : super(const PassportLoginState());

  Future<void> loginWithPassport(String passportNo) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isPassportNotFound: false,
      requiresOtp: false,
    );

    try {
      final result = await _authService.requestOtp(passportNo);
      
      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          requiresOtp: true,
          passportNo: passportNo,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          requiresOtp: false,
          errorMessage: result.message,
          isPassportNotFound: result.isPassportNotFound,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        requiresOtp: false,
        errorMessage: 'Erreur de connexion: ${e.toString()}',
        isPassportNotFound: false,
      );
    }
  }
}

class PassportLoginState {
  final bool isLoading;
  final bool isSuccess;
  final bool requiresOtp;
  final bool isPassportNotFound;
  final String? errorMessage;
  final String? passportNo;

  const PassportLoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.requiresOtp = false,
    this.isPassportNotFound = false,
    this.errorMessage,
    this.passportNo,
  });

  PassportLoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? requiresOtp,
    bool? isPassportNotFound,
    String? errorMessage,
    String? passportNo,
  }) {
    return PassportLoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      requiresOtp: requiresOtp ?? this.requiresOtp,
      isPassportNotFound: isPassportNotFound ?? this.isPassportNotFound,
      errorMessage: errorMessage,
      passportNo: passportNo ?? this.passportNo,
    );
  }
}
