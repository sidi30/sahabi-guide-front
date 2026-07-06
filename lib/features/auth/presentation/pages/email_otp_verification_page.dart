import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../providers/passport_auth_provider.dart';

/// Vérification du code reçu par email pour l'auth email (self-signup).
class EmailOtpVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const EmailOtpVerificationPage({super.key, required this.email});

  @override
  ConsumerState<EmailOtpVerificationPage> createState() => _EmailOtpVerificationPageState();
}

class _EmailOtpVerificationPageState extends ConsumerState<EmailOtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  int _countdown = 60;
  bool _canResend = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .verifyEmailCode(widget.email, _otpController.text.trim());

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error ?? 'Vérification échouée'}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Marque l'utilisateur comme connecté (plus visiteur).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_visitor', false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bienvenue !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) context.go('/home');
  }

  Future<void> _handleResend() async {
    await ref.read(authNotifierProvider.notifier).resendEmailCode(widget.email);
    if (!mounted) return;
    final error = ref.read(authNotifierProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error'), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code renvoyé par email'), backgroundColor: Colors.green),
      );
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final colors = ref.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Vérification',
          style: TextStyle(color: colors.primary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Entrez le code',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Code à 6 chiffres envoyé par email à ${widget.email}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: InputDecoration(
                    labelText: 'Code',
                    hintText: '123456',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Le code est requis';
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Le code doit contenir 6 chiffres';
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleVerify(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        : const Text('Valider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: authState.isLoading ? null : _handleResend,
                          child: Text(
                            'Renvoyer le code',
                            style: TextStyle(color: colors.primary, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )
                      : Text(
                          'Renvoyer le code dans ${_countdown}s',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
