#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Démarre le projet SahabiGuide avec Keycloak OBLIGATOIRE

.DESCRIPTION
    Ce script garantit que Keycloak est démarré et fonctionnel avant de lancer
    le dashboard et le backend. Il active automatiquement les modes de sécurité.

.EXAMPLE
    .\scripts\start-with-keycloak.ps1
#>

[CmdletBinding()]
param()

# Couleurs pour les messages
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error-Custom { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Configuration
$PROJECT_ROOT = Split-Path -Parent $PSScriptRoot
$KEYCLOAK_URL = "http://localhost:8080"
$KEYCLOAK_HEALTH_CHECK_URL = "$KEYCLOAK_URL/health"
$MAX_WAIT_TIME = 120  # secondes

Write-Info "🚀 Démarrage du projet SahabiGuide avec Keycloak"
Write-Info "=================================================="

# Vérifier si Docker est installé
try {
    $dockerVersion = docker --version
    Write-Success "Docker est installé : $dockerVersion"
} catch {
    Write-Error-Custom "Docker n'est pas installé ou n'est pas dans le PATH"
    exit 1
}

# Vérifier si le fichier .env existe
$envFile = Join-Path $PROJECT_ROOT ".env"
if (-not (Test-Path $envFile)) {
    Write-Warning "Fichier .env non trouvé. Création à partir du template..."
    $envTemplate = Join-Path $PROJECT_ROOT "env.template"
    
    if (Test-Path $envTemplate) {
        Copy-Item $envTemplate $envFile
        Write-Success ".env créé depuis env.template"
    } else {
        Write-Error-Custom "env.template non trouvé !"
        exit 1
    }
}

# Vérifier et corriger les variables dans .env
Write-Info "Vérification des variables d'environnement..."

$envContent = Get-Content $envFile -Raw

# Vérifier VITE_ENABLE_KEYCLOAK
if ($envContent -notmatch 'VITE_ENABLE_KEYCLOAK=true') {
    Write-Warning "VITE_ENABLE_KEYCLOAK n'est pas à 'true', correction en cours..."
    $envContent = $envContent -replace 'VITE_ENABLE_KEYCLOAK=false', 'VITE_ENABLE_KEYCLOAK=true'
    if ($envContent -notmatch 'VITE_ENABLE_KEYCLOAK=') {
        $envContent += "`nVITE_ENABLE_KEYCLOAK=true"
    }
    Set-Content $envFile $envContent
    Write-Success "VITE_ENABLE_KEYCLOAK activé"
}

# Vérifier APP_SECURITY_ENABLED
if ($envContent -notmatch 'APP_SECURITY_ENABLED=true') {
    Write-Warning "APP_SECURITY_ENABLED n'est pas à 'true', correction en cours..."
    $envContent = Get-Content $envFile -Raw
    $envContent = $envContent -replace 'APP_SECURITY_ENABLED=false', 'APP_SECURITY_ENABLED=true'
    if ($envContent -notmatch 'APP_SECURITY_ENABLED=') {
        $envContent += "`nAPP_SECURITY_ENABLED=true"
    }
    Set-Content $envFile $envContent
    Write-Success "APP_SECURITY_ENABLED activé"
}

# Démarrer PostgreSQL et Keycloak avec Docker Compose
Write-Info "📦 Démarrage de PostgreSQL et Keycloak..."

Push-Location $PROJECT_ROOT
try {
    # Arrêter les conteneurs existants si nécessaire
    docker-compose down postgres keycloak 2>$null
    
    # Démarrer les services
    docker-compose up -d postgres keycloak
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Échec du démarrage de Docker Compose"
        exit 1
    }
    
    Write-Success "Conteneurs démarrés"
} finally {
    Pop-Location
}

# Attendre que PostgreSQL soit prêt
Write-Info "⏳ Attente de PostgreSQL..."
$postgresReady = $false
$elapsed = 0
while (-not $postgresReady -and $elapsed -lt 30) {
    try {
        $healthCheck = docker exec sahabi-postgres pg_isready -U sahabi 2>$null
        if ($healthCheck -match "accepting connections") {
            $postgresReady = $true
            Write-Success "PostgreSQL est prêt"
        }
    } catch {
        # Ignorer les erreurs et réessayer
    }
    
    if (-not $postgresReady) {
        Start-Sleep -Seconds 2
        $elapsed += 2
        Write-Host "." -NoNewline
    }
}

if (-not $postgresReady) {
    Write-Error-Custom "PostgreSQL n'a pas démarré dans les temps"
    exit 1
}

# Attendre que Keycloak soit prêt
Write-Info "⏳ Attente de Keycloak (peut prendre jusqu'à 2 minutes)..."
$keycloakReady = $false
$elapsed = 0

while (-not $keycloakReady -and $elapsed -lt $MAX_WAIT_TIME) {
    try {
        $response = Invoke-WebRequest -Uri $KEYCLOAK_HEALTH_CHECK_URL -Method Get -TimeoutSec 5 -UseBasicParsing 2>$null
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
            Write-Success "Keycloak est prêt et accessible"
        }
    } catch {
        # Ignorer les erreurs et réessayer
    }
    
    if (-not $keycloakReady) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        Write-Host "." -NoNewline
    }
}

Write-Host ""  # Nouvelle ligne après les points

if (-not $keycloakReady) {
    Write-Error-Custom "Keycloak n'a pas démarré dans les temps ($MAX_WAIT_TIME secondes)"
    Write-Info "Vérifiez les logs : docker logs sahabi-keycloak"
    exit 1
}

# Afficher les informations de connexion Keycloak
Write-Info ""
Write-Info "🔐 KEYCLOAK EST PRÊT"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Info "Admin Console : $KEYCLOAK_URL/admin"
Write-Info "Realm : sahabi"
Write-Info "Client : sahabi-dashboard"
Write-Info ""
Write-Success "Credentials (par défaut) :"
Write-Host "  Username: " -NoNewline
Write-Host "admin" -ForegroundColor Yellow
Write-Host "  Password: " -NoNewline
Write-Host "admin123" -ForegroundColor Yellow
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Info ""

# Options de démarrage
Write-Info "🎯 Choisissez comment démarrer le projet :"
Write-Host ""
Write-Host "1. " -NoNewline -ForegroundColor Cyan
Write-Host "Démarrer le Backend ET le Dashboard (mode développement)"
Write-Host "2. " -NoNewline -ForegroundColor Cyan
Write-Host "Démarrer uniquement le Backend"
Write-Host "3. " -NoNewline -ForegroundColor Cyan
Write-Host "Démarrer uniquement le Dashboard"
Write-Host "4. " -NoNewline -ForegroundColor Cyan
Write-Host "Démarrer tous les services avec Docker Compose (mode production)"
Write-Host "5. " -NoNewline -ForegroundColor Cyan
Write-Host "Arrêter et quitter"
Write-Host ""

$choice = Read-Host "Votre choix (1-5)"

switch ($choice) {
    "1" {
        Write-Info "🚀 Démarrage du Backend et du Dashboard..."
        
        # Démarrer le backend en arrière-plan
        Write-Info "Démarrage du Backend (port 8084)..."
        $backendPath = Join-Path $PROJECT_ROOT "sahabi-guide-api"
        
        Start-Process powershell -ArgumentList @(
            "-NoExit",
            "-Command",
            "cd '$backendPath'; `$env:APP_SECURITY_ENABLED='true'; `$env:OIDC_ISSUER_URI='http://localhost:8080/realms/sahabi'; Write-Host '🔧 Backend Spring Boot' -ForegroundColor Green; ./mvnw spring-boot:run"
        )
        
        Start-Sleep -Seconds 5
        
        # Démarrer le dashboard
        Write-Info "Démarrage du Dashboard (port 3000)..."
        $dashboardPath = Join-Path $PROJECT_ROOT "sahabi-guide-dashboard"
        
        Start-Process powershell -ArgumentList @(
            "-NoExit",
            "-Command",
            "cd '$dashboardPath'; `$env:VITE_ENABLE_KEYCLOAK='true'; `$env:VITE_KEYCLOAK_URL='http://localhost:8080'; Write-Host '🎨 Dashboard React' -ForegroundColor Cyan; npm run dev"
        )
        
        Write-Success "Services démarrés dans de nouvelles fenêtres PowerShell"
        Write-Info ""
        Write-Info "Accès aux services :"
        Write-Info "  - Dashboard : http://localhost:3000"
        Write-Info "  - Backend API : http://localhost:8084"
        Write-Info "  - Keycloak Admin : http://localhost:8080/admin"
    }
    
    "2" {
        Write-Info "🚀 Démarrage du Backend uniquement..."
        $backendPath = Join-Path $PROJECT_ROOT "sahabi-guide-api"
        
        Push-Location $backendPath
        try {
            $env:APP_SECURITY_ENABLED = "true"
            $env:OIDC_ISSUER_URI = "http://localhost:8080/realms/sahabi"
            Write-Success "Backend accessible sur http://localhost:8084"
            ./mvnw spring-boot:run
        } finally {
            Pop-Location
        }
    }
    
    "3" {
        Write-Info "🚀 Démarrage du Dashboard uniquement..."
        $dashboardPath = Join-Path $PROJECT_ROOT "sahabi-guide-dashboard"
        
        Push-Location $dashboardPath
        try {
            $env:VITE_ENABLE_KEYCLOAK = "true"
            $env:VITE_KEYCLOAK_URL = "http://localhost:8080"
            Write-Success "Dashboard accessible sur http://localhost:3000"
            npm run dev
        } finally {
            Pop-Location
        }
    }
    
    "4" {
        Write-Info "🚀 Démarrage de tous les services avec Docker Compose..."
        
        Push-Location $PROJECT_ROOT
        try {
            docker-compose up -d
            Write-Success "Tous les services Docker sont démarrés"
            Write-Info ""
            Write-Info "Accès aux services :"
            Write-Info "  - Dashboard : http://localhost:3000"
            Write-Info "  - Backend API : http://localhost:8084"
            Write-Info "  - Keycloak Admin : http://localhost:8080/admin"
            Write-Info "  - PgAdmin (si profil 'tools' activé) : http://localhost:5050"
        } finally {
            Pop-Location
        }
    }
    
    "5" {
        Write-Warning "Arrêt des services..."
        Push-Location $PROJECT_ROOT
        try {
            docker-compose down
            Write-Success "Services arrêtés"
        } finally {
            Pop-Location
        }
        exit 0
    }
    
    default {
        Write-Error-Custom "Choix invalide"
        exit 1
    }
}

Write-Info ""
Write-Success "✅ Projet démarré avec succès avec Keycloak activé !"
Write-Info ""
Write-Info "Pour arrêter les services Docker :"
Write-Info "  docker-compose down"



