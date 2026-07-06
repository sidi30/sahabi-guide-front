import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/models/contact_message_model.dart';
import '../providers/contact_message_provider.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General';

  @override
  void initState() {
    super.initState();
    // Pre-remplir le nom et l'email si l'utilisateur est authentifie
    _fillUserInfo();
  }

  void _fillUserInfo() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && authState.pilgrimProfile != null) {
      final profile = authState.pilgrimProfile!;
      _nameController.text = profile.fullName ?? profile.firstName ?? '';
      _emailController.text = profile.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactMessageNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nous Contacter'),
        backgroundColor: ref.colors.primary,
        foregroundColor: ref.colors.textOnPrimary,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Informations de contact rapides
          Card(
            color: ref.colors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Besoin d\'aide rapide ?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickContact(
                    icon: Icons.phone,
                    title: 'Support Telephone',
                    subtitle: '+966 11 234 5678',
                    onTap: () => _copyToClipboard(context, '+966112345678'),
                  ),
                  const Divider(),
                  _buildQuickContact(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@sahabiguide.com',
                    onTap: () => _copyToClipboard(context, 'support@sahabiguide.com'),
                  ),
                  const Divider(),
                  _buildQuickContact(
                    icon: Icons.chat,
                    title: 'WhatsApp',
                    subtitle: '+966 50 123 4567',
                    onTap: () => _copyToClipboard(context, '+966501234567'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Horaires de disponibilite
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: ref.colors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horaires de disponibilite',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text('24h/24 pendant la periode du Hajj'),
                        const Text('Lun-Ven : 9h-18h (hors Hajj)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Formulaire de contact
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Envoyer un message',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ref.colors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Nom
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categorie *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'General', child: Text('Question generale')),
                        DropdownMenuItem(value: 'Technique', child: Text('Probleme technique')),
                        DropdownMenuItem(value: 'Compte', child: Text('Mon compte')),
                        DropdownMenuItem(value: 'Rituels', child: Text('Rituels du Hajj')),
                        DropdownMenuItem(value: 'Sante', child: Text('Sante & Urgence')),
                        DropdownMenuItem(value: 'Groupe', child: Text('Mon groupe')),
                        DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sujet
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Sujet *',
                        prefixIcon: Icon(Icons.subject),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un sujet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message *',
                        hintText: 'Decrivez votre demande en detail...',
                        prefixIcon: Icon(Icons.message),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un message';
                        }
                        if (value.length < 10) {
                          return 'Le message doit contenir au moins 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Bouton d'envoi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: contactState.isLoading ? null : _submitForm,
                        icon: contactState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(contactState.isLoading ? 'Envoi en cours...' : 'Envoyer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ref.colors.primary,
                          foregroundColor: ref.colors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Reseaux sociaux
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickContact({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: ref.colors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: ref.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.copy, size: 20, color: ref.colors.textLight),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copie : $text'),
        backgroundColor: ref.colors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Creer le message de contact
    final contactMessage = ContactMessageModel(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      category: ContactCategory.fromFrench(_selectedCategory),
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
    );

    // Envoyer le message via le provider
    final success = await ref.read(contactMessageNotifierProvider.notifier).sendMessage(contactMessage);

    if (!mounted) return;

    if (success) {
      // Afficher un message de succes
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: ref.colors.success, size: 64),
          title: const Text('Message envoye !'),
          content: const Text(
            'Nous avons bien recu votre message. Notre equipe vous repondra dans les plus brefs delais.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la dialog
                // Verifier si on peut revenir en arriere, sinon aller a l'accueil
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(); // Retour a la page precedente
                } else {
                  context.go('/home'); // Aller a l'accueil si pas de page precedente
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Reinitialiser le formulaire
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'General';
      });
    } else {
      // Afficher un message d'erreur
      final errorMessage = ref.read(contactMessageNotifierProvider).error ?? 'Erreur inconnue';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $errorMessage'),
          backgroundColor: ref.colors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
