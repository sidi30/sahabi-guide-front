#######################################################
# 🚀 Script de Déploiement Automatique - Google Cloud Run (PowerShell)
#######################################################
# Déploie tous les services Sahabi Guide sur Cloud Run
#
# Usage: .\scripts\deployment\deploy-cloud-run.ps1
#######################################################

$ErrorActionPreference = "Stop"

# Couleurs pour les logs
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host $Title -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host ""
}

# Vérifier les prérequis
function Test-Prerequisites {
    Write-Section "Vérification des Prérequis"
    
    # Vérifier gcloud
    if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
        Write-Error "gcloud CLI n'est pas installé"
        exit 1
    }
    Write-Success "gcloud CLI installé"
    
    # Vérifier docker
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker n'est pas installé"
        exit 1
    }
    Write-Success "Docker installé"
    
    # Vérifier l'authentification
    $account = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
    if (-not $account) {
        Write-Error "Vous n'êtes pas authentifié. Exécutez: gcloud auth login"
        exit 1
    }
    Write-Success "Authentifié sur Google Cloud"
}

# Configuration
function Set-Configuration {
    Write-Section "Configuration"
    
    # Demander le PROJECT_ID
    $script:PROJECT_ID = Read-Host "Entrez votre PROJECT_ID Google Cloud"
    
    # Demander la REGION
    $regionInput = Read-Host "Entrez la région (défaut: europe-west1)"
    $script:REGION = if ($regionInput) { $regionInput } else { "europe-west1" }
    
    # Définir le nom du registre
    $script:ARTIFACT_REGISTRY = "sahabi-registry"
    
    Write-Info "PROJECT_ID: $PROJECT_ID"
    Write-Info "REGION: $REGION"
    Write-Info "ARTIFACT_REGISTRY: $ARTIFACT_REGISTRY"
    
    # Configurer gcloud
    gcloud config set project $PROJECT_ID
    Write-Success "Projet configuré"
}

# Activer les APIs
function Enable-APIs {
    Write-Section "Activation des APIs Google Cloud"
    
    Write-Info "Activation des APIs nécessaires..."
    gcloud services enable `
        run.googleapis.com `
        sqladmin.googleapis.com `
        artifactregistry.googleapis.com `
        secretmanager.googleapis.com `
        cloudbuild.googleapis.com
    
    Write-Success "APIs activées"
}

# Créer Artifact Registry
function New-ArtifactRegistry {
    Write-Section "Création de l'Artifact Registry"
    
    # Vérifier si le registre existe déjà
    $registryExists = gcloud artifacts repositories describe $ARTIFACT_REGISTRY --location=$REGION 2>$null
    
    if ($registryExists) {
        Write-Warning "Le registre $ARTIFACT_REGISTRY existe déjà"
    } else {
        Write-Info "Création du registre Docker..."
        gcloud artifacts repositories create $ARTIFACT_REGISTRY `
            --repository-format=docker `
            --location=$REGION `
            --description="Registre Docker pour Sahabi Guide"
        
        Write-Success "Registre créé"
    }
    
    # Configurer Docker
    Write-Info "Configuration de Docker..."
    gcloud auth configure-docker "$REGION-docker.pkg.dev"
    Write-Success "Docker configuré"
}

# Créer Cloud SQL
function New-CloudSQL {
    Write-Section "Configuration de Cloud SQL"
    
    $INSTANCE_NAME = "sahabi-postgres"
    
    # Vérifier si l'instance existe
    $instanceExists = gcloud sql instances describe $INSTANCE_NAME 2>$null
    
    if ($instanceExists) {
        Write-Warning "L'instance Cloud SQL $INSTANCE_NAME existe déjà"
    } else {
        Write-Info "Création de l'instance PostgreSQL..."
        gcloud sql instances create $INSTANCE_NAME `
            --database-version=POSTGRES_15 `
            --tier=db-f1-micro `
            --region=$REGION `
            --database-flags=max_connections=100 `
            --backup-start-time=03:00 `
            --maintenance-window-day=SUN `
            --maintenance-window-hour=4
        
        Write-Success "Instance Cloud SQL créée"
        
        Write-Info "Attente que l'instance soit prête..."
        Start-Sleep -Seconds 30
    }
    
    # Créer les bases de données
    Write-Info "Création des bases de données..."
    gcloud sql databases create sahabi_db --instance=$INSTANCE_NAME 2>$null
    gcloud sql databases create keycloak_db --instance=$INSTANCE_NAME 2>$null
    
    # Créer les utilisateurs
    Write-Info "Création des utilisateurs..."
    $script:SAHABI_PASSWORD = Read-Host "Entrez le mot de passe pour l'utilisateur 'sahabi'" -AsSecureString
    $SAHABI_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SAHABI_PASSWORD))
    
    gcloud sql users create sahabi --instance=$INSTANCE_NAME --password=$SAHABI_PASSWORD_PLAIN 2>$null
    
    $script:KEYCLOAK_DB_PASSWORD = Read-Host "Entrez le mot de passe pour l'utilisateur 'keycloak'" -AsSecureString
    $KEYCLOAK_DB_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($KEYCLOAK_DB_PASSWORD))
    
    gcloud sql users create keycloak --instance=$INSTANCE_NAME --password=$KEYCLOAK_DB_PASSWORD_PLAIN 2>$null
    
    # Récupérer la connection string
    $script:CONNECTION_NAME = gcloud sql instances describe $INSTANCE_NAME --format="value(connectionName)"
    Write-Success "Connection string: $CONNECTION_NAME"
}

# Créer les secrets
function New-Secrets {
    Write-Section "Configuration des Secrets"
    
    # JWT Secret
    $jwtExists = gcloud secrets describe jwt-secret 2>$null
    if ($jwtExists) {
        Write-Warning "Secret jwt-secret existe déjà"
    } else {
        Write-Info "Génération du JWT secret..."
        $jwtSecret = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
        $jwtSecret | gcloud secrets create jwt-secret --data-file=-
        Write-Success "JWT secret créé"
    }
    
    # Database passwords
    $dbPasswordExists = gcloud secrets describe db-password 2>$null
    if ($dbPasswordExists) {
        Write-Warning "Secret db-password existe déjà"
    } else {
        $SAHABI_PASSWORD_PLAIN | gcloud secrets create db-password --data-file=-
        Write-Success "Database password créé"
    }
    
    $keycloakDbPasswordExists = gcloud secrets describe keycloak-db-password 2>$null
    if ($keycloakDbPasswordExists) {
        Write-Warning "Secret keycloak-db-password existe déjà"
    } else {
        $KEYCLOAK_DB_PASSWORD_PLAIN | gcloud secrets create keycloak-db-password --data-file=-
        Write-Success "Keycloak DB password créé"
    }
    
    # Keycloak admin password
    $keycloakAdminExists = gcloud secrets describe keycloak-admin-password 2>$null
    if ($keycloakAdminExists) {
        Write-Warning "Secret keycloak-admin-password existe déjà"
    } else {
        $KEYCLOAK_ADMIN_PASSWORD = Read-Host "Entrez le mot de passe admin Keycloak" -AsSecureString
        $KEYCLOAK_ADMIN_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($KEYCLOAK_ADMIN_PASSWORD))
        $KEYCLOAK_ADMIN_PASSWORD_PLAIN | gcloud secrets create keycloak-admin-password --data-file=-
        Write-Success "Keycloak admin password créé"
    }
}

# Déployer Keycloak
function Deploy-Keycloak {
    Write-Section "Déploiement de Keycloak"
    
    Push-Location sahabi-guide-keycloak
    
    # Build
    Write-Info "Build de l'image Keycloak..."
    docker build -t "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest" .
    
    # Push
    Write-Info "Push de l'image..."
    docker push "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest"
    
    # Deploy
    Write-Info "Déploiement sur Cloud Run..."
    gcloud run deploy sahabi-keycloak `
        --image="$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest" `
        --region=$REGION `
        --platform=managed `
        --allow-unauthenticated `
        --memory=1Gi `
        --cpu=2 `
        --timeout=300 `
        --max-instances=5 `
        --min-instances=1 `
        --set-env-vars="KC_HOSTNAME_STRICT=false,KC_HOSTNAME_STRICT_HTTPS=false,KC_HTTP_ENABLED=true,KC_PROXY_HEADERS=xforwarded,KC_PROXY=edge,KC_DB=postgres,KC_DB_URL_HOST=/cloudsql/$CONNECTION_NAME,KC_DB_URL_PORT=5432,KC_DB_URL_DATABASE=keycloak_db,KC_DB_USERNAME=keycloak,KC_DB_SCHEMA=public,KC_HEALTH_ENABLED=true,KC_METRICS_ENABLED=true,KC_LOG_LEVEL=INFO" `
        --set-secrets="KC_DB_PASSWORD=keycloak-db-password:latest,KC_BOOTSTRAP_ADMIN_PASSWORD=keycloak-admin-password:latest" `
        --add-cloudsql-instances=$CONNECTION_NAME
    
    # Récupérer l'URL
    $script:KEYCLOAK_URL = gcloud run services describe sahabi-keycloak --region=$REGION --format="value(status.url)"
    Write-Success "Keycloak déployé: $KEYCLOAK_URL"
    
    # Mettre à jour le hostname
    Write-Info "Mise à jour du hostname..."
    $KEYCLOAK_HOSTNAME = $KEYCLOAK_URL -replace "https://", ""
    gcloud run services update sahabi-keycloak --region=$REGION --update-env-vars="KC_HOSTNAME=$KEYCLOAK_HOSTNAME"
    
    Pop-Location
}

# Déployer Backend
function Deploy-Backend {
    Write-Section "Déploiement du Backend"
    
    Push-Location sahabi-guide-api
    
    # Build
    Write-Info "Build de l'image Backend..."
    docker build -t "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest" .
    
    # Push
    Write-Info "Push de l'image..."
    docker push "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest"
    
    # Deploy
    Write-Info "Déploiement sur Cloud Run..."
    gcloud run deploy sahabi-backend `
        --image="$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest" `
        --region=$REGION `
        --platform=managed `
        --allow-unauthenticated `
        --memory=768Mi `
        --cpu=2 `
        --timeout=300 `
        --max-instances=10 `
        --min-instances=1 `
        --set-env-vars="SPRING_PROFILES_ACTIVE=prod,DB_HOST=/cloudsql/$CONNECTION_NAME,DB_PORT=5432,DB_NAME=sahabi_db,DB_USERNAME=sahabi,OIDC_ISSUER_URI=$KEYCLOAK_URL/realms/sahabi,JWT_EXPIRATION=7776000,JWT_ISSUER=sahabi-guide" `
        --set-secrets="DB_PASSWORD=db-password:latest,JWT_SECRET=jwt-secret:latest" `
        --add-cloudsql-instances=$CONNECTION_NAME
    
    # Récupérer l'URL
    $script:BACKEND_URL = gcloud run services describe sahabi-backend --region=$REGION --format="value(status.url)"
    Write-Success "Backend déployé: $BACKEND_URL"
    
    Pop-Location
}

# Déployer Frontend
function Deploy-Frontend {
    Write-Section "Déploiement du Frontend"
    
    Push-Location sahabi-guide-dashboard
    
    # Build
    Write-Info "Build de l'image Frontend..."
    docker build `
        --build-arg VITE_API_BASE_URL=$BACKEND_URL `
        --build-arg VITE_API_BASE_PATH=/api/v1 `
        --build-arg VITE_ENABLE_KEYCLOAK=true `
        --build-arg VITE_KEYCLOAK_URL=$KEYCLOAK_URL `
        --build-arg VITE_KEYCLOAK_REALM=sahabi `
        --build-arg VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard `
        -t "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest" .
    
    # Push
    Write-Info "Push de l'image..."
    docker push "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest"
    
    # Deploy
    Write-Info "Déploiement sur Cloud Run..."
    gcloud run deploy sahabi-frontend `
        --image="$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest" `
        --region=$REGION `
        --platform=managed `
        --allow-unauthenticated `
        --memory=256Mi `
        --cpu=1 `
        --timeout=60 `
        --max-instances=10 `
        --min-instances=0
    
    # Récupérer l'URL
    $script:FRONTEND_URL = gcloud run services describe sahabi-frontend --region=$REGION --format="value(status.url)"
    Write-Success "Frontend déployé: $FRONTEND_URL"
    
    Pop-Location
}

# Mettre à jour CORS
function Update-CORS {
    Write-Section "Configuration CORS"
    
    Write-Info "Mise à jour des CORS sur le backend..."
    gcloud run services update sahabi-backend `
        --region=$REGION `
        --update-env-vars="CORS_ALLOWED_ORIGINS=$FRONTEND_URL,$KEYCLOAK_URL"
    
    Write-Success "CORS configuré"
}

# Résumé final
function Show-Summary {
    Write-Section "🎉 Déploiement Terminé !"
    
    Write-Host ""
    Write-Host "📌 URLs des Services :" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Frontend:  $FRONTEND_URL" -ForegroundColor Blue
    Write-Host "  Backend:   $BACKEND_URL" -ForegroundColor Blue
    Write-Host "  Keycloak:  $KEYCLOAK_URL" -ForegroundColor Blue
    Write-Host ""
    Write-Host "⚠️  Actions Requises :" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Configurer Keycloak :"
    Write-Host "     - Accéder à: $KEYCLOAK_URL/admin"
    Write-Host "     - Configurer les Redirect URIs du client 'sahabi-dashboard'"
    Write-Host "     - Ajouter: $FRONTEND_URL/*"
    Write-Host ""
    Write-Host "  2. Tester l'application :"
    Write-Host "     - Ouvrir: $FRONTEND_URL"
    Write-Host ""
    Write-Host "✅ Pour plus d'informations, consultez :" -ForegroundColor Green
    Write-Host "   - docs/deployment/GOOGLE_CLOUD_RUN_DEPLOYMENT.md"
    Write-Host "   - DEPLOIEMENT_CLOUD_RUN.md"
    Write-Host ""
}

# Main
function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║   🚀 Déploiement Sahabi Guide sur Cloud Run          ║" -ForegroundColor Blue
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    
    Test-Prerequisites
    Set-Configuration
    Enable-APIs
    New-ArtifactRegistry
    New-CloudSQL
    New-Secrets
    Deploy-Keycloak
    Deploy-Backend
    Deploy-Frontend
    Update-CORS
    Show-Summary
}

# Exécuter
Main

