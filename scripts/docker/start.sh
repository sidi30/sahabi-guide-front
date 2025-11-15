#!/bin/bash

#######################################################
# 🚀 Script de démarrage - Sahabi Guide
#######################################################
# Ce script démarre tous les services Docker dans le bon ordre
#######################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fichier docker-compose
COMPOSE_FILE="docker-compose.full.yml"

# Fonction pour afficher des messages colorés
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Fonction pour attendre qu'un service soit prêt
wait_for_service() {
    local service=$1
    local max_wait=${2:-120}  # Temps max en secondes
    local elapsed=0
    
    log_info "Attente du service $service..."
    
    while [ $elapsed -lt $max_wait ]; do
        if docker-compose -f $COMPOSE_FILE ps $service | grep -q "Up (healthy)"; then
            log_success "$service est prêt !"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
    done
    
    log_error "$service n'est pas prêt après ${max_wait}s"
    return 1
}

# Banner
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     🚀 SAHABI GUIDE - DÉMARRAGE          ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Vérification du fichier .env
if [ ! -f .env ]; then
    log_warning "Fichier .env non trouvé !"
    log_info "Création à partir du template..."
    cp env.template .env
    log_warning "⚠️  IMPORTANT : Éditez le fichier .env avec vos valeurs avant de continuer !"
    log_info "Lancez : nano .env (ou code .env)"
    exit 1
fi

# Vérification de Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé !"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé !"
    exit 1
fi

log_success "Docker et Docker Compose sont installés"

# Vérification de l'espace disque
available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$available_space" -lt 10 ]; then
    log_warning "Espace disque faible : ${available_space}GB disponibles (minimum recommandé : 10GB)"
fi

# Menu de démarrage
echo ""
log_info "Sélectionnez le mode de démarrage :"
echo "  1) Démarrage complet (tous les services)"
echo "  2) Démarrage progressif (recommandé pour la première fois)"
echo "  3) Développement (sans Caddy ni Tailscale)"
echo "  4) Redémarrer tous les services"
echo "  5) Quitter"
echo ""
read -p "Votre choix [1-5]: " choice

case $choice in
    1)
        log_info "Démarrage de tous les services..."
        docker-compose -f $COMPOSE_FILE up -d
        log_success "Tous les services sont lancés !"
        ;;
    
    2)
        log_info "Démarrage progressif..."
        
        # PostgreSQL
        echo ""
        log_info "📦 Étape 1/6 : Démarrage de PostgreSQL..."
        docker-compose -f $COMPOSE_FILE up -d postgres
        wait_for_service postgres 60
        
        # Keycloak
        echo ""
        log_info "🔐 Étape 2/6 : Démarrage de Keycloak..."
        docker-compose -f $COMPOSE_FILE up -d keycloak
        wait_for_service keycloak 120
        
        # Backend
        echo ""
        log_info "🔧 Étape 3/6 : Démarrage du Backend..."
        docker-compose -f $COMPOSE_FILE up -d backend
        wait_for_service backend 120
        
        # Frontend
        echo ""
        log_info "🎨 Étape 4/6 : Démarrage du Frontend..."
        docker-compose -f $COMPOSE_FILE up -d frontend
        wait_for_service frontend 60
        
        # Caddy
        echo ""
        log_info "🌐 Étape 5/6 : Démarrage de Caddy..."
        docker-compose -f $COMPOSE_FILE up -d caddy
        sleep 10
        log_success "Caddy est lancé"
        
        # Tailscale (optionnel)
        echo ""
        read -p "Démarrer Tailscale ? (y/N): " start_tailscale
        if [[ $start_tailscale =~ ^[Yy]$ ]]; then
            log_info "🔒 Étape 6/6 : Démarrage de Tailscale..."
            docker-compose -f $COMPOSE_FILE up -d tailscale
            sleep 10
            log_success "Tailscale est lancé"
        else
            log_info "Tailscale non démarré (vous pouvez le lancer plus tard)"
        fi
        
        log_success "Démarrage progressif terminé !"
        ;;
    
    3)
        log_info "Démarrage en mode développement..."
        docker-compose -f $COMPOSE_FILE up -d postgres keycloak backend frontend
        log_success "Services de développement lancés !"
        ;;
    
    4)
        log_info "Redémarrage de tous les services..."
        docker-compose -f $COMPOSE_FILE restart
        log_success "Services redémarrés !"
        ;;
    
    5)
        log_info "Annulé"
        exit 0
        ;;
    
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

# Afficher l'état des services
echo ""
log_info "État des services :"
docker-compose -f $COMPOSE_FILE ps

# Afficher les URLs
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     🌐 ACCÈS AUX SERVICES                ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "  Frontend     : http://localhost:3000"
echo "  Backend API  : http://localhost:8084"
echo "  Keycloak     : http://localhost:8080"
echo "  PgAdmin      : http://localhost:5050 (si lancé)"
echo ""
echo "  Swagger API  : http://localhost:8084/swagger-ui.html"
echo "  Health Check : http://localhost:8084/actuator/health"
echo ""

# Credentials
echo "╔═══════════════════════════════════════════╗"
echo "║     🔑 IDENTIFIANTS PAR DÉFAUT           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "  Keycloak Admin :"
echo "    Username : admin"
echo "    Password : admin"
echo ""
echo "  PgAdmin :"
echo "    Email    : admin@sahabi.local"
echo "    Password : admin"
echo ""
echo "  PostgreSQL :"
echo "    Host     : localhost"
echo "    Port     : 5432"
echo "    Database : sahabi_db"
echo "    Username : sahabi"
echo "    Password : sahabi"
echo ""

# Logs
echo "╔═══════════════════════════════════════════╗"
echo "║     📋 COMMANDES UTILES                  ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "  Voir les logs        : docker-compose -f $COMPOSE_FILE logs -f"
echo "  Arrêter tout         : docker-compose -f $COMPOSE_FILE down"
echo "  Redémarrer           : docker-compose -f $COMPOSE_FILE restart"
echo "  Voir l'état          : docker-compose -f $COMPOSE_FILE ps"
echo ""

log_success "Démarrage terminé ! 🎉"

