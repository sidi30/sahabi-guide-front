import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/constants/app_colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & FAQ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // ✅ Bouton retour automatique
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une question...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Liste des FAQ
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _getFilteredFAQs(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Naviguer vers la page de contact
          Navigator.pushNamed(context, '/settings/contact');
        },
        icon: const Icon(Icons.contact_support),
        label: const Text('Nous Contacter'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  List<Widget> _getFilteredFAQs() {
    final faqs = _getAllFAQs();
    
    if (_searchQuery.isEmpty) {
      return faqs;
    }
    
    return faqs.where((faq) {
      // Extraire le texte de l'ExpansionTile pour le filtre
      if (faq is _FAQItem) {
        return faq.question.toLowerCase().contains(_searchQuery) ||
               faq.answer.toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();
  }

  List<Widget> _getAllFAQs() {
    return [
      _buildCategoryHeader('Authentification & Compte'),
      _FAQItem(
        question: 'Comment me connecter à l\'application ?',
        answer: '''
Pour vous connecter :

1. Ouvrez l'application Sahabi Guide
2. Appuyez sur "Se connecter"
3. Entrez votre numéro de passeport
4. Vous recevrez un code OTP par SMS
5. Entrez le code à 6 chiffres
6. Vous êtes connecté !

Le code OTP expire après 5 minutes.
''',
      ),
      _FAQItem(
        question: 'Je n\'ai pas reçu le code OTP, que faire ?',
        answer: '''
Si vous ne recevez pas le code OTP :

1. Vérifiez que votre numéro de téléphone est correct
2. Vérifiez votre réseau mobile
3. Attendez quelques minutes (délai SMS)
4. Appuyez sur "Renvoyer le code"
5. Si le problème persiste, contactez le support

En cas d'urgence, contactez votre guide directement.
''',
      ),
      _FAQItem(
        question: 'Comment modifier mes informations personnelles ?',
        answer: '''
Pour modifier vos informations :

1. Allez dans "Profil"
2. Appuyez sur l'icône "Modifier" (crayon)
3. Modifiez les informations souhaitées
4. Enregistrez les modifications

Note : Le numéro de passeport ne peut pas être modifié. Contactez votre agence pour toute correction.
''',
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Géolocalisation & Carte'),
      _FAQItem(
        question: 'Comment activer la géolocalisation ?',
        answer: '''
Pour activer la géolocalisation :

1. Allez dans les paramètres de votre téléphone
2. Activez la localisation/GPS
3. Autorisez Sahabi Guide à accéder à votre position
4. Redémarrez l'application

La géolocalisation est essentielle pour votre sécurité.
''',
      ),
      _FAQItem(
        question: 'Pourquoi ma position n\'est pas précise ?',
        answer: '''
Si votre position n'est pas précise :

• Assurez-vous d'être à l'extérieur (meilleure réception GPS)
• Activez le Wi-Fi pour améliorer la précision
• Vérifiez que le mode haute précision est activé
• Attendez quelques secondes pour la calibration
• Redémarrez l'application

Dans les bâtiments, la précision GPS peut être réduite.
''',
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Rituels & Prières'),
      _FAQItem(
        question: 'Comment suivre mes rituels du Hajj ?',
        answer: '''
Pour suivre vos rituels :

1. Allez dans "Rituels" depuis le menu
2. Consultez la timeline des rituels
3. Chaque rituel est détaillé avec instructions
4. Cochez les rituels accomplis
5. Recevez des rappels automatiques

Les rituels sont organisés chronologiquement pour vous guider.
''',
      ),
      _FAQItem(
        question: 'Comment écouter les duas (invocations) ?',
        answer: '''
Pour écouter les duas :

1. Allez dans "Rituels" > "Duas"
2. Sélectionnez une invocation
3. Appuyez sur le bouton lecture
4. Suivez le texte en arabe et sa traduction
5. Changez la langue audio dans Paramètres > Langue Audio

Les duas sont disponibles en plusieurs langues.
''',
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Groupe & Communication'),
      _FAQItem(
        question: 'Comment communiquer avec mon groupe ?',
        answer: '''
Pour communiquer avec votre groupe :

1. Allez dans "Connectivité" ou "Groupe"
2. Consultez la liste des membres
3. Voyez leur position en temps réel
4. Contactez votre guide en cas de besoin

Les alertes d'urgence sont envoyées automatiquement à tout le groupe.
''',
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Santé & Urgences'),
      _FAQItem(
        question: 'Comment enregistrer mes informations médicales ?',
        answer: '''
Pour enregistrer vos informations médicales :

1. Allez dans "Santé"
2. Complétez votre carnet de santé
3. Ajoutez vos allergies
4. Listez vos traitements en cours
5. Ajoutez des contacts d'urgence

Ces informations sont cruciales en cas d'urgence médicale.
''',
      ),
      _FAQItem(
        question: 'Que faire en cas d\'urgence ?',
        answer: '''
En cas d'urgence :

1. Utilisez le bouton d'ALERTE URGENCE
2. Votre position sera partagée avec votre guide
3. Contactez les numéros d'urgence :
   • Police : 911
   • Ambulance : 997
   • Défense civile : 998
4. Contactez votre ambassade si nécessaire

Votre guide et groupe seront automatiquement notifiés.
''',
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Technique'),
      _FAQItem(
        question: 'L\'application ne fonctionne pas, que faire ?',
        answer: '''
Si l'application ne fonctionne pas :

1. Vérifiez votre connexion Internet
2. Redémarrez l'application
3. Videz le cache : Paramètres > Stockage > Vider le cache
4. Mettez à jour l'application
5. Redémarrez votre téléphone
6. Réinstallez l'application en dernier recours

Vos données sont sauvegardées et ne seront pas perdues.
''',
      ),
      _FAQItem(
        question: 'Comment économiser la batterie ?',
        answer: '''
Pour économiser la batterie :

• Réduisez la luminosité de l'écran
• Désactivez la géolocalisation quand vous ne vous déplacez pas
• Activez le mode économie d'énergie
• Fermez les applications en arrière-plan
• Utilisez le mode sombre (Paramètres > Thème)

Emportez toujours une batterie externe pour votre sécurité.
''',
      ),

      const SizedBox(height: 32),
    ];
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

