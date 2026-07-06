import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../providers/passport_auth_provider.dart';

/// Inscription / connexion par EMAIL (self-signup passwordless).
///
/// Chemin par défaut pour un pèlerin individuel : il saisit son email, reçoit
/// un code par mail, le valide -> compte créé/connecté. Aucune donnée sensible
/// (passeport, etc.) n'est requise (conformité Apple 5.1.1(v)). Le login par
/// passeport (comptes agence) reste accessible via un lien discret.
class EmailLoginPage extends ConsumerStatefulWidget {
  const EmailLoginPage({super.key});

  @override
  ConsumerState<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends ConsumerState<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.selectionClick();
    final email = _emailController.text.trim();
    final sent = await ref.read(authNotifierProvider.notifier).requestEmailCode(email);
    if (!mounted) return;
    if (sent) {
      context.push('/email-otp', extra: email);
    } else {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Impossible d\'envoyer le code. Réessayez.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final colors = ref.colors;

    return Scaffold(
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
                const SizedBox(height: 48),

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
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.location_on,
                        size: 50,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Créer un compte / Se connecter',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez votre adresse email. Nous vous enverrons un code par email.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Adresse email',
                    hintText: 'vous@exemple.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Adresse email requise';
                    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!re.hasMatch(v)) return 'Adresse email invalide';
                    return null;
                  },
                  onFieldSubmitted: (_) => _requestCode(),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _requestCode,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Recevoir le code'),
                ),

                const SizedBox(height: 24),

                // Lien discret : les pèlerins inscrits par une agence se
                // connectent avec leur passeport.
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/passport-login'),
                    child: Text(
                      'J\'ai un compte via mon agence (passeport)',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Accès libre sans compte (lecture seule) — argument de
                // conformité : la fonction de base ne requiert aucun compte.
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_visitor', true);
                      if (!context.mounted) return;
                      context.go('/rituals');
                    },
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text(
                      'Continuer sans compte',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
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
