import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme/theme_extensions.dart';

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
        title: const Text('A Propos'),
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
        automaticallyImplyLeading: true,
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
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/favicon/web-app-manifest-logo-192x192.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/favicon/apple-touch-icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Icon(
                              Icons.location_on,
                              size: 50,
                              color: context.primaryColor,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sahabi Guide',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre compagnon pour le Hajj',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version $_version (Build $_buildNumber)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.secondaryColor,
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
Sahabi Guide a pour mission de faciliter et securiser le pelerinage des musulmans vers les lieux saints. Nous combinons technologie moderne et traditions islamiques pour offrir une experience enrichissante et sereine.

Notre application accompagne les pelerins a chaque etape de leur Hajj, de la preparation jusqu'au retour, en assurant leur securite, en les guidant dans les rituels et en maintenant le lien avec leur groupe.
''',
          ),

          // Fonctionnalites principales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: context.primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Fonctionnalites Principales',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(context, Icons.location_on, 'Geolocalisation en temps reel'),
                  _buildFeatureItem(context, Icons.event, 'Guide des rituels du Hajj'),
                  _buildFeatureItem(context, Icons.group, 'Gestion de groupe'),
                  _buildFeatureItem(context, Icons.local_hospital, 'Carnet de sante digital'),
                  _buildFeatureItem(context, Icons.notifications_active, 'Alertes et rappels'),
                  _buildFeatureItem(context, Icons.map, 'Carte interactive'),
                  _buildFeatureItem(context, Icons.book, 'Invocations (Duas)'),
                  _buildFeatureItem(context, Icons.video_library, 'Videos educatives'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Equipe
          _buildSection(
            context,
            icon: Icons.people,
            title: 'Notre Equipe',
            content: '''
Sahabi Guide est developpe par une equipe passionnee de developpeurs, designers et experts religieux, tous unis par la volonte d'ameliorer l'experience du Hajj.

Nous travaillons en etroite collaboration avec des agences de voyage, des guides experimentes et des autorites religieuses pour vous offrir le meilleur accompagnement possible.
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
                      Icon(Icons.code, color: context.primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Technologies Utilisees',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTechItem(context, 'Flutter', 'Framework mobile multiplateforme'),
                  _buildTechItem(context, 'Spring Boot', 'Backend robuste et securise'),
                  _buildTechItem(context, 'PostgreSQL', 'Base de donnees fiable'),
                  _buildTechItem(context, 'Google Maps', 'Cartographie precise'),
                  _buildTechItem(context, 'Firebase', 'Notifications push'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Licences et credits
          Card(
            child: ListTile(
              leading: Icon(Icons.description, color: context.primaryColor),
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
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/favicon/web-app-manifest-logo-192x192.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/favicon/apple-touch-icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Icon(
                              Icons.location_on,
                              size: 30,
                              color: context.primaryColor,
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Mentions legales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mentions Legales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '(c) 2025 Sahabi Guide. Tous droits reserves.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Developpe avec amour pour la communaute musulmane',
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
                    // Ouvrir la page de confidentialite
                    Navigator.pushNamed(context, '/settings/privacy');
                  },
                  icon: const Icon(Icons.privacy_tip),
                  label: const Text('Confidentialite'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryColor,
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
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
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
                Icon(icon, color: context.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
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

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(BuildContext context, String name, String description) {
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
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
