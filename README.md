# Sahabi Guide - Islamic Companion App

Une application mobile Flutter complète pour accompagner les musulmans dans leur pratique spirituelle quotidienne.

## Fonctionnalités

### Rituels et Prières
- Horaires de prières automatiques
- Rappels personnalisables
- Suivi des prières accomplies
- Qibla et boussole

### Douas et Dhikr
- Collection complète de douas
- Audio en arabe avec translittération
- Traductions en français
- Compteur de dhikr

### Carte et Localisation
- Mosquées et centres islamiques à proximité
- Informations détaillées des lieux
- Itinéraires et navigation
- Évaluations et avis

### Profil Santé
- Informations médicales sécurisées
- QR code d'urgence
- Contact d'urgence
- Chiffrement des données

### Profil Utilisateur
- Informations personnelles
- QR code de contact
- Paramètres de l'application
- Synchronisation des données

### Connectivité
- Synchronisation automatique
- Mode hors ligne
- Gestion des données
- Diagnostics réseau

## Architecture

L'application suit les principes de **Clean Architecture** avec une approche **feature-first**:

```dart
lib/
├── core/                 # Configuration globale
│   ├── di/              # Injection de dépendances
│   ├── network/         # Client HTTP
│   ├── router/          # Navigation
│   ├── theme/           # Thèmes et styles
│   ├── utils/           # Utilitaires
│   └── widgets/         # Widgets communs
├── features/            # Fonctionnalités
│   ├── auth/           # Authentification
│   ├── home/           # Écran d'accueil
│   ├── rituals/        # Rituels et prières
│   ├── map/            # Carte et localisation
│   ├── health/         # Profil santé
│   ├── profile/        # Profil utilisateur
│   └── connectivity/   # Connectivité
└── shared/             # Éléments partagés
    ├── models/         # Modèles de données
    ├── services/       # Services
    └── constants/      # Constantes
```

### Couches d'Architecture

Chaque fonctionnalité est organisée en 3 couches :

- **Domain** : Logique métier, entités, cas d'usage
- **Data** : Sources de données, repositories
- **Presentation** : UI, état, pages

## Technologies Utilisées

### Framework et Langage
- **Flutter 3.10+** - Framework UI multiplateforme
- **Dart 3.0+** - Langage de programmation

### Gestion d'État
- **Riverpod 2.4+** - Gestion d'état réactive

### Navigation
- **GoRouter 12.1+** - Navigation déclarative

### Réseau
- **Dio 5.4+** - Client HTTP

### Injection de Dépendances
- **GetIt 7.6+** - Service locator

### Stockage
- **SharedPreferences** - Stockage simple
- **FlutterSecureStorage** - Stockage sécurisé

### Audio
- **JustAudio 0.9+** - Lecteur audio

### Cartes et Localisation
- **GoogleMaps** - Cartes interactives
- **Geolocator** - Géolocalisation

### Notifications
- **FlutterLocalNotifications** - Notifications locales

### UI et Thème
- **GoogleFonts** - Police Noto Sans
- **Material Design 3** - Design system

## Installation et Configuration

### Prérequis

- Flutter SDK 3.10 ou supérieur
- Dart SDK 3.0 ou supérieur
- Android Studio / VS Code
- Émulateur Android ou appareil physique
- Xcode (pour iOS)

### Installation

1. **Cloner le repository**
```bash
git clone <repository-url>
cd sahabi-guide-front
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les fichiers de code**
```bash
flutter packages pub run build_runner build
```

4. **Configurer les clés API**

Créer un fichier `.env` à la racine :
```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
API_BASE_URL=https://api.sahabiguide.com
```

5. **Lancer l'application**
```bash
flutter run
```

## Tests

### Lancer tous les tests
```bash
flutter test
```

### Tests de widgets
```bash
flutter test test/widget_test.dart
```

### Tests unitaires
```bash
flutter test test/features/
```

### Couverture de code
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Plateformes Supportées

- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (en développement)

## Localisation

### Langues Supportées
- **Français** (par défaut)
- **Anglais**
- **Haoussa** (audio uniquement)
- **Djerma** (audio uniquement)

## Design System

### Couleurs Principales
- **Primaire** : #1D3557 (Bleu profond)
- **Secondaire** : #2A9D8F (Vert doux)
- **Accent** : #E63946 (Rouge)
- **Arrière-plan** : #F1FAEE (Blanc cassé)

### Typographie
- **Police** : Noto Sans
- **Tailles** : 12sp à 32sp
- **Poids** : Regular, Medium, Bold

## Données Mock

L'application utilise des données de démonstration :

### Authentification
- **Email** : test@example.com
- **Mot de passe** : password

### Données Incluses
- 5 prières quotidiennes
- 25+ douas avec audio
- 6 lieux sur la carte
- Profil utilisateur complet

## Sécurité

- Chiffrement des données sensibles
- Stockage sécurisé des tokens
- Validation côté client
- Gestion des permissions

## Performance

- Chargement paresseux des images
- Cache intelligent
- Optimisation des animations
- Gestion mémoire efficace

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Équipe

- **Développement** : Équipe Sahabi Guide
- **Design** : Équipe UI/UX
- **Contenu Religieux** : Conseillers Islamiques

## Support

- **Email** : support@sahabiguide.com
- **Documentation** : [docs.sahabiguide.com](https://docs.sahabiguide.com)
- **Issues** : [GitHub Issues](https://github.com/sahabiguide/issues)

## Roadmap

### Version 1.1
- [ ] Mode sombre
- [ ] Widget iOS
- [ ] Synchronisation cloud

### Version 1.2
- [ ] Communauté intégrée
- [ ] Calendrier islamique
- [ ] Partage social

### Version 2.0
- [ ] IA pour recommandations
- [ ] Réalité augmentée pour Qibla
- [ ] Support multi-langues complet

---
**Sahabi Guide** - Votre compagnon spirituel 
