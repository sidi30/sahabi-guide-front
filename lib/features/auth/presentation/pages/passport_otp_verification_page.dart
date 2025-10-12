import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/passport_auth_provider.dart';

class PassportOtpVerificationPage extends ConsumerStatefulWidget {
  final String passportNo;

  const PassportOtpVerificationPage({
    super.key,
    required this.passportNo,
  });

  @override
  ConsumerState<PassportOtpVerificationPage> createState() => _PassportOtpVerificationPageState();
}

class _PassportOtpVerificationPageState extends ConsumerState<PassportOtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _canResend = true;
          }
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.verifyOtp(widget.passportNo, _otpController.text.trim());

    // Attendre un peu pour que l'état soit bien mis à jour
    await Future.delayed(const Duration(milliseconds: 100));
    
    final authState = ref.read(authNotifierProvider);
    
    if (!mounted) return;
    
    if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${authState.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (authState.isAuthenticated) {
      // Afficher le message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion réussie !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Attendre que le snackbar s'affiche puis naviguer
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Utiliser pushReplacement pour éviter le retour arrière
        context.go('/home');
        print('✅ Navigation vers /home après authentification réussie');
      }
    } else {
      print('⚠️ Authentification: isAuthenticated=${authState.isAuthenticated}, error=${authState.error}');
    }
  }

  Future<void> _handleResendOtp() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.resendOtp(widget.passportNo);

    final authState = ref.read(authNotifierProvider);
    
    if (authState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${authState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code OTP renvoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Vérification OTP',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Icône et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Vérification du code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entrez le code à 6 chiffres envoyé au numéro associé au passeport ${widget.passportNo}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Champ OTP
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Code OTP',
                    hintText: '123456',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le code OTP est requis';
                    }
                    if (value.length != 6) {
                      return 'Le code OTP doit contenir 6 chiffres';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'Le code OTP ne doit contenir que des chiffres';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleVerifyOtp(),
                ),

                const SizedBox(height: 32),

                // Bouton de vérification
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Vérifier',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de renvoi
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: authState.isLoading ? null : _handleResendOtp,
                          child: const Text(
                            'Renvoyer le code',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          'Renvoyer le code dans ${_countdown}s',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                ),

                const Spacer(),

                // Informations supplémentaires
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Le code OTP expire dans 5 minutes. Si vous ne l\'avez pas reçu, vérifiez vos SMS ou contactez le support.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
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
