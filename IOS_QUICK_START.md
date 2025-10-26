# 🚀 Quick Start iOS - Sahabi Guide

Guide rapide pour démarrer avec iOS en 5 minutes.

---

## ⚡ Commandes Essentielles

### 1. Préparation Initiale (une seule fois)

```bash
# Aller dans le projet
cd sahabi-guide-front

# Installer les dépendances Flutter
flutter pub get

# Installer les CocoaPods
cd ios
pod install
cd ..
```

### 2. Générer les Assets

```bash
# Générer les icônes
flutter pub run flutter_launcher_icons

# Générer le splash screen
flutter pub run flutter_native_splash:create

# Générer les localisations
flutter gen-l10n
```

### 3. Ouvrir dans Xcode

```bash
# Ouvrir le projet
open ios/Runner.xcworkspace
```

**Dans Xcode :**
- Sélectionner le projet `Runner`
- Onglet `Signing & Capabilities`
- Configurer `Team` et `Bundle Identifier`

### 4. Lancer l'App

```bash
# Sur simulateur
flutter run

# Sur device spécifique
flutter run -d <device-id>

# Lister les devices
flutter devices
```

### 5. Build Release

```bash
# Build iOS release
flutter build ios --release

# Puis dans Xcode : Product > Archive
```

---

## 📝 Fichiers Importants

| Fichier | Description |
|---------|-------------|
| `ios/Runner/Info.plist` | Permissions et configuration ✅ |
| `ios/Runner/Runner.entitlements` | Capabilities ✅ |
| `ios/Podfile` | Dépendances CocoaPods ✅ |
| `ios_config.yaml` | Configuration centralisée ✅ |

---

## 🔑 Configuration Minimale

### Bundle Identifier
```
com.sahabiguide.app
```

### iOS Deployment Target
```
15.0
```

### Permissions Essentielles
- ✅ Localisation (Always + When In Use)
- ✅ Caméra
- ✅ Photos
- ✅ Notifications
- ✅ Push Notifications (Capability)
- ✅ Background Modes (Capability)

---

## 🎯 Checklist Rapide

Avant de soumettre à l'App Store :

```
□ Bundle ID configuré : com.sahabiguide.app
□ Team sélectionnée dans Xcode
□ Icônes générées
□ Splash screen configuré
□ Permissions testées
□ Build release sans erreur
□ Tests sur device physique OK
□ Screenshots préparés (3 tailles)
□ App Store Connect configuré
```

---

## 📚 Documentation Complète

Pour plus de détails, consultez :

- **Guide Complet** : `GUIDE_PREPARATION_IOS.md`
- **Checklist Détaillée** : `CHECKLIST_IOS.md`
- **Configuration** : `ios_config.yaml`

---

## 🆘 Problèmes Courants

### Pods Installation Failed

```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

### Signing Failed

```bash
# Nettoyer
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Rebuilder
flutter build ios
```

### Device Not Found

```bash
# Lister les devices
flutter devices

# Redémarrer Xcode
killall Xcode
open ios/Runner.xcworkspace
```

---

## 🎉 C'est Tout !

Vous êtes prêt pour iOS ! 🍎

**Prochaines étapes :**
1. Tester sur simulateur
2. Tester sur device physique
3. Configurer App Store Connect
4. Soumettre pour review

**Support :** dev@sahabiguide.com

