#!/bin/bash

# ============================================
# Script de Préparation iOS - Sahabi Guide
# ============================================
# Ce script automatise la préparation de l'app iOS
# Usage: ./prepare_ios.sh

set -e  # Arrêter en cas d'erreur

echo "🍎 ============================================"
echo "🍎  Préparation iOS - Sahabi Guide"
echo "🍎 ============================================"
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# 1. Vérifications préalables
# ============================================
echo "📋 Étape 1/7 : Vérifications préalables..."

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter installé : $(flutter --version | head -1)${NC}"

# Vérifier Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Xcode installé : $(xcodebuild -version | head -1)${NC}"

# Vérifier CocoaPods
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}⚠️  CocoaPods n'est pas installé${NC}"
    echo "Installation de CocoaPods..."
    sudo gem install cocoapods
fi
echo -e "${GREEN}✅ CocoaPods installé : $(pod --version)${NC}"

echo ""

# ============================================
# 2. Nettoyage
# ============================================
echo "🧹 Étape 2/7 : Nettoyage des builds précédents..."

# Nettoyer Flutter
echo "  - Nettoyage Flutter..."
cd ..
flutter clean > /dev/null 2>&1

# Supprimer les pods
echo "  - Suppression des pods..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf build

echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# ============================================
# 3. Installation des dépendances
# ============================================
echo "📦 Étape 3/7 : Installation des dépendances..."

# Flutter pub get
echo "  - Installation des packages Flutter..."
cd ..
flutter pub get

echo -e "${GREEN}✅ Packages Flutter installés${NC}"
echo ""

# ============================================
# 4. Installation des CocoaPods
# ============================================
echo "🔨 Étape 4/7 : Installation des CocoaPods..."

cd ios
echo "  - Mise à jour du repo CocoaPods..."
pod repo update > /dev/null 2>&1

echo "  - Installation des pods..."
pod install

if [ ! -d "Pods" ]; then
    echo -e "${RED}❌ Erreur lors de l'installation des pods${NC}"
    exit 1
fi

echo -e "${GREEN}✅ CocoaPods installés${NC}"
echo ""

# ============================================
# 5. Génération des icônes
# ============================================
echo "🎨 Étape 5/7 : Génération des icônes..."

cd ..
if [ -f "assets/images/sahabi logo.png" ]; then
    echo "  - Génération des icônes iOS..."
    flutter pub run flutter_launcher_icons || echo -e "${YELLOW}⚠️  flutter_launcher_icons non configuré${NC}"
else
    echo -e "${YELLOW}⚠️  Logo manquant : assets/images/sahabi logo.png${NC}"
fi

echo -e "${GREEN}✅ Icônes générées${NC}"
echo ""

# ============================================
# 6. Génération du splash screen
# ============================================
echo "✨ Étape 6/7 : Génération du splash screen..."

echo "  - Génération du splash screen natif..."
flutter pub run flutter_native_splash:create || echo -e "${YELLOW}⚠️  flutter_native_splash non configuré${NC}"

echo -e "${GREEN}✅ Splash screen généré${NC}"
echo ""

# ============================================
# 7. Génération des localisations
# ============================================
echo "🌍 Étape 7/7 : Génération des fichiers de localisation..."

echo "  - Génération des traductions..."
flutter gen-l10n

echo -e "${GREEN}✅ Localisations générées${NC}"
echo ""

# ============================================
# 8. Build de test (optionnel)
# ============================================
echo "🔨 Build de test (optionnel)..."
echo "Voulez-vous builder l'application maintenant ? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "  - Build debug pour simulateur..."
    flutter build ios --debug --simulator
    echo -e "${GREEN}✅ Build réussi !${NC}"
else
    echo -e "${YELLOW}⏭  Build ignoré${NC}"
fi

echo ""

# ============================================
# Résumé final
# ============================================
echo "🎉 ============================================"
echo "🎉  Préparation iOS Terminée !"
echo "🎉 ============================================"
echo ""
echo "📝 Prochaines étapes :"
echo "  1. Ouvrir le projet dans Xcode :"
echo "     ${GREEN}open ios/Runner.xcworkspace${NC}"
echo ""
echo "  2. Configurer la signature dans Xcode :"
echo "     - Signing & Capabilities"
echo "     - Team : [Votre équipe Apple Developer]"
echo "     - Bundle ID : com.sahabiguide.app"
echo ""
echo "  3. Lancer sur simulateur :"
echo "     ${GREEN}flutter run -d <simulator_id>${NC}"
echo ""
echo "  4. Lire le guide complet :"
echo "     ${GREEN}GUIDE_PREPARATION_IOS.md${NC}"
echo ""
echo "📚 Documentation complète disponible dans :"
echo "   sahabi-guide-front/GUIDE_PREPARATION_IOS.md"
echo ""
echo "✨ Bonne chance avec votre soumission à l'App Store ! 🍎"






