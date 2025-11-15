#!/bin/bash

#######################################################
# 🌐 SCRIPT DE DÉPLOIEMENT INTERNET - SAHABI GUIDE
#######################################################
# Ce script configure automatiquement l'accès Internet
# pour votre application Sahabi Guide
#######################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables
MODE=""
DOMAIN=""
EMAIL=""
TAILSCALE_KEY=""

# Fonctions d'affichage
print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_help() {
    print_header "Guide d'utilisation - Déploiement Internet"
    
    echo "Ce script configure automatiquement l'accès Internet pour Sahabi Guide."
    echo ""
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  ./deploy-internet.sh <mode> [options]"
    echo ""
    echo -e "${YELLOW}MODES DISPONIBLES:${NC}"
    echo ""
    echo -e "${CYAN}  1. TAILSCALE (Recommandé - Le plus simple)${NC}"
    echo '     ./deploy-internet.sh tailscale --key "tskey-auth-..."'
    echo "     • Pas besoin de domaine"
    echo "     • Configuration automatique"
    echo "     • Sécurisé par défaut"
    echo ""
    echo -e "${CYAN}  2. CADDY (Production - Avec nom de domaine)${NC}"
    echo '     ./deploy-internet.sh caddy --domain "sahabi-guide.com" --email "admin@example.com"'
    echo "     • Nécessite un nom de domaine"
    echo "     • SSL automatique (Let's Encrypt)"
    echo "     • Professionnel"
    echo ""
    echo -e "${CYAN}  3. DIRECT (Tests uniquement - Sans SSL)${NC}"
    echo "     ./deploy-internet.sh direct"
    echo "     • Exposition directe des ports"
    echo "     • Pas de SSL"
    echo "     • Non recommandé en production"
    echo ""
    echo -e "${YELLOW}EXEMPLES:${NC}"
    echo "  # Avec Tailscale"
    echo '  ./deploy-internet.sh tailscale --key "tskey-auth-kH5XSEoevj11CNTRL-..."'
    echo ""
    echo "  # Avec Caddy et nom de domaine"
    echo '  ./deploy-internet.sh caddy --domain "sahabi-guide.com" --email "admin@example.com"'
    echo ""
    echo "  # Exposition directe (tests)"
    echo "  ./deploy-internet.sh direct"
    echo ""
    echo -e "${YELLOW}DOCUMENTATION:${NC}"
    echo "  Consultez ACCES_INTERNET.md pour plus de détails"
    echo ""
}

test_prerequisites() {
    print_header "Vérification des prérequis"
    
    local all_good=true
    
    # Vérifier Docker
    print_info "Vérification de Docker..."
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        print_success "Docker installé : $docker_version"
    else
        print_error "Docker n'est pas installé"
        echo "  → Installez Docker : https://docs.docker.com/get-docker/"
        all_good=false
    fi
    
    # Vérifier Docker Compose
    print_info "Vérification de Docker Compose..."
    if command -v docker-compose &> /dev/null; then
        local compose_version=$(docker-compose --version)
        print_success "Docker Compose installé : $compose_version"
    else
        print_error "Docker Compose n'est pas installé"
        all_good=false
    fi
    
    # Vérifier que Docker est démarré
    print_info "Vérification du démon Docker..."
    if docker ps &> /dev/null; then
        print_success "Docker est en cours d'exécution"
    else
        print_error "Docker n'est pas démarré"
        echo "  → Démarrez Docker avec : sudo systemctl start docker"
        all_good=false
    fi
    
    # Vérifier les fichiers nécessaires
    print_info "Vérification des fichiers du projet..."
    local required_files=("docker-compose.yml" "Caddyfile" "tailscale-serve.json" "env.template")
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_success "Fichier trouvé : $file"
        else
            print_error "Fichier manquant : $file"
            all_good=false
        fi
    done
    
    echo ""
    
    if [ "$all_good" = false ]; then
        return 1
    fi
    return 0
}

create_env_file() {
    print_header "Configuration du fichier .env"
    
    if [ -f ".env" ]; then
        print_warning "Le fichier .env existe déjà"
        read -p "Voulez-vous le remplacer ? (o/N) " overwrite
        if [[ ! "$overwrite" =~ ^[oO]$ ]]; then
            print_info "Conservation du fichier .env existant"
            return
        fi
    fi
    
    print_info "Copie de env.template vers .env..."
    cp env.template .env
    print_success "Fichier .env créé"
}

configure_tailscale() {
    print_header "Configuration Tailscale"
    
    if [ -z "$TAILSCALE_KEY" ]; then
        print_error "La clé Tailscale est requise"
        echo ""
        echo -e "${YELLOW}Pour obtenir une clé Tailscale :${NC}"
        echo "  1. Créez un compte sur https://login.tailscale.com/start"
        echo "  2. Allez sur https://login.tailscale.com/admin/settings/keys"
        echo "  3. Cliquez sur 'Generate auth key'"
        echo "  4. Cochez 'Reusable' et générez la clé"
        echo '  5. Relancez le script avec : ./deploy-internet.sh tailscale --key "tskey-auth-..."'
        echo ""
        exit 1
    fi
    
    # Créer le fichier .env si nécessaire
    create_env_file
    
    # Mettre à jour la clé Tailscale dans .env
    print_info "Mise à jour de la clé Tailscale dans .env..."
    sed -i "s|TAILSCALE_AUTHKEY=.*|TAILSCALE_AUTHKEY=$TAILSCALE_KEY|g" .env
    print_success "Clé Tailscale configurée"
    
    # Arrêter les services existants
    print_info "Arrêt des services en cours..."
    docker-compose down 2>/dev/null || true
    
    # Démarrer avec le profil production
    print_info "Démarrage des services avec Tailscale..."
    echo ""
    docker-compose --profile production up -d
    
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Services démarrés avec succès !"
        
        # Attendre que Tailscale soit prêt
        print_info "Attente du démarrage de Tailscale (30 secondes)..."
        sleep 30
        
        # Afficher le statut Tailscale
        print_header "Statut Tailscale"
        docker exec sahabi-tailscale tailscale status 2>/dev/null || true
        
        # Instructions pour Tailscale Serve
        echo ""
        print_header "Configuration Tailscale Serve"
        echo -e "${YELLOW}Pour exposer votre application via Tailscale, exécutez :${NC}"
        echo ""
        echo -e "${CYAN}  docker exec -it sahabi-tailscale sh${NC}"
        echo -e "${CYAN}  tailscale serve https / http://frontend:80${NC}"
        echo -e "${CYAN}  exit${NC}"
        echo ""
        echo -e "${YELLOW}Pour un accès PUBLIC (sans installation Tailscale) :${NC}"
        echo ""
        echo -e "${CYAN}  docker exec -it sahabi-tailscale sh${NC}"
        echo -e "${CYAN}  tailscale funnel 443 on${NC}"
        echo -e "${CYAN}  exit${NC}"
        echo ""
    else
        print_error "Erreur lors du démarrage des services"
        echo ""
        echo -e "${YELLOW}Consultez les logs avec : docker-compose logs${NC}"
        exit 1
    fi
}

configure_caddy() {
    print_header "Configuration Caddy + Domaine"
    
    if [ -z "$DOMAIN" ]; then
        print_error "Le nom de domaine est requis"
        echo ""
        echo -e "${YELLOW}Exemple : ./deploy-internet.sh caddy --domain \"sahabi-guide.com\" --email \"admin@example.com\"${NC}"
        exit 1
    fi
    
    if [ -z "$EMAIL" ]; then
        print_error "L'email est requis pour les certificats SSL"
        echo ""
        echo -e "${YELLOW}Exemple : ./deploy-internet.sh caddy --domain \"sahabi-guide.com\" --email \"admin@example.com\"${NC}"
        exit 1
    fi
    
    # Vérifier les DNS
    print_info "Vérification des DNS pour $DOMAIN..."
    if host "$DOMAIN" &> /dev/null; then
        local ip_address=$(host "$DOMAIN" | grep "has address" | head -1 | awk '{print $4}')
        print_success "DNS configuré : $DOMAIN → $ip_address"
    else
        print_warning "Impossible de résoudre $DOMAIN"
        echo -e "${YELLOW}  Assurez-vous que les enregistrements DNS sont configurés :${NC}"
        echo "    A    @     VOTRE_IP_SERVEUR"
        echo "    A    api   VOTRE_IP_SERVEUR"
        echo "    A    auth  VOTRE_IP_SERVEUR"
        echo ""
        read -p "Continuer quand même ? (o/N) " continue
        if [[ ! "$continue" =~ ^[oO]$ ]]; then
            exit 1
        fi
    fi
    
    # Créer le fichier .env si nécessaire
    create_env_file
    
    # Mettre à jour .env
    print_info "Mise à jour de la configuration dans .env..."
    sed -i "s|DOMAIN=.*|DOMAIN=$DOMAIN|g" .env
    sed -i "s|ACME_EMAIL=.*|ACME_EMAIL=$EMAIL|g" .env
    sed -i "s|KEYCLOAK_HOSTNAME=.*|KEYCLOAK_HOSTNAME=auth.$DOMAIN|g" .env
    sed -i "s|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=https://api.$DOMAIN|g" .env
    sed -i "s|VITE_KEYCLOAK_URL=.*|VITE_KEYCLOAK_URL=https://auth.$DOMAIN|g" .env
    sed -i "s|CORS_ALLOWED_ORIGINS=.*|CORS_ALLOWED_ORIGINS=https://$DOMAIN,https://api.$DOMAIN,https://auth.$DOMAIN|g" .env
    print_success "Configuration mise à jour"
    
    # Avertissement pour Keycloak realm
    echo ""
    print_warning "ACTION REQUISE : Mise à jour du Keycloak Realm"
    echo -e "${YELLOW}  Vous devez mettre à jour les URLs de redirection dans :${NC}"
    echo -e "${CYAN}  sahabi-guide-api/keycloak/import/sahabi-realm.json${NC}"
    echo ""
    echo -e "${YELLOW}  Ajoutez ces URLs dans le client 'sahabi-dashboard' :${NC}"
    echo -e "${CYAN}    redirectUris: [\"https://$DOMAIN/*\"]${NC}"
    echo -e "${CYAN}    webOrigins: [\"https://$DOMAIN\"]${NC}"
    echo ""
    read -p "Appuyez sur Entrée quand c'est fait (ou Ctrl+C pour annuler) "
    
    # Arrêter les services existants
    print_info "Arrêt des services en cours..."
    docker-compose down 2>/dev/null || true
    
    # Supprimer l'image frontend pour forcer le rebuild
    print_info "Suppression de l'image frontend pour rebuild..."
    docker rmi sahabi-guide-dashboard-frontend 2>/dev/null || true
    
    # Démarrer avec le profil production et rebuild
    print_info "Démarrage des services avec Caddy..."
    echo ""
    docker-compose --profile production up -d --build
    
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Services démarrés avec succès !"
        
        # Attendre que Caddy soit prêt
        print_info "Attente du démarrage de Caddy (30 secondes)..."
        sleep 30
        
        # Vérifier les certificats
        print_header "Vérification des certificats SSL"
        docker exec sahabi-caddy caddy list-certificates 2>/dev/null || true
        
        echo ""
        print_header "🎉 Déploiement terminé !"
        echo ""
        echo -e "${GREEN}Votre application est accessible via :${NC}"
        echo -e "${CYAN}  🎨 Frontend   : https://$DOMAIN${NC}"
        echo -e "${CYAN}  🔧 API        : https://api.$DOMAIN${NC}"
        echo -e "${CYAN}  🔐 Keycloak   : https://auth.$DOMAIN${NC}"
        echo ""
        echo -e "${YELLOW}Vérifiez les logs avec : docker-compose logs -f caddy${NC}"
        echo ""
    else
        print_error "Erreur lors du démarrage des services"
        echo ""
        echo -e "${YELLOW}Consultez les logs avec : docker-compose logs${NC}"
        exit 1
    fi
}

configure_direct() {
    print_header "Configuration Exposition Directe"
    
    print_warning "ATTENTION : Cette méthode n'est PAS recommandée en production !"
    echo -e "${YELLOW}  • Pas de SSL (données non chiffrées)${NC}"
    echo -e "${YELLOW}  • Ports non standard${NC}"
    echo -e "${YELLOW}  • Moins sécurisé${NC}"
    echo ""
    echo -e "${RED}Utilisez cette méthode uniquement pour des TESTS !${NC}"
    echo ""
    read -p "Continuer quand même ? (o/N) " continue
    if [[ ! "$continue" =~ ^[oO]$ ]]; then
        print_info "Déploiement annulé"
        exit 0
    fi
    
    # Créer le fichier .env si nécessaire
    create_env_file
    
    # Modifier docker-compose.yml pour exposer Keycloak publiquement
    print_info "Modification de docker-compose.yml pour exposer Keycloak..."
    sed -i 's|127\.0\.0\.1:${KEYCLOAK_PORT:-8080}:8080|${KEYCLOAK_PORT:-8080}:8080|g' docker-compose.yml
    print_success "docker-compose.yml modifié"
    
    # Arrêter les services existants
    print_info "Arrêt des services en cours..."
    docker-compose down 2>/dev/null || true
    
    # Démarrer les services de base
    print_info "Démarrage des services..."
    echo ""
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Services démarrés avec succès !"
        
        # Obtenir l'IP publique
        print_info "Récupération de votre IP publique..."
        local public_ip=$(curl -s https://api.ipify.org || echo "VOTRE_IP_PUBLIQUE")
        if [ "$public_ip" != "VOTRE_IP_PUBLIQUE" ]; then
            print_success "IP publique : $public_ip"
        else
            print_warning "Impossible de récupérer l'IP publique automatiquement"
        fi
        
        echo ""
        print_header "⚠️  Configuration du Pare-feu Requise"
        echo -e "${YELLOW}Vous devez ouvrir ces ports sur votre pare-feu :${NC}"
        echo ""
        echo -e "${CYAN}sudo ufw allow 3000/tcp  # Frontend${NC}"
        echo -e "${CYAN}sudo ufw allow 8080/tcp  # Keycloak${NC}"
        echo -e "${CYAN}sudo ufw allow 8084/tcp  # Backend${NC}"
        echo ""
        read -p "Configurer le pare-feu maintenant ? (o/N) " config_firewall
        if [[ "$config_firewall" =~ ^[oO]$ ]]; then
            if command -v ufw &> /dev/null; then
                sudo ufw allow 3000/tcp
                sudo ufw allow 8080/tcp
                sudo ufw allow 8084/tcp
                print_success "Règles de pare-feu créées"
            else
                print_warning "UFW n'est pas installé, configurez votre pare-feu manuellement"
            fi
        fi
        
        echo ""
        print_header "🎉 Déploiement terminé !"
        echo ""
        echo -e "${GREEN}Votre application est accessible via :${NC}"
        echo -e "${CYAN}  🎨 Frontend   : http://${public_ip}:3000${NC}"
        echo -e "${CYAN}  🔧 API        : http://${public_ip}:8084${NC}"
        echo -e "${CYAN}  🔐 Keycloak   : http://${public_ip}:8080${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  N'oubliez pas :${NC}"
        echo -e "${YELLOW}  • Configurer le port forwarding sur votre box Internet${NC}"
        echo -e "${YELLOW}  • Cette configuration n'a PAS de SSL (HTTP uniquement)${NC}"
        echo ""
    else
        print_error "Erreur lors du démarrage des services"
        echo ""
        echo -e "${YELLOW}Consultez les logs avec : docker-compose logs${NC}"
        exit 1
    fi
}

show_status() {
    print_header "État des Services"
    docker-compose ps
    
    echo ""
    print_info "Pour voir les logs : docker-compose logs -f"
    print_info "Pour arrêter : docker-compose down"
}

#######################################################
# MAIN
#######################################################

print_header "🌐 Déploiement Internet - Sahabi Guide"

# Parser les arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

MODE=$1
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --key|-k)
            TAILSCALE_KEY="$2"
            shift 2
            ;;
        --domain|-d)
            DOMAIN="$2"
            shift 2
            ;;
        --email|-e)
            EMAIL="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Option inconnue : $1"
            show_help
            exit 1
            ;;
    esac
done

# Afficher l'aide si demandé
if [ "$MODE" = "help" ]; then
    show_help
    exit 0
fi

# Vérifier les prérequis
if ! test_prerequisites; then
    echo ""
    print_error "Les prérequis ne sont pas satisfaits"
    echo -e "${YELLOW}Corrigez les erreurs ci-dessus et relancez le script${NC}"
    exit 1
fi

# Exécuter le mode choisi
case "$MODE" in
    tailscale)
        configure_tailscale
        ;;
    caddy)
        configure_caddy
        ;;
    direct)
        configure_direct
        ;;
    *)
        print_error "Mode invalide : $MODE"
        echo ""
        show_help
        exit 1
        ;;
esac

# Afficher le statut final
echo ""
show_status

echo ""
print_success "Déploiement terminé avec succès !"
echo ""
echo -e "${CYAN}📚 Pour plus d'informations, consultez ACCES_INTERNET.md${NC}"
echo ""

