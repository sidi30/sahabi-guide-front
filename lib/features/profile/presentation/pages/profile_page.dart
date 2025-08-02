import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/constants.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authRepository = sl<AuthRepository>();
  return await authRepository.getCurrentUser();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => _buildProfileContent(context, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel? user) {
    if (user == null) {
      return const Center(
        child: Text('Utilisateur non trouvé'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: user.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  user.profileImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.primaryColor,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Email
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Verification Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.isVerified ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isVerified ? Icons.verified : Icons.pending,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isVerified ? 'Vérifié' : 'En attente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Personal Information
          _buildSectionCard(
            'Informations Personnelles',
            [
              _buildInfoRow('Prénom', user.firstName),
              _buildInfoRow('Nom', user.lastName),
              _buildInfoRow('Email', user.email),
              if (user.phoneNumber != null)
                _buildInfoRow('Téléphone', user.phoneNumber!),
              if (user.dateOfBirth != null)
                _buildInfoRow('Date de naissance', _formatDate(user.dateOfBirth!)),
              if (user.address != null)
                _buildInfoRow('Adresse', user.address!),
            ],
          ),

          const SizedBox(height: 16),

          // QR Code Section
          Card(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: const Text('Mon QR Code'),
              subtitle: const Text('Partager mes informations de contact'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showQRCode(context, user),
            ),
          ),

          const SizedBox(height: 16),

          // Settings Section
          _buildSectionCard(
            'Paramètres',
            [
              _buildSettingsTile(
                'Notifications',
                'Gérer les notifications',
                Icons.notifications_outlined,
                () {
                  // TODO: Navigate to notifications settings
                },
              ),
              _buildSettingsTile(
                'Langue',
                'Français',
                Icons.language,
                () {
                  // TODO: Navigate to language settings
                },
              ),
              _buildSettingsTile(
                'Thème',
                'Automatique',
                Icons.palette_outlined,
                () {
                  // TODO: Navigate to theme settings
                },
              ),
              _buildSettingsTile(
                'Confidentialité',
                'Paramètres de confidentialité',
                Icons.privacy_tip_outlined,
                () {
                  // TODO: Navigate to privacy settings
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support Section
          _buildSectionCard(
            'Support',
            [
              _buildSettingsTile(
                'Aide',
                'Centre d\'aide et FAQ',
                Icons.help_outline,
                () {
                  // TODO: Navigate to help
                },
              ),
              _buildSettingsTile(
                'Nous contacter',
                'Envoyer un message',
                Icons.contact_support_outlined,
                () {
                  // TODO: Navigate to contact
                },
              ),
              _buildSettingsTile(
                'À propos',
                'Version ${AppConstants.appVersion}',
                Icons.info_outline,
                () {
                  // TODO: Show about dialog
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: AppTheme.accentColor),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: AppTheme.accentColor),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentColor),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showQRCode(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mon QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('QR Code Profil', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Partagez ce QR code pour permettre aux autres de vous ajouter rapidement.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Share QR code
              Navigator.of(context).pop();
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final logoutUseCase = sl<LogoutUseCase>();
              await logoutUseCase();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
