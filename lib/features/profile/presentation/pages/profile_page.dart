import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/data/models/passport_auth_models.dart';
import '../../../auth/domain/usecases/passport_auth_usecases.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';
import '../../../settings/presentation/screens/notifications_settings_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/presentation/screens/privacy_screen.dart';
import '../../../settings/presentation/screens/help_screen.dart';
import '../../../settings/presentation/screens/contact_screen.dart';
import '../../../settings/presentation/screens/about_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/constants.dart';

// Provider pour récupérer le profil du pèlerin
final pilgrimProfileProvider = FutureProvider<PilgrimProfile?>((ref) async {
  final getPilgrimProfileUseCase = sl<GetPilgrimProfileUseCase>();
  try {
    return await getPilgrimProfileUseCase();
  } catch (e) {
    print('Erreur récupération profil: $e');
    return null;
  }
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(pilgrimProfileProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: profileAsync.when(
        data: (profile) => _buildProfileContent(context, profile, authState),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement du profil...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(pilgrimProfileProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, PilgrimProfile? profile, AuthState authState) {
    // Si pas de profil, afficher un message
    if (profile == null && !authState.isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Non connecté'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/passport-login'),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    profile?.fullName ?? 'Nom non disponible',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Passport Number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Passeport: ${profile?.passportNo ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Account Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (profile?.enabled ?? false) ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (profile?.enabled ?? false) ? Icons.check_circle : Icons.block,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (profile?.enabled ?? false) ? 'Compte Actif' : 'Compte Désactivé',
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
              _buildInfoRow('Nom complet', profile?.fullName ?? 'Non renseigné'),
              _buildInfoRow('Prénom', profile?.firstName ?? 'Non renseigné'),
              _buildInfoRow('Nom', profile?.lastName ?? 'Non renseigné'),
              _buildInfoRow('Passeport', profile?.passportNo ?? 'Non renseigné'),
              if (profile?.phone != null)
                _buildInfoRow('Téléphone', profile!.phone!),
              if (profile?.email != null && profile!.email!.isNotEmpty)
                _buildInfoRow('Email', profile.email!),
              if (profile?.role != null)
                _buildInfoRow('Rôle', profile!.role!),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Mon QR Code'),
              subtitle: const Text('Partager mes informations'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showQRCode(context, profile),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                'Langue & Thème',
                'Personnaliser l\'interface',
                Icons.palette_outlined,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                'Confidentialité',
                'Protection de vos données',
                Icons.privacy_tip_outlined,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support Section
          _buildSectionCard(
            'Support & Aide',
            [
              _buildSettingsTile(
                'Aide & FAQ',
                'Trouvez des réponses rapidement',
                Icons.help_outline,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                'Nous contacter',
                'Besoin d\'assistance ?',
                Icons.contact_support_outlined,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ContactScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                'À propos',
                'Version ${AppConstants.appVersion}',
                Icons.info_outline,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
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
              icon: const Icon(Icons.logout, color: AppColors.accent),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: AppColors.accent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
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
                    color: AppColors.textSecondary,
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
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showQRCode(BuildContext context, PilgrimProfile? profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mon QR Code d\'Urgence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 80, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text(
                      'QR Code Profil',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ce QR code contient vos informations d\'urgence (nom, passeport, contacts).',
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
              // TODO: Implémenter le partage du QR code
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
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
              final authNotifier = ref.read(authNotifierProvider.notifier);
              await authNotifier.logout();
              if (context.mounted) {
                context.go('/passport-login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
