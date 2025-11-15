#!/usr/bin/env pwsh
#######################################################
# Script de Correction Tailscale + Caddy
#######################################################
# Ce script applique la correction du probleme du slash
# final en configurant Tailscale pour utiliser Caddy
#######################################################

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Correction Tailscale - Probleme du Slash" -ForegroundColor Cyan
Write-Host "  Configuration : Tailscale -> Caddy -> Services" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Verifier que les conteneurs sont actifs
Write-Host "Etape 1/5 : Verification des services..." -ForegroundColor Yellow

$requiredContainers = @("sahabi-tailscale", "sahabi-caddy", "sahabi-backend", "sahabi-frontend", "sahabi-keycloak")
$runningContainers = docker ps --format "{{.Names}}" | Out-String

foreach ($container in $requiredContainers) {
    if ($runningContainers -match $container) {
        Write-Host "  OK $container est actif" -ForegroundColor Green
    } else {
        Write-Host "  ERREUR $container n'est pas actif !" -ForegroundColor Red
        Write-Host ""
        Write-Host "Lancez d'abord : docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
}

# Verifier que Caddy peut atteindre les services
Write-Host ""
Write-Host "Etape 2/5 : Test de connectivite Caddy..." -ForegroundColor Yellow

Write-Host "  Test Frontend..." -NoNewline
try {
    $frontendTest = docker exec sahabi-caddy sh -c "wget -qO- http://frontend:80 2>&1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " ERREUR" -ForegroundColor Red
    }
} catch {
    Write-Host " ERREUR" -ForegroundColor Red
}

Write-Host "  Test Backend..." -NoNewline
try {
    $backendTest = docker exec sahabi-caddy sh -c "wget -qO- http://backend:8084/actuator/health 2>&1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " WARNING (peut etre normal si le backend demarre)" -ForegroundColor Yellow
    }
} catch {
    Write-Host " WARNING" -ForegroundColor Yellow
}

Write-Host "  Test Keycloak..." -NoNewline
try {
    $keycloakTest = docker exec sahabi-caddy sh -c "wget -qO- http://keycloak:8080/realms/sahabi 2>&1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " WARNING (peut etre normal si Keycloak demarre)" -ForegroundColor Yellow
    }
} catch {
    Write-Host " WARNING" -ForegroundColor Yellow
}

# Valider la configuration Caddy
Write-Host ""
Write-Host "Etape 3/5 : Validation de la configuration Caddy..." -ForegroundColor Yellow
try {
    docker exec sahabi-caddy caddy validate --config /etc/caddy/Caddyfile 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK Configuration Caddy valide" -ForegroundColor Green
    } else {
        Write-Host "  WARNING Avertissement dans la configuration Caddy" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARNING Impossible de valider (peut etre normal)" -ForegroundColor Yellow
}

# Desactiver l'ancienne configuration Tailscale
Write-Host ""
Write-Host "Etape 4/5 : Configuration de Tailscale Serve..." -ForegroundColor Yellow
Write-Host "  Desactivation de l'ancienne configuration..." -NoNewline
docker exec sahabi-tailscale tailscale serve off 2>&1 | Out-Null
Start-Sleep -Seconds 2
Write-Host " OK" -ForegroundColor Green

# Configurer Tailscale pour utiliser Caddy
Write-Host "  Configuration de la nouvelle route..." -NoNewline
$serveOutput = docker exec sahabi-tailscale tailscale serve --bg http://caddy:80 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host ""
    Write-Host "Erreur lors de la configuration :" -ForegroundColor Red
    Write-Host $serveOutput
    exit 1
}

# Afficher la configuration actuelle
Write-Host ""
Write-Host "Etape 5/5 : Verification de la configuration finale..." -ForegroundColor Yellow
$status = docker exec sahabi-tailscale tailscale serve status 2>&1 | Out-String

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host $status -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan

# Extraire l'URL Tailscale
if ($status -match "https://([a-z0-9\-\.]+\.ts\.net)") {
    $tailscaleUrl = "https://$($matches[1])"
    
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "            CONFIGURATION REUSSIE !" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Votre application est accessible sur :" -ForegroundColor Cyan
    Write-Host "   $tailscaleUrl" -ForegroundColor White
    
    Write-Host ""
    Write-Host "URLs disponibles :" -ForegroundColor Yellow
    Write-Host "   Frontend  : $tailscaleUrl/" -ForegroundColor White
    Write-Host "   API       : $tailscaleUrl/api/v1/" -ForegroundColor White
    Write-Host "   Keycloak  : $tailscaleUrl/auth/" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Tests rapides :" -ForegroundColor Yellow
    Write-Host "   curl $tailscaleUrl/" -ForegroundColor Gray
    Write-Host "   curl $tailscaleUrl/api/v1/auth/health" -ForegroundColor Gray
    Write-Host "   curl $tailscaleUrl/auth/realms/sahabi" -ForegroundColor Gray
    
} else {
    Write-Host ""
    Write-Host "Configuration appliquee mais URL non detectee" -ForegroundColor Yellow
    Write-Host "Verifiez manuellement avec : docker exec sahabi-tailscale tailscale serve status" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pour activer l'acces public (Funnel) :" -ForegroundColor Cyan
Write-Host "   docker exec sahabi-tailscale tailscale funnel --bg 443 on" -ForegroundColor White

Write-Host ""
Write-Host "Documentation complete : docs/deployment/CORRECTION_TAILSCALE_SLASH.md" -ForegroundColor Gray
Write-Host ""
