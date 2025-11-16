#!/bin/bash
#######################################################
# 🚀 Script de Déploiement Automatique - Google Cloud Run
#######################################################
# Déploie tous les services Sahabi Guide sur Cloud Run
#
# Usage: ./scripts/deployment/deploy-cloud-run.sh
#######################################################

set -e  # Exit on error

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Vérifier les prérequis
check_prerequisites() {
    log_section "Vérification des Prérequis"
    
    # Vérifier gcloud
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI n'est pas installé"
        exit 1
    fi
    log_success "gcloud CLI installé"
    
    # Vérifier docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    log_success "Docker installé"
    
    # Vérifier l'authentification
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        log_error "Vous n'êtes pas authentifié. Exécutez: gcloud auth login"
        exit 1
    fi
    log_success "Authentifié sur Google Cloud"
}

# Configuration
configure() {
    log_section "Configuration"
    
    # Demander le PROJECT_ID si non défini
    if [ -z "$PROJECT_ID" ]; then
        read -p "Entrez votre PROJECT_ID Google Cloud: " PROJECT_ID
    fi
    
    # Demander la REGION si non définie
    if [ -z "$REGION" ]; then
        read -p "Entrez la région (défaut: europe-west1): " REGION
        REGION=${REGION:-europe-west1}
    fi
    
    # Définir le nom du registre
    ARTIFACT_REGISTRY=${ARTIFACT_REGISTRY:-sahabi-registry}
    
    log_info "PROJECT_ID: $PROJECT_ID"
    log_info "REGION: $REGION"
    log_info "ARTIFACT_REGISTRY: $ARTIFACT_REGISTRY"
    
    # Configurer gcloud
    gcloud config set project $PROJECT_ID
    log_success "Projet configuré"
}

# Activer les APIs
enable_apis() {
    log_section "Activation des APIs Google Cloud"
    
    log_info "Activation des APIs nécessaires..."
    gcloud services enable \
        run.googleapis.com \
        sqladmin.googleapis.com \
        artifactregistry.googleapis.com \
        secretmanager.googleapis.com \
        cloudbuild.googleapis.com
    
    log_success "APIs activées"
}

# Créer Artifact Registry
create_artifact_registry() {
    log_section "Création de l'Artifact Registry"
    
    # Vérifier si le registre existe déjà
    if gcloud artifacts repositories describe $ARTIFACT_REGISTRY \
        --location=$REGION &> /dev/null; then
        log_warning "Le registre $ARTIFACT_REGISTRY existe déjà"
    else
        log_info "Création du registre Docker..."
        gcloud artifacts repositories create $ARTIFACT_REGISTRY \
            --repository-format=docker \
            --location=$REGION \
            --description="Registre Docker pour Sahabi Guide"
        
        log_success "Registre créé"
    fi
    
    # Configurer Docker pour utiliser Artifact Registry
    log_info "Configuration de Docker..."
    gcloud auth configure-docker $REGION-docker.pkg.dev
    log_success "Docker configuré"
}

# Créer Cloud SQL
create_cloud_sql() {
    log_section "Configuration de Cloud SQL"
    
    INSTANCE_NAME="sahabi-postgres"
    
    # Vérifier si l'instance existe
    if gcloud sql instances describe $INSTANCE_NAME &> /dev/null; then
        log_warning "L'instance Cloud SQL $INSTANCE_NAME existe déjà"
    else
        log_info "Création de l'instance PostgreSQL..."
        gcloud sql instances create $INSTANCE_NAME \
            --database-version=POSTGRES_15 \
            --tier=db-f1-micro \
            --region=$REGION \
            --database-flags=max_connections=100 \
            --backup-start-time=03:00 \
            --maintenance-window-day=SUN \
            --maintenance-window-hour=4
        
        log_success "Instance Cloud SQL créée"
        
        # Attendre que l'instance soit prête
        log_info "Attente que l'instance soit prête..."
        sleep 30
    fi
    
    # Créer les bases de données
    log_info "Création des bases de données..."
    gcloud sql databases create sahabi_db --instance=$INSTANCE_NAME 2>/dev/null || log_warning "Base sahabi_db existe déjà"
    gcloud sql databases create keycloak_db --instance=$INSTANCE_NAME 2>/dev/null || log_warning "Base keycloak_db existe déjà"
    
    # Créer les utilisateurs
    log_info "Création des utilisateurs..."
    read -sp "Entrez le mot de passe pour l'utilisateur 'sahabi': " SAHABI_PASSWORD
    echo ""
    gcloud sql users create sahabi \
        --instance=$INSTANCE_NAME \
        --password=$SAHABI_PASSWORD 2>/dev/null || log_warning "Utilisateur sahabi existe déjà"
    
    read -sp "Entrez le mot de passe pour l'utilisateur 'keycloak': " KEYCLOAK_DB_PASSWORD
    echo ""
    gcloud sql users create keycloak \
        --instance=$INSTANCE_NAME \
        --password=$KEYCLOAK_DB_PASSWORD 2>/dev/null || log_warning "Utilisateur keycloak existe déjà"
    
    # Récupérer la connection string
    CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME \
        --format="value(connectionName)")
    log_success "Connection string: $CONNECTION_NAME"
    
    export CLOUD_SQL_CONNECTION=$CONNECTION_NAME
}

# Créer les secrets
create_secrets() {
    log_section "Configuration des Secrets"
    
    # JWT Secret
    if gcloud secrets describe jwt-secret &> /dev/null; then
        log_warning "Secret jwt-secret existe déjà"
    else
        log_info "Génération du JWT secret..."
        openssl rand -base64 32 | gcloud secrets create jwt-secret --data-file=-
        log_success "JWT secret créé"
    fi
    
    # Database passwords
    if gcloud secrets describe db-password &> /dev/null; then
        log_warning "Secret db-password existe déjà"
    else
        echo -n "$SAHABI_PASSWORD" | gcloud secrets create db-password --data-file=-
        log_success "Database password créé"
    fi
    
    if gcloud secrets describe keycloak-db-password &> /dev/null; then
        log_warning "Secret keycloak-db-password existe déjà"
    else
        echo -n "$KEYCLOAK_DB_PASSWORD" | gcloud secrets create keycloak-db-password --data-file=-
        log_success "Keycloak DB password créé"
    fi
    
    # Keycloak admin password
    if gcloud secrets describe keycloak-admin-password &> /dev/null; then
        log_warning "Secret keycloak-admin-password existe déjà"
    else
        read -sp "Entrez le mot de passe admin Keycloak: " KEYCLOAK_ADMIN_PASSWORD
        echo ""
        echo -n "$KEYCLOAK_ADMIN_PASSWORD" | gcloud secrets create keycloak-admin-password --data-file=-
        log_success "Keycloak admin password créé"
    fi
    
    # Twilio (optionnel)
    read -p "Configurer Twilio? (y/N): " configure_twilio
    if [[ $configure_twilio =~ ^[Yy]$ ]]; then
        if ! gcloud secrets describe twilio-account-sid &> /dev/null; then
            read -p "Twilio Account SID: " TWILIO_SID
            echo -n "$TWILIO_SID" | gcloud secrets create twilio-account-sid --data-file=-
            log_success "Twilio Account SID créé"
        fi
        
        if ! gcloud secrets describe twilio-auth-token &> /dev/null; then
            read -sp "Twilio Auth Token: " TWILIO_TOKEN
            echo ""
            echo -n "$TWILIO_TOKEN" | gcloud secrets create twilio-auth-token --data-file=-
            log_success "Twilio Auth Token créé"
        fi
    fi
}

# Build et deploy Keycloak
deploy_keycloak() {
    log_section "Déploiement de Keycloak"
    
    cd sahabi-guide-keycloak
    
    # Build
    log_info "Build de l'image Keycloak..."
    docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest .
    
    # Push
    log_info "Push de l'image..."
    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest
    
    # Deploy
    log_info "Déploiement sur Cloud Run..."
    gcloud run deploy sahabi-keycloak \
        --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest \
        --region=$REGION \
        --platform=managed \
        --allow-unauthenticated \
        --memory=1Gi \
        --cpu=2 \
        --timeout=300 \
        --max-instances=5 \
        --min-instances=1 \
        --set-env-vars="KC_HOSTNAME_STRICT=false,KC_HOSTNAME_STRICT_HTTPS=false,KC_HTTP_ENABLED=true,KC_PROXY_HEADERS=xforwarded,KC_PROXY=edge,KC_DB=postgres,KC_DB_URL_HOST=/cloudsql/$CLOUD_SQL_CONNECTION,KC_DB_URL_PORT=5432,KC_DB_URL_DATABASE=keycloak_db,KC_DB_USERNAME=keycloak,KC_DB_SCHEMA=public,KC_HEALTH_ENABLED=true,KC_METRICS_ENABLED=true,KC_LOG_LEVEL=INFO" \
        --set-secrets="KC_DB_PASSWORD=keycloak-db-password:latest,KC_BOOTSTRAP_ADMIN_PASSWORD=keycloak-admin-password:latest" \
        --add-cloudsql-instances=$CLOUD_SQL_CONNECTION
    
    # Récupérer l'URL
    export KEYCLOAK_URL=$(gcloud run services describe sahabi-keycloak \
        --region=$REGION --format="value(status.url)")
    
    log_success "Keycloak déployé: $KEYCLOAK_URL"
    
    # Mettre à jour le hostname
    log_info "Mise à jour du hostname..."
    KEYCLOAK_HOSTNAME=$(echo $KEYCLOAK_URL | sed 's|https://||')
    gcloud run services update sahabi-keycloak \
        --region=$REGION \
        --update-env-vars="KC_HOSTNAME=$KEYCLOAK_HOSTNAME"
    
    cd ..
}

# Build et deploy Backend
deploy_backend() {
    log_section "Déploiement du Backend"
    
    cd sahabi-guide-api
    
    # Build
    log_info "Build de l'image Backend..."
    docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest .
    
    # Push
    log_info "Push de l'image..."
    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest
    
    # Deploy
    log_info "Déploiement sur Cloud Run..."
    gcloud run deploy sahabi-backend \
        --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest \
        --region=$REGION \
        --platform=managed \
        --allow-unauthenticated \
        --memory=768Mi \
        --cpu=2 \
        --timeout=300 \
        --max-instances=10 \
        --min-instances=1 \
        --set-env-vars="SPRING_PROFILES_ACTIVE=prod,DB_HOST=/cloudsql/$CLOUD_SQL_CONNECTION,DB_PORT=5432,DB_NAME=sahabi_db,DB_USERNAME=sahabi,OIDC_ISSUER_URI=$KEYCLOAK_URL/realms/sahabi,JWT_EXPIRATION=7776000,JWT_ISSUER=sahabi-guide" \
        --set-secrets="DB_PASSWORD=db-password:latest,JWT_SECRET=jwt-secret:latest" \
        --add-cloudsql-instances=$CLOUD_SQL_CONNECTION
    
    # Récupérer l'URL
    export BACKEND_URL=$(gcloud run services describe sahabi-backend \
        --region=$REGION --format="value(status.url)")
    
    log_success "Backend déployé: $BACKEND_URL"
    
    cd ..
}

# Build et deploy Frontend
deploy_frontend() {
    log_section "Déploiement du Frontend"
    
    cd sahabi-guide-dashboard
    
    # Build avec les variables
    log_info "Build de l'image Frontend..."
    docker build \
        --build-arg VITE_API_BASE_URL=$BACKEND_URL \
        --build-arg VITE_API_BASE_PATH=/api/v1 \
        --build-arg VITE_ENABLE_KEYCLOAK=true \
        --build-arg VITE_KEYCLOAK_URL=$KEYCLOAK_URL \
        --build-arg VITE_KEYCLOAK_REALM=sahabi \
        --build-arg VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard \
        -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest .
    
    # Push
    log_info "Push de l'image..."
    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest
    
    # Deploy
    log_info "Déploiement sur Cloud Run..."
    gcloud run deploy sahabi-frontend \
        --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest \
        --region=$REGION \
        --platform=managed \
        --allow-unauthenticated \
        --memory=256Mi \
        --cpu=1 \
        --timeout=60 \
        --max-instances=10 \
        --min-instances=0
    
    # Récupérer l'URL
    export FRONTEND_URL=$(gcloud run services describe sahabi-frontend \
        --region=$REGION --format="value(status.url)")
    
    log_success "Frontend déployé: $FRONTEND_URL"
    
    cd ..
}

# Mettre à jour les CORS
update_cors() {
    log_section "Configuration CORS"
    
    log_info "Mise à jour des CORS sur le backend..."
    gcloud run services update sahabi-backend \
        --region=$REGION \
        --update-env-vars="CORS_ALLOWED_ORIGINS=$FRONTEND_URL,$KEYCLOAK_URL"
    
    log_success "CORS configuré"
}

# Résumé final
show_summary() {
    log_section "🎉 Déploiement Terminé !"
    
    echo ""
    echo -e "${GREEN}📌 URLs des Services :${NC}"
    echo ""
    echo -e "  ${BLUE}Frontend:${NC}  $FRONTEND_URL"
    echo -e "  ${BLUE}Backend:${NC}   $BACKEND_URL"
    echo -e "  ${BLUE}Keycloak:${NC}  $KEYCLOAK_URL"
    echo ""
    echo -e "${YELLOW}⚠️  Actions Requises :${NC}"
    echo ""
    echo "  1. Configurer Keycloak :"
    echo "     - Accéder à: $KEYCLOAK_URL/admin"
    echo "     - Configurer les Redirect URIs du client 'sahabi-dashboard'"
    echo "     - Ajouter: $FRONTEND_URL/*"
    echo ""
    echo "  2. Tester l'application :"
    echo "     - Ouvrir: $FRONTEND_URL"
    echo "     - Se connecter avec un utilisateur Keycloak"
    echo ""
    echo -e "${GREEN}✅ Pour plus d'informations, consultez :${NC}"
    echo "   - docs/deployment/GOOGLE_CLOUD_RUN_DEPLOYMENT.md"
    echo "   - DEPLOIEMENT_CLOUD_RUN.md"
    echo ""
}

# Main
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   🚀 Déploiement Sahabi Guide sur Cloud Run          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_prerequisites
    configure
    enable_apis
    create_artifact_registry
    create_cloud_sql
    create_secrets
    deploy_keycloak
    deploy_backend
    deploy_frontend
    update_cors
    show_summary
}

# Exécuter le script
main

