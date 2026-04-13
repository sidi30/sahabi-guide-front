import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/notification_snackbar.dart';

/// Page d'inscription pour les visiteurs (non-pèlerins)
/// Permet de collecter email et téléphone pour la newsletter
class VisitorRegistrationPage extends ConsumerStatefulWidget {
  const VisitorRegistrationPage({super.key});

  @override
  ConsumerState<VisitorRegistrationPage> createState() =>
      _VisitorRegistrationPageState();
}

class _VisitorRegistrationPageState
    extends ConsumerState<VisitorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerVisitor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      NotificationService.showError(
        context,
        'Veuillez accepter les conditions pour continuer',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sauvegarder les informations localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('visitor_name', _nameController.text);
      await prefs.setString('visitor_email', _emailController.text);
      await prefs.setString('visitor_phone', _phoneController.text);
      await prefs.setBool('is_visitor', true);
      
      // TODO: Envoyer les données au backend pour la newsletter
      // await _sendToNewsletterAPI();

      if (!mounted) return;

      // Afficher un message de succès
      NotificationService.showSuccess(
        context,
        'Merci ! Vous pouvez maintenant explorer l\'application',
      );

      // Petit délai pour que l'utilisateur voie le message
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Rediriger vers la page d'accueil
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      NotificationService.showError(
        context,
        'Une erreur s\'est produite. Veuillez réessayer.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription Visiteur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.explore_outlined,
                          size: 40,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Explorez SahabiGuide',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Laissez-nous vos coordonnées pour rester informé',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Champ Nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Entrez votre nom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nom requis';
                    }
                    if (value.length < 3) {
                      return 'Le nom doit contenir au moins 3 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'exemple@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email requis';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ Téléphone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    hintText: '+227 XX XX XX XX',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Téléphone requis';
                    }
                    // Accepter différents formats de numéro
                    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{8,}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Numéro de téléphone invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Case à cocher pour les conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: context.primaryColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'J\'accepte de recevoir des informations et actualités sur le Hajj et la Omra',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bouton d'inscription
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerVisitor,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'S\'inscrire et continuer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Bouton pour continuer sans inscription
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Marquer comme visiteur sans info
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('is_visitor', true);
                          if (!context.mounted) return;
                          context.go('/home');
                        },
                  child: Text(
                    'Continuer sans inscription',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.secondaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vos données sont sécurisées et utilisées uniquement pour vous tenir informé de nos actualités',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor.withValues(alpha: 0.8),
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
