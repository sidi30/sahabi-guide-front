#!/bin/bash

#######################################################
# 🔧 Script de configuration des permissions
#######################################################
# Rend tous les scripts .sh exécutables
#######################################################

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║   🔧 Configuration des permissions       ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Liste des scripts à rendre exécutables
SCRIPTS=(
    "start.sh"
    "stop.sh"
    "logs.sh"
    "backup-db.sh"
    "restore-db.sh"
    "setup-permissions.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "✓ $script → Exécutable"
    else
        echo "⚠ $script → Non trouvé"
    fi
done

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "Vous pouvez maintenant lancer :"
echo "  ./start.sh"
echo ""

