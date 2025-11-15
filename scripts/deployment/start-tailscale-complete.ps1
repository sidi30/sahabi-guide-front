#!/usr/bin/env pwsh
#######################################################
# Script de Démarrage Complet Tailscale
#######################################################
# Ce script configure automatiquement Tailscale avec
# socat et Caddy au démarrage
#######################################################

param(
    [switch]$EnableFunnel = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Configuration Tailscale + Caddy (Solution Complete)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Fonction de vérification de conteneur
function Test-Container {
    param([string]$Name)
    $running = docker ps --format "{{.Names}}" | Select-String -Pattern "^$Name$" -Quiet
    return $running
}

# Fonction d'attente de service
function Wait-Service {
    param(
        [string]$Container,
        [string]$Command,
        [int]$MaxAttempts = 30
    )
    
    Write-Host "  Attente de $Container..." -NoNewline
    $attempt = 0
    while ($attempt -lt $MaxAttempts) {
        try {
            $result = docker exec $Container sh -c $Command 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host " OK" -ForegroundColor Green
                return $true
            }
        } catch {}
        $attempt++
        Start-Sleep -Seconds 2
    }
    Write-Host " TIMEOUT" -ForegroundColor Red
    return $false
}

# Étape 1 : Vérifier les conteneurs
Write-Host "Etape 1/6 : Verification des conteneurs..." -ForegroundColor Yellow
$requiredContainers = @("sahabi-tailscale", "sahabi-caddy", "sahabi-backend", "sahabi-frontend")

foreach ($container in $requiredContainers) {
    if (Test-Container -Name $container) {
        Write-Host "  OK $container" -ForegroundColor Green
    } else {
        Write-Host "  ERREUR : $container n'est pas actif !" -ForegroundColor Red
        Write-Host ""
        Write-Host "Lancez : docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
}

# Étape 2 : Attendre que les services soient prêts
Write-Host ""
Write-Host "Etape 2/6 : Attente des services..." -ForegroundColor Yellow

if (-not (Wait-Service -Container "sahabi-caddy" -Command "wget -qO- http://frontend:80")) {
    Write-Host "  ERREUR : Caddy ne peut pas atteindre le frontend" -ForegroundColor Red
    exit 1
}

# Étape 3 : Installer socat dans Tailscale
Write-Host ""
Write-Host "Etape 3/6 : Installation de socat..." -ForegroundColor Yellow
$socatCheck = docker exec sahabi-tailscale sh -c "command -v socat" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Installation de socat..." -NoNewline
    docker exec sahabi-tailscale apk add --no-cache socat 2>&1 | Out-Null
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host "  socat deja installe" -ForegroundColor Green
}

# Étape 4 : Configurer le proxy socat
Write-Host ""
Write-Host "Etape 4/6 : Configuration du proxy socat..." -ForegroundColor Yellow

# Tuer les anciennes instances
Write-Host "  Nettoyage des anciennes instances..." -NoNewline
docker exec sahabi-tailscale pkill socat 2>&1 | Out-Null
Start-Sleep -Seconds 1
Write-Host " OK" -ForegroundColor Green

# Démarrer socat
Write-Host "  Demarrage du proxy (localhost:8080 -> caddy:80)..." -NoNewline
docker exec -d sahabi-tailscale socat TCP-LISTEN:8080,fork,reuseaddr TCP:caddy:80 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Vérifier que socat écoute
$listening = docker exec sahabi-tailscale netstat -tlnp 2>&1 | Select-String "8080"
if ($listening) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " ERREUR" -ForegroundColor Red
    exit 1
}

# Tester le proxy
Write-Host "  Test du proxy..." -NoNewline
$testResult = docker exec sahabi-tailscale curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>&1
if ($testResult -eq "200") {
    Write-Host " OK (HTTP 200)" -ForegroundColor Green
} else {
    Write-Host " WARNING (HTTP $testResult)" -ForegroundColor Yellow
}

# Étape 5 : Configurer Tailscale Serve
Write-Host ""
Write-Host "Etape 5/6 : Configuration de Tailscale Serve..." -ForegroundColor Yellow

Write-Host "  Desactivation de l'ancienne configuration..." -NoNewline
docker exec sahabi-tailscale tailscale serve off 2>&1 | Out-Null
Start-Sleep -Seconds 1
Write-Host " OK" -ForegroundColor Green

Write-Host "  Configuration de Tailscale Serve..." -NoNewline
$serveOutput = docker exec sahabi-tailscale tailscale serve --bg http://localhost:8080 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host $serveOutput
    exit 1
}

# Étape 6 : Funnel (optionnel)
if ($EnableFunnel) {
    Write-Host ""
    Write-Host "Etape 6/6 : Activation de Tailscale Funnel..." -ForegroundColor Yellow
    Write-Host "  Activation de l'acces public..." -NoNewline
    $funnelOutput = docker exec sahabi-tailscale tailscale funnel --bg 443 on 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " ERREUR" -ForegroundColor Yellow
        Write-Host "  $funnelOutput" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "Etape 6/6 : Funnel non active (acces Tailnet uniquement)" -ForegroundColor Gray
}

# Afficher le statut final
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
$status = docker exec sahabi-tailscale tailscale serve status 2>&1 | Out-String
Write-Host $status -ForegroundColor White
Write-Host "========================================================" -ForegroundColor Cyan

# Extraire l'URL
if ($status -match "https://([a-z0-9\-\.]+\.ts\.net)") {
    $tailscaleUrl = "https://$($matches[1])"
    
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "            CONFIGURATION REUSSIE !" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Votre application Sahabi Guide est accessible :" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   URL : $tailscaleUrl" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ""
    
    if ($EnableFunnel -and $status -match "Funnel on") {
        Write-Host "   Acces : PUBLIC (Funnel active)" -ForegroundColor Green
    } else {
        Write-Host "   Acces : TAILNET UNIQUEMENT (Funnel desactive)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Routes disponibles :" -ForegroundColor Yellow
    Write-Host "   Frontend  : $tailscaleUrl/" -ForegroundColor White
    Write-Host "   API       : $tailscaleUrl/api/v1/" -ForegroundColor White
    Write-Host "   Keycloak  : $tailscaleUrl/auth/" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Architecture :" -ForegroundColor Yellow
    Write-Host "   Internet -> Tailscale -> socat (localhost:8080) -> Caddy -> Services" -ForegroundColor Gray
    
} else {
    Write-Host ""
    Write-Host "Configuration appliquee mais URL non detectee" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour activer Funnel (acces public) :" -ForegroundColor Cyan
Write-Host "   .\scripts\deployment\start-tailscale-complete.ps1 -EnableFunnel" -ForegroundColor White
Write-Host ""
Write-Host "Pour verifier le statut :" -ForegroundColor Cyan
Write-Host "   docker exec sahabi-tailscale tailscale serve status" -ForegroundColor White
Write-Host ""




