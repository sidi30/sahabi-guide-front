import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/utils/constants.dart';
import '../../../../shared/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = AppConstants.appVersion;
        _buildNumber = '1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À Propos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // ✅ Bouton retour automatique
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo et nom de l'application
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/sahabi logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.mosque,
                          size: 50,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sahabi Guide',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre compagnon pour le Hajj',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version $_version (Build $_buildNumber)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mission
          _buildSection(
            context,
            icon: Icons.flag,
            title: 'Notre Mission',
            content: '''
Sahabi Guide a pour mission de faciliter et sécuriser le pèlerinage des musulmans vers les lieux saints. Nous combinons technologie moderne et traditions islamiques pour offrir une expérience enrichissante et sereine.

Notre application accompagne les pèlerins à chaque étape de leur Hajj, de la préparation jusqu'au retour, en assurant leur sécurité, en les guidant dans les rituels et en maintenant le lien avec leur groupe.
''',
          ),

          // Fonctionnalités principales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Fonctionnalités Principales',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.location_on, 'Géolocalisation en temps réel'),
                  _buildFeatureItem(Icons.event, 'Guide des rituels du Hajj'),
                  _buildFeatureItem(Icons.group, 'Gestion de groupe'),
                  _buildFeatureItem(Icons.local_hospital, 'Carnet de santé digital'),
                  _buildFeatureItem(Icons.notifications_active, 'Alertes et rappels'),
                  _buildFeatureItem(Icons.map, 'Carte interactive'),
                  _buildFeatureItem(Icons.book, 'Invocations (Duas)'),
                  _buildFeatureItem(Icons.video_library, 'Vidéos éducatives'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Équipe
          _buildSection(
            context,
            icon: Icons.people,
            title: 'Notre Équipe',
            content: '''
Sahabi Guide est développé par une équipe passionnée de développeurs, designers et experts religieux, tous unis par la volonté d'améliorer l'expérience du Hajj.

Nous travaillons en étroite collaboration avec des agences de voyage, des guides expérimentés et des autorités religieuses pour vous offrir le meilleur accompagnement possible.
''',
          ),

          // Technologies
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Technologies Utilisées',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTechItem('Flutter', 'Framework mobile multiplateforme'),
                  _buildTechItem('Spring Boot', 'Backend robuste et sécurisé'),
                  _buildTechItem('PostgreSQL', 'Base de données fiable'),
                  _buildTechItem('Google Maps', 'Cartographie précise'),
                  _buildTechItem('Firebase', 'Notifications push'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Licences et crédits
          Card(
            child: ListTile(
              leading: const Icon(Icons.description, color: AppColors.primary),
              title: const Text('Licences Open Source'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Sahabi Guide',
                  applicationVersion: '$_version ($_buildNumber)',
                  applicationIcon: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/sahabi logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.mosque,
                          size: 30,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Mentions légales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mentions Légales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2025 Sahabi Guide. Tous droits réservés.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Développé avec ❤️ pour la communauté musulmane',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Ouvrir la page de confidentialité
                    Navigator.pushNamed(context, '/settings/privacy');
                  },
                  icon: const Icon(Icons.privacy_tip),
                  label: const Text('Confidentialité'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Ouvrir la page de contact
                    Navigator.pushNamed(context, '/settings/contact');
                  },
                  icon: const Icon(Icons.contact_support),
                  label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

