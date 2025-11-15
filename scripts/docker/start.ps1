#######################################################
# 🚀 Script de démarrage PowerShell - Sahabi Guide
#######################################################
# Ce script démarre tous les services Docker dans le bon ordre
#######################################################

$ErrorActionPreference = "Stop"

# Fichier docker-compose
$COMPOSE_FILE = "docker-compose.full.yml"

# Fonction pour afficher des messages colorés
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ " -ForegroundColor Blue -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

# Fonction pour attendre qu'un service soit prêt
function Wait-ForService {
    param(
        [string]$Service,
        [int]$MaxWait = 120
    )
    
    Write-Info "Attente du service $Service..."
    
    $elapsed = 0
    while ($elapsed -lt $MaxWait) {
        $status = docker-compose -f $COMPOSE_FILE ps $Service 2>&1
        if ($status -match "Up.*healthy") {
            Write-Success "$Service est prêt !"
            return $true
        }
        Start-Sleep -Seconds 5
        $elapsed += 5
        Write-Host "." -NoNewline
    }
    
    Write-Host ""
    Write-Error-Custom "$Service n'est pas prêt après ${MaxWait}s"
    return $false
}

# Banner
Write-Host ""
Write-Host "╔═══════════════════════════════════════════╗"
Write-Host "║     🚀 SAHABI GUIDE - DÉMARRAGE          ║"
Write-Host "╚═══════════════════════════════════════════╝"
Write-Host ""

# Vérification du fichier .env
if (-Not (Test-Path .env)) {
    Write-Warning "Fichier .env non trouvé !"
    Write-Info "Création à partir du template..."
    Copy-Item env.template .env
    Write-Warning "⚠️  IMPORTANT : Éditez le fichier .env avec vos valeurs avant de continuer !"
    Write-Info "Lancez : notepad .env (ou code .env)"
    exit 1
}

# Vérification de Docker
try {
    docker --version | Out-Null
    docker-compose --version | Out-Null
    Write-Success "Docker et Docker Compose sont installés"
} catch {
    Write-Error-Custom "Docker ou Docker Compose n'est pas installé !"
    exit 1
}

# Menu de démarrage
Write-Host ""
Write-Info "Sélectionnez le mode de démarrage :"
Write-Host "  1) Démarrage complet (tous les services)"
Write-Host "  2) Démarrage progressif (recommandé pour la première fois)"
Write-Host "  3) Développement (sans Caddy ni Tailscale)"
Write-Host "  4) Redémarrer tous les services"
Write-Host "  5) Quitter"
Write-Host ""
$choice = Read-Host "Votre choix [1-5]"

switch ($choice) {
    "1" {
        Write-Info "Démarrage de tous les services..."
        docker-compose -f $COMPOSE_FILE up -d
        Write-Success "Tous les services sont lancés !"
    }
    
    "2" {
        Write-Info "Démarrage progressif..."
        
        # PostgreSQL
        Write-Host ""
        Write-Info "📦 Étape 1/6 : Démarrage de PostgreSQL..."
        docker-compose -f $COMPOSE_FILE up -d postgres
        Wait-ForService -Service "postgres" -MaxWait 60
        
        # Keycloak
        Write-Host ""
        Write-Info "🔐 Étape 2/6 : Démarrage de Keycloak..."
        docker-compose -f $COMPOSE_FILE up -d keycloak
        Wait-ForService -Service "keycloak" -MaxWait 120
        
        # Backend
        Write-Host ""
        Write-Info "🔧 Étape 3/6 : Démarrage du Backend..."
        docker-compose -f $COMPOSE_FILE up -d backend
        Wait-ForService -Service "backend" -MaxWait 120
        
        # Frontend
        Write-Host ""
        Write-Info "🎨 Étape 4/6 : Démarrage du Frontend..."
        docker-compose -f $COMPOSE_FILE up -d frontend
        Wait-ForService -Service "frontend" -MaxWait 60
        
        # Caddy
        Write-Host ""
        Write-Info "🌐 Étape 5/6 : Démarrage de Caddy..."
        docker-compose -f $COMPOSE_FILE up -d caddy
        Start-Sleep -Seconds 10
        Write-Success "Caddy est lancé"
        
        # Tailscale (optionnel)
        Write-Host ""
        $startTailscale = Read-Host "Démarrer Tailscale ? (y/N)"
        if ($startTailscale -match "^[Yy]$") {
            Write-Info "🔒 Étape 6/6 : Démarrage de Tailscale..."
            docker-compose -f $COMPOSE_FILE up -d tailscale
            Start-Sleep -Seconds 10
            Write-Success "Tailscale est lancé"
        } else {
            Write-Info "Tailscale non démarré (vous pouvez le lancer plus tard)"
        }
        
        Write-Success "Démarrage progressif terminé !"
    }
    
    "3" {
        Write-Info "Démarrage en mode développement..."
        docker-compose -f $COMPOSE_FILE up -d postgres keycloak backend frontend
        Write-Success "Services de développement lancés !"
    }
    
    "4" {
        Write-Info "Redémarrage de tous les services..."
        docker-compose -f $COMPOSE_FILE restart
        Write-Success "Services redémarrés !"
    }
    
    "5" {
        Write-Info "Annulé"
        exit 0
    }
    
    default {
        Write-Error-Custom "Choix invalide"
        exit 1
    }
}

# Afficher l'état des services
Write-Host ""
Write-Info "État des services :"
docker-compose -f $COMPOSE_FILE ps

# Afficher les URLs
Write-Host ""
Write-Host "╔═══════════════════════════════════════════╗"
Write-Host "║     🌐 ACCÈS AUX SERVICES                ║"
Write-Host "╚═══════════════════════════════════════════╝"
Write-Host ""
Write-Host "  Frontend     : http://localhost:3000"
Write-Host "  Backend API  : http://localhost:8084"
Write-Host "  Keycloak     : http://localhost:8080"
Write-Host "  PgAdmin      : http://localhost:5050 (si lancé)"
Write-Host ""
Write-Host "  Swagger API  : http://localhost:8084/swagger-ui.html"
Write-Host "  Health Check : http://localhost:8084/actuator/health"
Write-Host ""

# Credentials
Write-Host "╔═══════════════════════════════════════════╗"
Write-Host "║     🔑 IDENTIFIANTS PAR DÉFAUT           ║"
Write-Host "╚═══════════════════════════════════════════╝"
Write-Host ""
Write-Host "  Keycloak Admin :"
Write-Host "    Username : admin"
Write-Host "    Password : admin"
Write-Host ""
Write-Host "  PgAdmin :"
Write-Host "    Email    : admin@sahabi.local"
Write-Host "    Password : admin"
Write-Host ""
Write-Host "  PostgreSQL :"
Write-Host "    Host     : localhost"
Write-Host "    Port     : 5432"
Write-Host "    Database : sahabi_db"
Write-Host "    Username : sahabi"
Write-Host "    Password : sahabi"
Write-Host ""

# Commandes utiles
Write-Host "╔═══════════════════════════════════════════╗"
Write-Host "║     📋 COMMANDES UTILES                  ║"
Write-Host "╚═══════════════════════════════════════════╝"
Write-Host ""
Write-Host "  Voir les logs        : docker-compose -f $COMPOSE_FILE logs -f"
Write-Host "  Arrêter tout         : docker-compose -f $COMPOSE_FILE down"
Write-Host "  Redémarrer           : docker-compose -f $COMPOSE_FILE restart"
Write-Host "  Voir l'état          : docker-compose -f $COMPOSE_FILE ps"
Write-Host ""

Write-Success "Démarrage terminé ! 🎉"

