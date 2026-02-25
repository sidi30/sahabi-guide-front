import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialite'),
        backgroundColor: ref.colors.primary,
        foregroundColor: ref.colors.textOnPrimary,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            ref,
            icon: Icons.lock_outline,
            title: 'Politique de Confidentialite',
            content: '''
Chez Sahabi Guide, nous prenons la protection de vos donnees personnelles tres au serieux. Cette politique explique comment nous collectons, utilisons et protegeons vos informations.
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.info_outline,
            title: '1. Donnees Collectees',
            content: '''
Nous collectons les informations suivantes :

- Informations d'identification : Numero de passeport, nom, prenom
- Coordonnees : Numero de telephone, email
- Donnees de localisation : Position GPS pour votre securite
- Donnees de sante : Informations medicales que vous fournissez volontairement
- Donnees d'utilisation : Interactions avec l'application
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.security,
            title: '2. Utilisation des Donnees',
            content: '''
Vos donnees sont utilisees pour :

- Assurer votre securite pendant le Hajj
- Faciliter la communication avec votre groupe
- Fournir des rappels et alertes personnalisees
- Ameliorer nos services
- Respecter nos obligations legales
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.shield,
            title: '3. Protection des Donnees',
            content: '''
Nous mettons en oeuvre des mesures de securite strictes :

- Chiffrement de bout en bout pour les communications
- Stockage securise dans des centres de donnees certifies
- Acces limite aux donnees sensibles
- Audits de securite reguliers
- Conformite RGPD
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.share,
            title: '4. Partage des Donnees',
            content: '''
Nous ne partageons vos donnees qu'avec :

- Votre agence de voyage (avec votre consentement)
- Votre guide et groupe (informations limitees)
- Autorites competentes (en cas d'urgence)
- Prestataires de services essentiels (hebergement cloud, SMS)

Nous ne vendons JAMAIS vos donnees a des tiers.
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.person_outline,
            title: '5. Vos Droits',
            content: '''
Vous avez le droit de :

- Acceder a vos donnees personnelles
- Corriger vos informations
- Supprimer votre compte
- Exporter vos donnees
- Refuser le traitement de certaines donnees
- Deposer une plainte aupres d'une autorite de protection

Pour exercer vos droits, contactez-nous via l'application.
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.gps_fixed,
            title: '6. Geolocalisation',
            content: '''
L'utilisation de votre position GPS est essentielle pour :

- Votre securite en cas d'urgence
- Vous guider vers les lieux saints
- Vous regrouper avec votre groupe

Vous pouvez desactiver la geolocalisation, mais cela limitera certaines fonctionnalites de securite.
''',
          ),
          _buildSection(
            context,
            ref,
            icon: Icons.update,
            title: '7. Modifications',
            content: '''
Cette politique peut etre mise a jour occasionnellement. Nous vous informerons de tout changement important par notification dans l'application.

Derniere mise a jour : 12 octobre 2025
''',
          ),
          const SizedBox(height: 16),
          Card(
            color: ref.colors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.email, color: ref.colors.primary),
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
                        const Text('Contactez-nous a privacy@sahabiguide.com'),
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
    BuildContext context,
    WidgetRef ref, {
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
                Icon(icon, color: ref.colors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ref.colors.primary,
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
