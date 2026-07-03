import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'contact_screen.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & FAQ'),
        backgroundColor: ref.colors.primary,
        foregroundColor: ref.colors.textOnPrimary,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: ref.colors.primary.withValues(alpha: 0.1),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une question...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: ref.colors.surface,
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ContactScreen(),
            ),
          );
        },
        icon: const Icon(Icons.contact_support),
        label: const Text('Nous Contacter'),
        backgroundColor: ref.colors.primary,
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
        question: 'Comment me connecter a l\'application ?',
        answer: '''
Pour creer un compte ou vous connecter :

1. Ouvrez l'application Sahabi Guide
2. Appuyez sur "Se connecter"
3. Entrez votre adresse email
4. Vous recevrez un code par email
5. Entrez le code a 6 chiffres
6. Vous etes connecte !

(Si vous etes inscrit par une agence, vous pouvez aussi vous connecter avec
votre numero de passeport.)

Le code expire apres quelques minutes.
''',
        primaryColor: ref.colors.primary,
      ),
      _FAQItem(
        question: 'Je n\'ai pas recu le code OTP, que faire ?',
        answer: '''
Si vous ne recevez pas le code :

1. Verifiez que votre adresse email est correcte
2. Regardez dans vos courriers indesirables (spam)
3. Attendez quelques minutes
4. Appuyez sur "Renvoyer le code"
5. Si le probleme persiste, contactez le support

En cas d'urgence, contactez votre guide directement.
''',
        primaryColor: ref.colors.primary,
      ),
      _FAQItem(
        question: 'Comment modifier mes informations personnelles ?',
        answer: '''
Pour modifier vos informations :

1. Allez dans "Profil"
2. Appuyez sur l'icone "Modifier" (crayon)
3. Modifiez les informations souhaitees
4. Enregistrez les modifications

Note : Le numero de passeport ne peut pas etre modifie. Contactez votre agence pour toute correction.
''',
        primaryColor: ref.colors.primary,
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Geolocalisation & Carte'),
      _FAQItem(
        question: 'Comment activer la geolocalisation ?',
        answer: '''
Pour activer la geolocalisation :

1. Allez dans les parametres de votre telephone
2. Activez la localisation/GPS
3. Autorisez Sahabi Guide a acceder a votre position
4. Redemarrez l'application

La geolocalisation est essentielle pour votre securite.
''',
        primaryColor: ref.colors.primary,
      ),
      _FAQItem(
        question: 'Pourquoi ma position n\'est pas precise ?',
        answer: '''
Si votre position n'est pas precise :

- Assurez-vous d'etre a l'exterieur (meilleure reception GPS)
- Activez le Wi-Fi pour ameliorer la precision
- Verifiez que le mode haute precision est active
- Attendez quelques secondes pour la calibration
- Redemarrez l'application

Dans les batiments, la precision GPS peut etre reduite.
''',
        primaryColor: ref.colors.primary,
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Rituels & Prieres'),
      _FAQItem(
        question: 'Comment suivre mes rituels du Hajj ?',
        answer: '''
Pour suivre vos rituels :

1. Allez dans "Rituels" depuis le menu
2. Consultez la timeline des rituels
3. Chaque rituel est detaille avec instructions
4. Cochez les rituels accomplis
5. Recevez des rappels automatiques

Les rituels sont organises chronologiquement pour vous guider.
''',
        primaryColor: ref.colors.primary,
      ),
      _FAQItem(
        question: 'Comment ecouter les duas (invocations) ?',
        answer: '''
Pour ecouter les duas :

1. Allez dans "Rituels" > "Duas"
2. Selectionnez une invocation
3. Appuyez sur le bouton lecture
4. Suivez le texte en arabe et sa traduction
5. Changez la langue audio dans Parametres > Langue Audio

Les duas sont disponibles en plusieurs langues.
''',
        primaryColor: ref.colors.primary,
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Groupe & Communication'),
      _FAQItem(
        question: 'Comment communiquer avec mon groupe ?',
        answer: '''
Pour communiquer avec votre groupe :

1. Allez dans "Connectivite" ou "Groupe"
2. Consultez la liste des membres
3. Voyez leur position en temps reel
4. Contactez votre guide en cas de besoin

Les alertes d'urgence sont envoyees automatiquement a tout le groupe.
''',
        primaryColor: ref.colors.primary,
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Sante & Urgences'),
      _FAQItem(
        question: 'Comment enregistrer mes informations medicales ?',
        answer: '''
Pour enregistrer vos informations medicales :

1. Allez dans "Sante"
2. Completez votre carnet de sante
3. Ajoutez vos allergies
4. Listez vos traitements en cours
5. Ajoutez des contacts d'urgence

Ces informations sont cruciales en cas d'urgence medicale.
''',
        primaryColor: ref.colors.primary,
      ),
      _FAQItem(
        question: 'Que faire en cas d\'urgence ?',
        answer: '''
En cas d'urgence :

1. Utilisez le bouton d'ALERTE URGENCE
2. Votre position sera partagee avec votre guide
3. Contactez les numeros d'urgence :
   - Police : 911
   - Ambulance : 997
   - Defense civile : 998
4. Contactez votre ambassade si necessaire

Votre guide et groupe seront automatiquement notifies.
''',
        primaryColor: ref.colors.primary,
      ),

      const SizedBox(height: 16),
      _buildCategoryHeader('Technique'),
      _FAQItem(
        question: 'L\'application ne fonctionne pas, que faire ?',
        answer: '''
Si l'application ne fonctionne pas :

1. Verifiez votre connexion Internet
2. Redemarrez l'application
3. Videz le cache : Parametres > Stockage > Vider le cache
4. Mettez a jour l'application
5. Redemarrez votre telephone
6. Reinstallez l'application en dernier recours

Vos donnees sont sauvegardees et ne seront pas perdues.
''',
        primaryColor: ref.colors.primary,
      ),
      _FAQItem(
        question: 'Comment economiser la batterie ?',
        answer: '''
Pour economiser la batterie :

- Reduisez la luminosite de l'ecran
- Desactivez la geolocalisation quand vous ne vous deplacez pas
- Activez le mode economie d'energie
- Fermez les applications en arriere-plan
- Utilisez le mode sombre (Parametres > Theme)

Emportez toujours une batterie externe pour votre securite.
''',
        primaryColor: ref.colors.primary,
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
              color: ref.colors.primary,
            ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final Color primaryColor;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.primaryColor,
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
        leading: Icon(Icons.help_outline, color: primaryColor),
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
