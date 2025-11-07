import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // ✅ Bouton retour automatique
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            icon: Icons.lock_outline,
            title: 'Politique de Confidentialité',
            content: '''
Chez Sahabi Guide, nous prenons la protection de vos données personnelles très au sérieux. Cette politique explique comment nous collectons, utilisons et protégeons vos informations.
''',
          ),
          _buildSection(
            context,
            icon: Icons.info_outline,
            title: '1. Données Collectées',
            content: '''
Nous collectons les informations suivantes :

• Informations d'identification : Numéro de passeport, nom, prénom
• Coordonnées : Numéro de téléphone, email
• Données de localisation : Position GPS pour votre sécurité
• Données de santé : Informations médicales que vous fournissez volontairement
• Données d'utilisation : Interactions avec l'application
''',
          ),
          _buildSection(
            context,
            icon: Icons.security,
            title: '2. Utilisation des Données',
            content: '''
Vos données sont utilisées pour :

• Assurer votre sécurité pendant le Hajj
• Faciliter la communication avec votre groupe
• Fournir des rappels et alertes personnalisées
• Améliorer nos services
• Respecter nos obligations légales
''',
          ),
          _buildSection(
            context,
            icon: Icons.shield,
            title: '3. Protection des Données',
            content: '''
Nous mettons en œuvre des mesures de sécurité strictes :

• Chiffrement de bout en bout pour les communications
• Stockage sécurisé dans des centres de données certifiés
• Accès limité aux données sensibles
• Audits de sécurité réguliers
• Conformité RGPD
''',
          ),
          _buildSection(
            context,
            icon: Icons.share,
            title: '4. Partage des Données',
            content: '''
Nous ne partageons vos données qu'avec :

• Votre agence de voyage (avec votre consentement)
• Votre guide et groupe (informations limitées)
• Autorités compétentes (en cas d'urgence)
• Prestataires de services essentiels (hébergement cloud, SMS)

Nous ne vendons JAMAIS vos données à des tiers.
''',
          ),
          _buildSection(
            context,
            icon: Icons.person_outline,
            title: '5. Vos Droits',
            content: '''
Vous avez le droit de :

• Accéder à vos données personnelles
• Corriger vos informations
• Supprimer votre compte
• Exporter vos données
• Refuser le traitement de certaines données
• Déposer une plainte auprès d'une autorité de protection

Pour exercer vos droits, contactez-nous via l'application.
''',
          ),
          _buildSection(
            context,
            icon: Icons.gps_fixed,
            title: '6. Géolocalisation',
            content: '''
L'utilisation de votre position GPS est essentielle pour :

• Votre sécurité en cas d'urgence
• Vous guider vers les lieux saints
• Vous regrouper avec votre groupe

Vous pouvez désactiver la géolocalisation, mais cela limitera certaines fonctionnalités de sécurité.
''',
          ),
          _buildSection(
            context,
            icon: Icons.update,
            title: '7. Modifications',
            content: '''
Cette politique peut être mise à jour occasionnellement. Nous vous informerons de tout changement important par notification dans l'application.

Dernière mise à jour : 12 octobre 2025
''',
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.email, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Questions ?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Contactez-nous à privacy@sahabiguide.com'),
                      ],
                    ),
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

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
}

