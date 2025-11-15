#!/bin/bash

#######################################################
# 🛑 Script d'arrêt - Sahabi Guide
#######################################################
# Ce script arrête tous les services Docker
#######################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

COMPOSE_FILE="docker-compose.full.yml"

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     🛑 SAHABI GUIDE - ARRÊT              ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

log_info "Sélectionnez l'option d'arrêt :"
echo "  1) Arrêter les services (conserver les données)"
echo "  2) Arrêter et supprimer les conteneurs (conserver les volumes)"
echo "  3) Tout supprimer (⚠️  SUPPRIME LES DONNÉES !)"
echo "  4) Annuler"
echo ""
read -p "Votre choix [1-4]: " choice

case $choice in
    1)
        log_info "Arrêt des services..."
        docker-compose -f $COMPOSE_FILE stop
        log_success "Services arrêtés !"
        ;;
    
    2)
        log_info "Arrêt et suppression des conteneurs..."
        docker-compose -f $COMPOSE_FILE down
        log_success "Conteneurs supprimés (volumes conservés)"
        ;;
    
    3)
        log_warning "⚠️  ATTENTION : Cette action supprimera TOUTES les données !"
        read -p "Êtes-vous sûr ? Tapez 'OUI' pour confirmer : " confirm
        if [ "$confirm" = "OUI" ]; then
            log_info "Suppression complète..."
            docker-compose -f $COMPOSE_FILE down -v
            log_success "Tout a été supprimé"
        else
            log_info "Annulé"
        fi
        ;;
    
    4)
        log_info "Annulé"
        exit 0
        ;;
    
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

echo ""
log_success "Opération terminée !"

