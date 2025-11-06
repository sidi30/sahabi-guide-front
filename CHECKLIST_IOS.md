# ✅ Checklist iOS - Sahabi Guide

Suivez cette checklist étape par étape pour préparer et soumettre l'app à l'App Store.

---

## 📋 Phase 1 : Configuration Initiale

### Environnement de Développement
- [ ] macOS 12.0+ installé
- [ ] Xcode 15.0+ installé
- [ ] Flutter 3.x+ installé et configuré
- [ ] CocoaPods installé (`sudo gem install cocoapods`)
- [ ] Compte Apple Developer actif (99$/an)

### Premier Build
- [ ] `flutter pub get` exécuté sans erreur
- [ ] `cd ios && pod install` exécuté sans erreur
- [ ] `flutter doctor` sans erreurs critiques
- [ ] Simulateur iOS lancé avec succès
- [ ] `flutter run` fonctionne sur simulateur

---

## 🔧 Phase 2 : Configuration du Projet

### Dans Xcode (Runner.xcworkspace)
- [ ] Projet ouvert : `open ios/Runner.xcworkspace`
- [ ] Bundle Identifier défini : `com.sahabiguide.app`
- [ ] Team sélectionnée (compte Apple Developer)
- [ ] iOS Deployment Target = 15.0
- [ ] Signing activé (Automatically manage signing)

### Permissions (Info.plist)
- [ ] Localisation (Always + When In Use) ✅ Déjà configuré
- [ ] Caméra ✅ Déjà configuré
- [ ] Photos ✅ Déjà configuré
- [ ] Notifications ✅ Déjà configuré
- [ ] Contacts ✅ Déjà configuré
- [ ] Calendrier ✅ Déjà configuré
- [ ] Microphone ✅ Déjà configuré (optionnel)
- [ ] Motion ✅ Déjà configuré

### Capabilities (Signing & Capabilities)
- [ ] **Push Notifications** activé
- [ ] **Background Modes** activé :
  - [ ] Location updates
  - [ ] Background fetch
  - [ ] Remote notifications
  - [ ] Background processing

---

## 🎨 Phase 3 : Assets et Branding

### Icône de l'Application
- [ ] Icône 1024x1024 px créée (PNG sans transparence)
- [ ] `flutter pub run flutter_launcher_icons` exécuté
- [ ] Toutes les tailles générées dans `AppIcon.appiconset`
- [ ] Vérification visuelle dans Xcode

### Splash Screen
- [ ] Logo pour splash screen préparé
- [ ] `flutter pub run flutter_native_splash:create` exécuté
- [ ] Splash screen vérifié sur simulateur
- [ ] Splash screen vérifié sur device physique

### Screenshots App Store
- [ ] iPhone 6.5" (1242 x 2688) - 3 à 10 screenshots
- [ ] iPhone 6.7" (1290 x 2796) - 3 à 10 screenshots
- [ ] iPad Pro 12.9" (2048 x 2732) - 3 à 10 screenshots
- [ ] Screenshots en français (langue principale)
- [ ] Screenshots en anglais (optionnel)
- [ ] Screenshots en arabe (optionnel)

---

## 🧪 Phase 4 : Tests

### Tests Fonctionnels
- [ ] Login avec passeport + OTP
- [ ] Géolocalisation fonctionnelle
- [ ] Carte interactive affichée
- [ ] Notifications reçues
- [ ] QR code médical généré
- [ ] Assistant conversationnel répond
- [ ] Vidéos de rituels lisibles
- [ ] Profil santé sauvegardé
- [ ] Changement de langue (FR/EN/AR)
- [ ] Mode sombre/clair

### Tests sur Devices
- [ ] Test sur simulateur iPhone (iOS 15+)
- [ ] Test sur simulateur iPad (iOS 15+)
- [ ] Test sur iPhone physique (iOS 15+)
- [ ] Test sur iPad physique (optionnel)
- [ ] Test avec connexion 4G/5G
- [ ] Test en mode avion (fonctionnalités offline)
- [ ] Test avec localisation désactivée
- [ ] Test avec permissions refusées

### Tests de Performance
- [ ] Temps de lancement < 3 secondes
- [ ] Fluidité 60 FPS
- [ ] Consommation batterie acceptable
- [ ] Utilisation mémoire < 200 MB
- [ ] Pas de crashes détectés
- [ ] `flutter run --profile` pour analyser

---

## 🔐 Phase 5 : Certificats et Provisioning

### Sur developer.apple.com
- [ ] Certificat iOS Development créé
- [ ] Certificat iOS Distribution créé
- [ ] App ID enregistré : `com.sahabiguide.app`
- [ ] Capabilities activées sur App ID :
  - [ ] Push Notifications
  - [ ] Background Modes
  - [ ] Associated Domains (si nécessaire)
- [ ] Devices iOS enregistrés (UDID)
- [ ] Development Profile créé
- [ ] App Store Distribution Profile créé

### Dans Xcode
- [ ] Certificats importés dans Keychain
- [ ] Profiles importés et valides
- [ ] Signing configuré correctement
- [ ] Pas d'erreurs de signing

---

## 📦 Phase 6 : Build Release

### Préparation
- [ ] Version number mise à jour (ex: 1.0.0)
- [ ] Build number incrémenté (ex: 1)
- [ ] Code nettoyé (commentaires, debugs)
- [ ] Logs de debug supprimés/désactivés
- [ ] `flutter clean` exécuté

### Build
- [ ] `flutter build ios --release` sans erreur
- [ ] Dans Xcode : Product > Archive
- [ ] Archive créée avec succès
- [ ] Archive validée dans Organizer
- [ ] Pas de warnings critiques

---

## 🚀 Phase 7 : App Store Connect

### Création de l'App
- [ ] App créée sur https://appstoreconnect.apple.com
- [ ] Nom : "Sahabi Guide"
- [ ] Langue principale : Français
- [ ] Bundle ID : `com.sahabiguide.app`
- [ ] SKU : SAHABIGUIDE001

### Métadonnées
- [ ] **Nom de l'app** : Sahabi Guide
- [ ] **Sous-titre** : Votre compagnon pour un pèlerinage béni
- [ ] **Description** complète rédigée
- [ ] **Mots-clés** optimisés (100 caractères max)
- [ ] **URL de support** : https://sahabiguide.com/support
- [ ] **URL marketing** : https://sahabiguide.com
- [ ] **Privacy Policy** : https://sahabiguide.com/privacy

### Catégories et Tarifs
- [ ] Catégorie principale : Travel
- [ ] Catégorie secondaire : Lifestyle
- [ ] Prix : Gratuit (ou prix défini)
- [ ] Disponibilité : Tous les pays

### Assets
- [ ] Screenshots uploadés (iPhone 6.5")
- [ ] Screenshots uploadés (iPhone 6.7")
- [ ] Screenshots uploadés (iPad Pro 12.9")
- [ ] Icône App Store 1024x1024 uploadée
- [ ] Preview vidéo (optionnel)

### Informations de Review
- [ ] Informations de contact fournies
- [ ] Notes pour la review rédigées
- [ ] Compte demo créé (si nécessaire)
- [ ] Instructions spéciales pour les reviewers

### Pratiques de Confidentialité
- [ ] Déclaration des données collectées :
  - [ ] Localisation précise
  - [ ] Informations de contact
  - [ ] Contenu utilisateur (photos)
  - [ ] Identifiants
- [ ] Politique de confidentialité liée

---

## 📤 Phase 8 : Soumission

### Upload du Build
- [ ] Build uploadé via Xcode Organizer
- [ ] Build traité par App Store Connect (15-30 min)
- [ ] Build sélectionné dans App Store Connect
- [ ] Build validé (aucune erreur)

### Préparation à la Review
- [ ] Toutes les métadonnées complétées
- [ ] Tous les champs obligatoires remplis
- [ ] Export Compliance répondu
- [ ] Content Rights répondu
- [ ] Advertising Identifier répondu (si applicable)

### Soumission Finale
- [ ] **Submit for Review** cliqué
- [ ] Statut : "Waiting for Review"
- [ ] Email de confirmation reçu
- [ ] Estimation : 24-48h de review

---

## ✅ Post-Soumission

### Monitoring
- [ ] Surveiller les emails d'Apple
- [ ] Vérifier le statut dans App Store Connect
- [ ] Répondre rapidement si Apple contacte
- [ ] Préparer les réponses aux questions potentielles

### Si Rejeté
- [ ] Lire attentivement le motif de rejet
- [ ] Corriger les problèmes identifiés
- [ ] Tester les corrections
- [ ] Resoumettre avec explications

### Si Approuvé 🎉
- [ ] Statut : "Ready for Sale"
- [ ] App visible sur l'App Store
- [ ] Tester le téléchargement depuis l'App Store
- [ ] Partager le lien App Store
- [ ] Célébrer ! 🎊

---

## 📊 Suivi Post-Lancement

### Premières 48h
- [ ] Monitorer les crashes (Firebase/Crashlytics)
- [ ] Vérifier les reviews utilisateurs
- [ ] Surveiller les ratings
- [ ] Répondre aux premiers avis

### Première Semaine
- [ ] Analyser les métriques d'utilisation
- [ ] Collecter les feedbacks utilisateurs
- [ ] Identifier les bugs critiques
- [ ] Préparer un hotfix si nécessaire

### Premier Mois
- [ ] Analyser les KPIs
- [ ] Planifier les prochaines features
- [ ] Optimiser en fonction des retours
- [ ] Préparer la version 1.1.0

---

## 🔄 Mises à Jour Futures

### Pour Chaque Mise à Jour
- [ ] Incrémenter le Build Number
- [ ] Mettre à jour le Version Number (si feature)
- [ ] Rédiger les Release Notes
- [ ] Tester exhaustivement
- [ ] Créer une nouvelle Archive
- [ ] Uploader sur App Store Connect
- [ ] Soumettre pour review

---

## 📞 Contacts d'Urgence

| Besoin | Contact |
|--------|---------|
| **Support Apple Developer** | https://developer.apple.com/support/ |
| **App Store Connect Help** | https://help.apple.com/app-store-connect/ |
| **Flutter iOS Issues** | https://github.com/flutter/flutter/issues |
| **Équipe Sahabi Guide** | dev@sahabiguide.com |

---

## 🎯 Objectifs de Qualité

### Standards Minimums
- ✅ 0 crash au lancement
- ✅ Toutes les permissions expliquées
- ✅ UI responsive sur tous les écrans
- ✅ Support des langues FR/EN/AR
- ✅ Conformité WCAG 2.1 (accessibilité)
- ✅ Temps de réponse < 1s
- ✅ Utilisation batterie optimisée

### Excellence
- 🌟 Rating App Store > 4.5
- 🌟 Aucun crash rapporté
- 🌟 Feedback utilisateurs positifs
- 🌟 Temps de review < 24h
- 🌟 Optimisation continue

---

**Date de début :** _______________  
**Date de soumission prévue :** _______________  
**Date de soumission réelle :** _______________  
**Date d'approbation :** _______________  

---

**Bonne chance avec votre soumission à l'App Store ! 🍎✨**






