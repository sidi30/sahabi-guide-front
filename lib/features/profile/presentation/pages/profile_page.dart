import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_extensions.dart';
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
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/app_logger.dart';

// Provider pour récupérer le profil du pèlerin
final pilgrimProfileProvider = FutureProvider<PilgrimProfile?>((ref) async {
  final getPilgrimProfileUseCase = sl<GetPilgrimProfileUseCase>();
  try {
    return await getPilgrimProfileUseCase();
  } catch (e) {
    AppLogger.error('Erreur récupération profil', error: e);
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
        backgroundColor: ref.colors.primary,
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
              onPressed: () => context.go('/email-login'),
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
                      color: ref.colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ref.colors.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: ref.colors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    profile?.fullName ?? 'Nom non disponible',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ref.colors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Passport Number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ref.colors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge,
                          size: 18,
                          color: ref.colors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile?.passportNo != null
                              ? 'Passeport: ${profile!.passportNo}'
                              : (profile?.phone != null
                                  ? profile!.phone!
                                  : 'Compte'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ref.colors.secondary,
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
              // Passeport affiché uniquement s'il existe (comptes agence). Un
              // compte email n'en a pas -> on masque la ligne (pas de "Non
              // renseigné" qui ressemble à un champ manquant/obligatoire).
              if (profile?.passportNo != null && profile!.passportNo!.isNotEmpty)
                _buildInfoRow('Passeport', profile.passportNo!),
              if (profile?.phone != null)
                _buildInfoRow('Téléphone', profile!.phone!),
              // Masquer les emails techniques générés pour les comptes
              // sans email (self-signup par téléphone).
              if (profile?.email != null &&
                  profile!.email!.isNotEmpty &&
                  !profile.email!.endsWith('.sahabi.local'))
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
                  color: ref.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.qr_code,
                  color: ref.colors.primary,
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
              icon: Icon(Icons.logout, color: ref.colors.accent),
              label: Text(
                'Se déconnecter',
                style: TextStyle(color: ref.colors.accent),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ref.colors.accent),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Delete Account Button (conformité Apple 5.1.1(v))
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _deleteAccount(context),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text(
                'Supprimer mon compte',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
                    color: ref.colors.textSecondary,
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
      leading: Icon(icon, color: ref.colors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showQRCode(BuildContext context, PilgrimProfile? profile) {
    final colors = ref.colors;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mon QR Code d\'Urgence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: colors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 80, color: colors.primary),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code Profil',
                      style: TextStyle(
                        color: colors.primary,
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
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter le partage du QR code
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
            ),
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final colors = ref.colors;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final authNotifier = ref.read(authNotifierProvider.notifier);
              await authNotifier.logout();
              if (context.mounted) {
                context.go('/auth-choice');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.textOnPrimary,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  /// Suppression de compte in-app : avertissement + confirmation par saisie du
  /// mot « SUPPRIMER », puis appel serveur (anonymisation + désactivation) et
  /// retour à l'écran d'accueil. Conformité Apple 5.1.1(v).
  void _deleteAccount(BuildContext context) {
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool canDelete = false;
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Supprimer mon compte')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cette action est définitive. Vos données personnelles '
                    '(profil, historique, suivi) seront supprimées et vous serez '
                    'déconnecté. Cette action est irréversible.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tapez SUPPRIMER pour confirmer :',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'SUPPRIMER',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setDialogState(
                      () => canDelete = v.trim().toUpperCase() == 'SUPPRIMER',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: (!canDelete || isDeleting)
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final ok = await ref
                              .read(authNotifierProvider.notifier)
                              .deleteAccount();
                          if (ok) {
                            // Nettoie l'état local (évite un classement visiteur
                            // périmé au prochain lancement).
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('is_visitor');
                          }
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Votre compte a été supprimé.'
                                    : 'Suppression impossible. Réessayez.'),
                                backgroundColor: ok ? Colors.green : Colors.red,
                              ),
                            );
                          }
                          if (ok && context.mounted) {
                            context.go('/auth-choice');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Supprimer définitivement'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
