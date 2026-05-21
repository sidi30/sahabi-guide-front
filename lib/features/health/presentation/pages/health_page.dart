import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';

class HealthPage extends ConsumerWidget {
  const HealthPage({super.key});

  static const List<_UpcomingFeature> _upcomingFeatures = [
    _UpcomingFeature(
      icon: Icons.medical_information,
      title: 'Profil médical complet',
      description:
          'Groupe sanguin, allergies, conditions chroniques et traitements en cours.',
    ),
    _UpcomingFeature(
      icon: Icons.contact_emergency,
      title: 'Contact d\'urgence',
      description:
          'Personne à prévenir et son numéro, accessibles en un clic depuis l\'écran de verrouillage.',
    ),
    _UpcomingFeature(
      icon: Icons.qr_code_2,
      title: 'QR code médical',
      description:
          'Carte d\'urgence chiffrée à présenter aux secouristes saoudiens sans déverrouiller le téléphone.',
    ),
    _UpcomingFeature(
      icon: Icons.local_hospital,
      title: 'Hôpitaux & cliniques à proximité',
      description:
          'Annuaire géolocalisé des centres médicaux agréés Hajj/Omra à La Mecque et Médine.',
    ),
    _UpcomingFeature(
      icon: Icons.medication,
      title: 'Rappels de médicaments',
      description:
          'Notifications de prise adaptées au fuseau horaire saoudien et aux horaires de prière.',
    ),
    _UpcomingFeature(
      icon: Icons.thermostat,
      title: 'Conseils anti-canicule',
      description:
          'Alertes de chaleur, hydratation et prévention des coups de soleil pendant les rituels en extérieur.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Santé'),
        backgroundColor: ref.colors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCard(),
            const SizedBox(height: 24),
            Text(
              'Ce que cette section contiendra',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._upcomingFeatures.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FeatureTile(feature: f),
              ),
            ),
            const SizedBox(height: 8),
            _PrivacyNotice(),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: ref.colors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ref.colors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ref.colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: ref.colors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Section Santé',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule,
                                color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Bientôt disponible',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Cette section est en cours de développement et sera bientôt disponible. Elle regroupera tout ce dont vous avez besoin pour préserver votre santé pendant le Hajj et la Omra.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ref.colors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends ConsumerWidget {
  final _UpcomingFeature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ref.colors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: ref.colors.secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ref.colors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Toutes vos données médicales seront chiffrées localement et ne quitteront jamais votre appareil sans votre consentement explicite.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade800,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingFeature {
  final IconData icon;
  final String title;
  final String description;

  const _UpcomingFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
