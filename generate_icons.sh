#!/bin/bash

# ============================================
# Script de Génération des Icônes et Splash Screen
# Sahabi Guide - Flutter
# ============================================

set -e

echo "🎨 ============================================"
echo "🎨  Génération des Icônes - Sahabi Guide"
echo "🎨 ============================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# 1. Vérifications
# ============================================
echo "📋 Étape 1/4 : Vérifications..."

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter installé${NC}"

# Vérifier l'image du logo
if [ ! -f "assets/images/sahabi logo.png" ]; then
    echo -e "${RED}❌ Logo manquant : assets/images/sahabi logo.png${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Logo trouvé${NC}"

echo ""

# ============================================
# 2. Installation des packages
# ============================================
echo "📦 Étape 2/4 : Installation des packages..."

flutter pub get

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de l'installation des packages${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Packages installés${NC}"
echo ""

# ============================================
# 3. Génération des icônes
# ============================================
echo "🎨 Étape 3/4 : Génération des icônes d'application..."

# Générer les icônes pour Android et iOS
flutter pub run flutter_launcher_icons

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Icônes générées avec succès !${NC}"
    echo ""
    echo -e "${BLUE}📱 Icônes générées pour :${NC}"
    echo "  ✅ Android (adaptive icons)"
    echo "  ✅ iOS (toutes les tailles)"
    echo "  ✅ Web (optionnel)"
    echo "  ✅ Windows (optionnel)"
    echo "  ✅ macOS (optionnel)"
else
    echo -e "${RED}❌ Erreur lors de la génération des icônes${NC}"
    exit 1
fi

echo ""

# ============================================
# 4. Génération du splash screen
# ============================================
echo "✨ Étape 4/4 : Génération du splash screen natif..."

# Générer le splash screen
flutter pub run flutter_native_splash:create

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Splash screen généré avec succès !${NC}"
    echo ""
    echo -e "${BLUE}🎬 Splash screen généré pour :${NC}"
    echo "  ✅ Android (y compris Android 12+)"
    echo "  ✅ iOS"
    echo "  ✅ Web (optionnel)"
else
    echo -e "${RED}❌ Erreur lors de la génération du splash screen${NC}"
    exit 1
fi

echo ""

# ============================================
# Résumé
# ============================================
echo "🎉 ============================================"
echo "🎉  Génération Terminée !"
echo "🎉 ============================================"
echo ""
echo -e "${GREEN}✅ Tous les assets ont été générés avec succès !${NC}"
echo ""
echo "📱 Fichiers générés :"
echo ""
echo "📂 Android :"
echo "  - android/app/src/main/res/mipmap-*/ic_launcher.png"
echo "  - android/app/src/main/res/drawable/launch_background.xml"
echo "  - android/app/src/main/res/values/colors.xml"
echo ""
echo "📂 iOS :"
echo "  - ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "  - ios/Runner/Assets.xcassets/LaunchImage.imageset/"
echo ""
echo "🔍 Vérification :"
echo "  1. Android : Ouvrir dans Android Studio"
echo "     ${YELLOW}android/app/src/main/res/mipmap-hdpi/ic_launcher.png${NC}"
echo ""
echo "  2. iOS : Ouvrir dans Xcode"
echo "     ${YELLOW}open ios/Runner.xcworkspace${NC}"
echo "     Vérifier : Assets.xcassets/AppIcon.appiconset"
echo ""
echo "🚀 Prochaines étapes :"
echo "  1. Tester sur Android : ${GREEN}flutter run${NC}"
echo "  2. Tester sur iOS : ${GREEN}flutter run${NC}"
echo "  3. Vérifier visuellement les icônes dans l'émulateur"
echo ""
echo "📝 Note : Les icônes sont visibles après une réinstallation complète de l'app"
echo ""






