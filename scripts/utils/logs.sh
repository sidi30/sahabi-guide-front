#!/bin/bash

#######################################################
# 📋 Script de logs - Sahabi Guide
#######################################################
# Ce script affiche les logs des services
#######################################################

COMPOSE_FILE="docker-compose.full.yml"

# Couleurs
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     📋 SAHABI GUIDE - LOGS               ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

if [ -z "$1" ]; then
    log_info "Sélectionnez le service :"
    echo "  1) Tous les services"
    echo "  2) PostgreSQL"
    echo "  3) Keycloak"
    echo "  4) Backend"
    echo "  5) Frontend"
    echo "  6) Caddy"
    echo "  7) Tailscale"
    echo ""
    read -p "Votre choix [1-7]: " choice
    
    case $choice in
        1) docker-compose -f $COMPOSE_FILE logs -f ;;
        2) docker-compose -f $COMPOSE_FILE logs -f postgres ;;
        3) docker-compose -f $COMPOSE_FILE logs -f keycloak ;;
        4) docker-compose -f $COMPOSE_FILE logs -f backend ;;
        5) docker-compose -f $COMPOSE_FILE logs -f frontend ;;
        6) docker-compose -f $COMPOSE_FILE logs -f caddy ;;
        7) docker-compose -f $COMPOSE_FILE logs -f tailscale ;;
        *) echo "Choix invalide" ; exit 1 ;;
    esac
else
    # Si un argument est fourni, l'utiliser comme nom de service
    docker-compose -f $COMPOSE_FILE logs -f "$1"
fi

