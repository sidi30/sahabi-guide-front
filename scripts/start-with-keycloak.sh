#!/bin/bash
###############################################################################
# Démarre le projet SahabiGuide avec Keycloak OBLIGATOIRE
#
# Usage: ./scripts/start-with-keycloak.sh
###############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonctions d'affichage
function success() { echo -e "${GREEN}✅ $1${NC}"; }
function info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
function warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
function error() { echo -e "${RED}❌ $1${NC}"; }

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYCLOAK_URL="http://localhost:8080"
KEYCLOAK_HEALTH_CHECK_URL="$KEYCLOAK_URL/health"
MAX_WAIT_TIME=120  # secondes

info "🚀 Démarrage du projet SahabiGuide avec Keycloak"
info "=================================================="

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    error "Docker n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
success "Docker est installé : $DOCKER_VERSION"

# Vérifier si le fichier .env existe
ENV_FILE="$PROJECT_ROOT/.env"
if [ ! -f "$ENV_FILE" ]; then
    warning "Fichier .env non trouvé. Création à partir du template..."
    ENV_TEMPLATE="$PROJECT_ROOT/env.template"
    
    if [ -f "$ENV_TEMPLATE" ]; then
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        success ".env créé depuis env.template"
    else
        error "env.template non trouvé !"
        exit 1
    fi
fi

# Vérifier et corriger les variables dans .env
info "Vérification des variables d'environnement..."

# Vérifier VITE_ENABLE_KEYCLOAK
if ! grep -q "VITE_ENABLE_KEYCLOAK=true" "$ENV_FILE"; then
    warning "VITE_ENABLE_KEYCLOAK n'est pas à 'true', correction en cours..."
    sed -i.bak 's/VITE_ENABLE_KEYCLOAK=false/VITE_ENABLE_KEYCLOAK=true/g' "$ENV_FILE"
    if ! grep -q "VITE_ENABLE_KEYCLOAK=" "$ENV_FILE"; then
        echo "VITE_ENABLE_KEYCLOAK=true" >> "$ENV_FILE"
    fi
    success "VITE_ENABLE_KEYCLOAK activé"
fi

# Vérifier APP_SECURITY_ENABLED
if ! grep -q "APP_SECURITY_ENABLED=true" "$ENV_FILE"; then
    warning "APP_SECURITY_ENABLED n'est pas à 'true', correction en cours..."
    sed -i.bak 's/APP_SECURITY_ENABLED=false/APP_SECURITY_ENABLED=true/g' "$ENV_FILE"
    if ! grep -q "APP_SECURITY_ENABLED=" "$ENV_FILE"; then
        echo "APP_SECURITY_ENABLED=true" >> "$ENV_FILE"
    fi
    success "APP_SECURITY_ENABLED activé"
fi

# Démarrer PostgreSQL et Keycloak avec Docker Compose
info "📦 Démarrage de PostgreSQL et Keycloak..."

cd "$PROJECT_ROOT"
docker-compose down postgres keycloak 2>/dev/null || true
docker-compose up -d postgres keycloak

if [ $? -ne 0 ]; then
    error "Échec du démarrage de Docker Compose"
    exit 1
fi

success "Conteneurs démarrés"

# Attendre que PostgreSQL soit prêt
info "⏳ Attente de PostgreSQL..."
POSTGRES_READY=false
ELAPSED=0

while [ "$POSTGRES_READY" = false ] && [ $ELAPSED -lt 30 ]; do
    if docker exec sahabi-postgres pg_isready -U sahabi 2>/dev/null | grep -q "accepting connections"; then
        POSTGRES_READY=true
        success "PostgreSQL est prêt"
    else
        sleep 2
        ELAPSED=$((ELAPSED + 2))
        echo -n "."
    fi
done

if [ "$POSTGRES_READY" = false ]; then
    error "PostgreSQL n'a pas démarré dans les temps"
    exit 1
fi

# Attendre que Keycloak soit prêt
info "⏳ Attente de Keycloak (peut prendre jusqu'à 2 minutes)..."
KEYCLOAK_READY=false
ELAPSED=0

while [ "$KEYCLOAK_READY" = false ] && [ $ELAPSED -lt $MAX_WAIT_TIME ]; do
    if curl -sf "$KEYCLOAK_HEALTH_CHECK_URL" > /dev/null 2>&1; then
        KEYCLOAK_READY=true
        success "Keycloak est prêt et accessible"
    else
        sleep 5
        ELAPSED=$((ELAPSED + 5))
        echo -n "."
    fi
done

echo ""  # Nouvelle ligne après les points

if [ "$KEYCLOAK_READY" = false ]; then
    error "Keycloak n'a pas démarré dans les temps ($MAX_WAIT_TIME secondes)"
    info "Vérifiez les logs : docker logs sahabi-keycloak"
    exit 1
fi

# Afficher les informations de connexion Keycloak
info ""
info "🔐 KEYCLOAK EST PRÊT"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Admin Console : $KEYCLOAK_URL/admin"
info "Realm : sahabi"
info "Client : sahabi-dashboard"
info ""
success "Credentials (par défaut) :"
echo -e "  Username: ${YELLOW}admin${NC}"
echo -e "  Password: ${YELLOW}admin123${NC}"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info ""

# Options de démarrage
info "🎯 Choisissez comment démarrer le projet :"
echo ""
echo -e "${CYAN}1.${NC} Démarrer le Backend ET le Dashboard (mode développement)"
echo -e "${CYAN}2.${NC} Démarrer uniquement le Backend"
echo -e "${CYAN}3.${NC} Démarrer uniquement le Dashboard"
echo -e "${CYAN}4.${NC} Démarrer tous les services avec Docker Compose (mode production)"
echo -e "${CYAN}5.${NC} Arrêter et quitter"
echo ""

read -p "Votre choix (1-5): " choice

case $choice in
    1)
        info "🚀 Démarrage du Backend et du Dashboard..."
        
        # Démarrer le backend en arrière-plan
        info "Démarrage du Backend (port 8084)..."
        cd "$PROJECT_ROOT/sahabi-guide-api"
        
        # Ouvrir un nouveau terminal pour le backend
        if command -v gnome-terminal &> /dev/null; then
            gnome-terminal -- bash -c "cd $PROJECT_ROOT/sahabi-guide-api && export APP_SECURITY_ENABLED=true && export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi && echo '🔧 Backend Spring Boot' && ./mvnw spring-boot:run; exec bash"
        elif command -v xterm &> /dev/null; then
            xterm -e "cd $PROJECT_ROOT/sahabi-guide-api && export APP_SECURITY_ENABLED=true && export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi && echo '🔧 Backend Spring Boot' && ./mvnw spring-boot:run; bash" &
        else
            # Fallback : démarrer en arrière-plan dans le terminal actuel
            (cd "$PROJECT_ROOT/sahabi-guide-api" && export APP_SECURITY_ENABLED=true && export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi && ./mvnw spring-boot:run) &
        fi
        
        sleep 5
        
        # Démarrer le dashboard
        info "Démarrage du Dashboard (port 3000)..."
        cd "$PROJECT_ROOT/sahabi-guide-dashboard"
        
        if command -v gnome-terminal &> /dev/null; then
            gnome-terminal -- bash -c "cd $PROJECT_ROOT/sahabi-guide-dashboard && export VITE_ENABLE_KEYCLOAK=true && export VITE_KEYCLOAK_URL=http://localhost:8080 && echo '🎨 Dashboard React' && npm run dev; exec bash"
        elif command -v xterm &> /dev/null; then
            xterm -e "cd $PROJECT_ROOT/sahabi-guide-dashboard && export VITE_ENABLE_KEYCLOAK=true && export VITE_KEYCLOAK_URL=http://localhost:8080 && echo '🎨 Dashboard React' && npm run dev; bash" &
        else
            # Fallback : démarrer dans le terminal actuel
            (cd "$PROJECT_ROOT/sahabi-guide-dashboard" && export VITE_ENABLE_KEYCLOAK=true && export VITE_KEYCLOAK_URL=http://localhost:8080 && npm run dev)
        fi
        
        success "Services démarrés"
        info ""
        info "Accès aux services :"
        info "  - Dashboard : http://localhost:3000"
        info "  - Backend API : http://localhost:8084"
        info "  - Keycloak Admin : http://localhost:8080/admin"
        ;;
    
    2)
        info "🚀 Démarrage du Backend uniquement..."
        cd "$PROJECT_ROOT/sahabi-guide-api"
        export APP_SECURITY_ENABLED=true
        export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi
        success "Backend accessible sur http://localhost:8084"
        ./mvnw spring-boot:run
        ;;
    
    3)
        info "🚀 Démarrage du Dashboard uniquement..."
        cd "$PROJECT_ROOT/sahabi-guide-dashboard"
        export VITE_ENABLE_KEYCLOAK=true
        export VITE_KEYCLOAK_URL=http://localhost:8080
        success "Dashboard accessible sur http://localhost:3000"
        npm run dev
        ;;
    
    4)
        info "🚀 Démarrage de tous les services avec Docker Compose..."
        cd "$PROJECT_ROOT"
        docker-compose up -d
        success "Tous les services Docker sont démarrés"
        info ""
        info "Accès aux services :"
        info "  - Dashboard : http://localhost:3000"
        info "  - Backend API : http://localhost:8084"
        info "  - Keycloak Admin : http://localhost:8080/admin"
        info "  - PgAdmin (si profil 'tools' activé) : http://localhost:5050"
        ;;
    
    5)
        warning "Arrêt des services..."
        cd "$PROJECT_ROOT"
        docker-compose down
        success "Services arrêtés"
        exit 0
        ;;
    
    *)
        error "Choix invalide"
        exit 1
        ;;
esac

info ""
success "✅ Projet démarré avec succès avec Keycloak activé !"
info ""
info "Pour arrêter les services Docker :"
info "  docker-compose down"



