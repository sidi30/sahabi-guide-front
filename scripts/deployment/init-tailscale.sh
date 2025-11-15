#!/bin/sh
#######################################################
# Script d'initialisation Tailscale
#######################################################
# Ce script configure automatiquement le proxy socat
# et Tailscale Serve au démarrage du conteneur
#######################################################

set -e

echo "=================================================="
echo "  Initialisation Tailscale + Caddy Proxy"
echo "=================================================="

# Attendre que Caddy soit disponible
echo "Attente de Caddy..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if ping -c 1 caddy > /dev/null 2>&1; then
        echo "Caddy est accessible"
        break
    fi
    attempt=$((attempt + 1))
    echo "Tentative $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERREUR : Impossible d'atteindre Caddy"
    exit 1
fi

# Installer socat si nécessaire
if ! command -v socat > /dev/null 2>&1; then
    echo "Installation de socat..."
    apk add --no-cache socat
fi

# Tuer les anciennes instances de socat
pkill socat 2>/dev/null || true
sleep 1

# Démarrer socat en arrière-plan
echo "Démarrage du proxy socat (localhost:8080 -> caddy:80)..."
socat TCP-LISTEN:8080,fork,reuseaddr TCP:caddy:80 &
SOCAT_PID=$!
echo "socat démarré (PID: $SOCAT_PID)"

# Attendre que socat soit prêt
sleep 2

# Vérifier que socat fonctionne
if ! netstat -tlnp 2>/dev/null | grep -q ":8080"; then
    echo "ERREUR : socat n'est pas en écoute sur le port 8080"
    exit 1
fi

echo "socat est opérationnel sur le port 8080"

# Configurer Tailscale Serve
echo "Configuration de Tailscale Serve..."
tailscale serve off 2>/dev/null || true
sleep 1

tailscale serve --bg http://localhost:8080

# Afficher le statut
echo ""
echo "=================================================="
echo "  Configuration terminée !"
echo "=================================================="
echo ""
tailscale serve status

echo ""
echo "Proxy socat : localhost:8080 -> caddy:80"
echo "Tailscale Serve : configuré"
echo ""




