# 📱 Guide Complet - Préparation iOS pour Sahabi Guide

Ce guide vous accompagne dans la préparation complète de l'application Sahabi Guide pour iOS (iPhone et iPad).

---

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Configuration du Projet](#configuration-du-projet)
3. [Permissions et Capabilities](#permissions-et-capabilities)
4. [Icônes et Splash Screen](#icônes-et-splash-screen)
5. [Build et Test](#build-et-test)
6. [Signature et Distribution](#signature-et-distribution)
7. [Soumission à l'App Store](#soumission-à-lapp-store)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Prérequis

### Matériel et Logiciels

| Élément | Requis |
|---------|--------|
| **macOS** | macOS 12.0 (Monterey) ou supérieur |
| **Xcode** | Version 15.0+ |
| **Flutter** | Version 3.x+ |
| **CocoaPods** | Installé (`sudo gem install cocoapods`) |
| **Compte Apple Developer** | Nécessaire pour la distribution |

### Vérifications Préalables

```bash
# Vérifier la version de Flutter
flutter --version

# Vérifier la version de Xcode
xcodebuild -version

# Vérifier CocoaPods
pod --version

# Vérifier les devices iOS disponibles
flutter devices
```

---

## ⚙️ Configuration du Projet

### 1. Configuration de Base

```bash
cd sahabi-guide-front

# Installer les dépendances
flutter pub get

# Installer les pods iOS
cd ios
pod install
cd ..
```

### 2. Bundle Identifier

**Ouvrir le projet dans Xcode :**

```bash
open ios/Runner.xcworkspace
```

**Dans Xcode :**
1. Sélectionner le projet `Runner` dans la barre latérale
2. Onglet `Signing & Capabilities`
3. Modifier le **Bundle Identifier** : `com.sahabiguide.app`
4. Sélectionner votre **Team** (compte Apple Developer)

### 3. Version de Déploiement

**Dans `ios/Podfile` :**
```ruby
platform :ios, '15.0'  # ✅ Déjà configuré
```

**Dans Xcode (Deployment Info) :**
- iOS Deployment Target : **15.0**

---

## 🔐 Permissions et Capabilities

### Permissions Configurées

Toutes les permissions sont déjà configurées dans `ios/Runner/Info.plist` :

| Permission | Usage | Status |
|------------|-------|--------|
| **Localisation** | Suivi GPS en temps réel | ✅ |
| **Caméra** | QR codes, photos de profil | ✅ |
| **Photos** | Galerie, sauvegarde de documents | ✅ |
| **Notifications** | Alertes, rappels de prière | ✅ |
| **Contacts** | Contact d'urgence | ✅ |
| **Calendrier** | Horaires de prière | ✅ |
| **Microphone** | Assistance vocale (optionnel) | ✅ |
| **Motion** | Tracking d'activité | ✅ |

### Capabilities à Activer dans Xcode

**Onglet `Signing & Capabilities` → Cliquer sur `+ Capability` :**

1. **Push Notifications** ✅ Obligatoire
   - Active les notifications push
   
2. **Background Modes** ✅ Obligatoire
   - ☑️ Location updates
   - ☑️ Background fetch
   - ☑️ Remote notifications
   - ☑️ Background processing

3. **Associated Domains** (optionnel)
   - Pour les Universal Links
   - Format : `applinks:sahabiguide.com`

4. **App Groups** (optionnel)
   - Pour partage de données avec widgets
   - Format : `group.com.sahabiguide.app`

---

## 🎨 Icônes et Splash Screen

### Icônes de l'Application

**Générer les icônes iOS :**

1. **Préparer une icône haute résolution (1024x1024)**
   - Format : PNG sans transparence
   - Nom : `app_icon.png`
   - Placer dans : `assets/images/`

2. **Utiliser `flutter_launcher_icons` (déjà configuré dans `pubspec.yaml`)**

```bash
flutter pub run flutter_launcher_icons
```

3. **Vérifier dans Xcode :**
   - Ouvrir `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Toutes les tailles doivent être générées automatiquement

### Splash Screen Natif

**Configuration avec `flutter_native_splash` :**

```yaml
# Dans pubspec.yaml (déjà configuré)
flutter_native_splash:
  color: "#1D3557"  # Couleur de fond
  image: assets/images/sahabi logo.png
  ios: true
  android: true
```

```bash
# Générer le splash screen
flutter pub run flutter_native_splash:create
```

---

## 🔨 Build et Test

### 1. Build Debug

```bash
# Build pour simulateur iOS
flutter build ios --debug --simulator

# Build pour device physique
flutter build ios --debug
```

### 2. Lancer sur Simulateur

```bash
# Lister les simulateurs disponibles
flutter emulators

# Lancer un simulateur
open -a Simulator

# Exécuter l'app
flutter run -d <simulator_id>
```

### 3. Lancer sur Device Physique

**Prérequis :**
- iPhone/iPad connecté via USB
- Confiance établie entre Mac et device
- Certificat de développement configuré

```bash
# Lister les devices
flutter devices

# Exécuter sur iPhone
flutter run -d <iphone_id>
```

### 4. Tests de Performance

```bash
# Build en mode profile (pour tester les performances)
flutter build ios --profile
flutter run --profile -d <device_id>

# Analyser les performances
flutter run --profile --trace-startup
```

---

## 📝 Signature et Distribution

### 1. Certificats et Profils de Provisioning

**Dans le Portail Apple Developer :**

1. **Certificates** (https://developer.apple.com/account/resources/certificates)
   - Créer : **iOS App Development** (pour développement)
   - Créer : **iOS Distribution** (pour App Store)

2. **Identifiers** 
   - Bundle ID : `com.sahabiguide.app`
   - Activer les capabilities : Push Notifications, Background Modes, etc.

3. **Devices**
   - Enregistrer les UDID des iPhones de test

4. **Profiles**
   - Créer : **Development Profile**
   - Créer : **App Store Profile**

### 2. Configuration dans Xcode

**Signing & Capabilities :**

```
✅ Automatically manage signing (pour développement)
   Team : [Votre équipe Apple Developer]
   Bundle Identifier : com.sahabiguide.app
   
ou

❌ Automatically manage signing (pour production)
   Provisioning Profile : [Votre profil App Store]
   Signing Certificate : [iOS Distribution]
```

### 3. Build Release

```bash
# Build pour App Store
flutter build ios --release

# Résultat :
# ios/build/Runner.app
```

### 4. Archiver dans Xcode

**Étapes :**
1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Sélectionner **Any iOS Device (arm64)**
3. Menu **Product** → **Archive**
4. Attendre la fin de l'archivage
5. Fenêtre **Organizer** s'ouvre automatiquement

---

## 🚀 Soumission à l'App Store

### 1. Préparer l'Archive

**Dans Xcode Organizer :**

1. Sélectionner l'archive la plus récente
2. Cliquer sur **Distribute App**
3. Choisir **App Store Connect**
4. Options recommandées :
   - ✅ Upload
   - ✅ Include bitcode (si disponible)
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number

### 2. App Store Connect

**Créer l'application :**

1. Aller sur https://appstoreconnect.apple.com
2. **My Apps** → **+** → **New App**
3. Remplir les informations :
   - **Name** : Sahabi Guide
   - **Primary Language** : French
   - **Bundle ID** : com.sahabiguide.app
   - **SKU** : SAHABIGUIDE001

### 3. Métadonnées de l'App

**Informations requises :**

```
Nom : Sahabi Guide
Sous-titre : Votre compagnon pour un pèlerinage béni

Description :
Sahabi Guide est votre compagnon indispensable pour un pèlerinage harmonieux 
et sécurisé. L'application offre :

🗺️ Géolocalisation en temps réel
📿 Guide des rituels du Hajj
🤲 Invocations et Duas
👥 Gestion de groupe
🏥 Profil médical d'urgence
📞 Contacts d'urgence
🔔 Notifications de prière
🎥 Vidéos éducatives

Fonctionnalités principales :
• Suivi GPS en temps réel pour votre sécurité
• Partage de position avec votre famille
• Guide complet des rituels du Hajj
• QR code médical pour les urgences
• Assistant conversationnel intelligent
• Support multilingue (FR, EN, AR)

Sahabi Guide est conçu pour garantir votre sécurité et enrichir 
votre expérience spirituelle durant le Hajj.

Mots-clés :
hajj, omra, pelerinage, islam, mecca, medina, guide, rituals, 
prayer times, qibla, muslim, sahabi
```

**Screenshots requis :**
- iPhone 6.5" : 1242 x 2688 px (3 minimum)
- iPhone 6.7" : 1290 x 2796 px (3 minimum)
- iPad Pro 12.9" : 2048 x 2732 px (3 minimum)

### 4. Informations de Confidentialité

**Privacy Policy URL :**
- URL requise : https://sahabiguide.com/privacy

**Pratiques de confidentialité Apple :**
- ✅ Localisation précise
- ✅ Contact info (email, phone)
- ✅ Photos/Videos
- ✅ Identifiants (User ID)

### 5. Catégorie et Tarification

```
Catégorie principale : Travel
Catégorie secondaire : Lifestyle
Prix : Gratuit
Achats intégrés : Non (ou selon business model)
```

### 6. Review Information

```
Demo Account (si nécessaire) :
- Email : demo@sahabiguide.com
- Password : [Votre mot de passe demo]

Notes pour la review :
"Cette application nécessite l'accès à la localisation pour 
fonctionner correctement. Elle est destinée aux pèlerins du Hajj 
pour assurer leur sécurité et faciliter leur pèlerinage."
```

### 7. Soumettre pour Review

1. Cliquer sur **Submit for Review**
2. Répondre aux questions de conformité
3. Attendre la validation (généralement 24-48h)

---

## 🐛 Troubleshooting

### Problèmes Courants

#### 1. Erreur de Signing

**Problème :** "Failed to register bundle identifier"

**Solution :**
```bash
# 1. Nettoyer le cache
flutter clean
cd ios
pod deintegrate
pod install
cd ..

# 2. Dans Xcode, vérifier Team et Bundle ID
# 3. Rebuilder
flutter build ios
```

#### 2. Pods Installation Failed

**Problème :** Erreur lors de `pod install`

**Solution :**
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

#### 3. Certificat Expiré

**Problème :** "Certificate has expired"

**Solution :**
1. Aller sur https://developer.apple.com/account
2. Révoquer l'ancien certificat
3. Créer un nouveau certificat
4. Télécharger et installer
5. Mettre à jour le profil de provisioning

#### 4. Build Failed - Architecture

**Problème :** "Building for iOS Simulator, but linking..."

**Solution :**
```bash
# Exclure les architectures ARM du simulateur
# Dans Podfile, ajouter :
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
```

#### 5. Permissions Non Accordées

**Problème :** L'app ne demande pas les permissions

**Solution :**
1. Vérifier que toutes les clés NSxxxxUsageDescription sont dans Info.plist
2. Désinstaller complètement l'app du device/simulateur
3. Rebuilder et réinstaller

---

## ✅ Checklist Finale

Avant de soumettre à l'App Store :

### Configuration
- [ ] Bundle Identifier correct (`com.sahabiguide.app`)
- [ ] Version et Build Number corrects
- [ ] iOS Deployment Target = 15.0
- [ ] Team configurée dans Xcode

### Permissions
- [ ] Toutes les permissions nécessaires dans Info.plist
- [ ] Descriptions claires et en français
- [ ] Capabilities activées dans Xcode

### Assets
- [ ] Icône d'app 1024x1024 générée
- [ ] Toutes les tailles d'icônes présentes
- [ ] Splash screen natif configuré
- [ ] Screenshots pour App Store préparés

### Build
- [ ] Build release sans erreurs
- [ ] Tests sur simulateur OK
- [ ] Tests sur device physique OK
- [ ] Pas de warnings critiques

### App Store Connect
- [ ] App créée dans App Store Connect
- [ ] Métadonnées complètes (nom, description, etc.)
- [ ] Screenshots uploadés
- [ ] Privacy Policy URL fournie
- [ ] Catégories sélectionnées
- [ ] Prix configuré

### Review
- [ ] Notes pour la review rédigées
- [ ] Compte demo fourni (si nécessaire)
- [ ] Build uploadé via Xcode
- [ ] Soumission pour review effectuée

---

## 📞 Support

### Ressources Officielles

- **Apple Developer Documentation** : https://developer.apple.com/documentation/
- **Flutter iOS Deployment** : https://docs.flutter.dev/deployment/ios
- **App Store Connect Help** : https://help.apple.com/app-store-connect/

### Contacts Utiles

- **Support Technique Sahabi Guide** : dev@sahabiguide.com
- **Apple Developer Support** : https://developer.apple.com/support/

---

## 🎉 Félicitations !

Votre application Sahabi Guide est maintenant prête pour iOS ! 🍎

**Prochaines étapes :**
1. ✅ Tester extensivement sur différents devices
2. ✅ Collecter les retours utilisateurs (TestFlight)
3. ✅ Soumettre à l'App Store
4. ✅ Monitorer les reviews et performances

---

**Date de création :** 2025-01-XX  
**Dernière mise à jour :** 2025-01-XX  
**Version du guide :** 1.0.0






