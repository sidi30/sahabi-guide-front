import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/constants/app_colors.dart';
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
  String _selectedCategory = 'Général';

  @override
  void initState() {
    super.initState();
    // Pré-remplir le nom et l'email si l'utilisateur est authentifié
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // ✅ Bouton retour automatique
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Informations de contact rapides
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
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
                    title: 'Support Téléphone',
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

          // Horaires de disponibilité
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horaires de disponibilité',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text('24h/24 pendant la période du Hajj'),
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
                            color: AppColors.primary,
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
                    
                    // Catégorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Général', child: Text('Question générale')),
                        DropdownMenuItem(value: 'Technique', child: Text('Problème technique')),
                        DropdownMenuItem(value: 'Compte', child: Text('Mon compte')),
                        DropdownMenuItem(value: 'Rituels', child: Text('Rituels du Hajj')),
                        DropdownMenuItem(value: 'Santé', child: Text('Santé & Urgence')),
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
                        hintText: 'Décrivez votre demande en détail...',
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
                          return 'Le message doit contenir au moins 10 caractères';
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
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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

          // Réseaux sociaux
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suivez-nous',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSocialButton(Icons.facebook, 'Facebook', () {}),
                      _buildSocialButton(Icons.language, 'Twitter', () {}),
                      _buildSocialButton(Icons.photo_camera, 'Instagram', () {}),
                      _buildSocialButton(Icons.video_library, 'YouTube', () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

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
            Icon(icon, color: AppColors.primary, size: 28),
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
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copié : $text'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Créer le message de contact
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
      // Afficher un message de succès
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Message envoyé !'),
          content: const Text(
            'Nous avons bien reçu votre message. Notre équipe vous répondra dans les plus brefs délais.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la dialog
                // Vérifier si on peut revenir en arrière, sinon aller à l'accueil
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(); // Retour à la page précédente
                } else {
                  context.go('/home'); // Aller à l'accueil si pas de page précédente
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Réinitialiser le formulaire
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'Général';
      });
    } else {
      // Afficher un message d'erreur
      final errorMessage = ref.read(contactMessageNotifierProvider).error ?? 'Erreur inconnue';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

