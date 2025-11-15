# SCRIPT DE CORRECTION TAILSCALE
# Ce script corrige le probleme du tag non autorise

Write-Host "Correction de la configuration Tailscale..." -ForegroundColor Cyan
Write-Host ""

# 1. Verifier que le fichier .env existe
if (-not (Test-Path ".env")) {
    Write-Host "ERREUR: Fichier .env non trouve" -ForegroundColor Red
    Write-Host "Copiez d'abord env.template vers .env" -ForegroundColor Yellow
    exit 1
}

# 2. Corriger le fichier .env
Write-Host "Correction du fichier .env..." -ForegroundColor Yellow
$envContent = Get-Content ".env" -Raw

# Remplacer la ligne TAILSCALE_EXTRA_ARGS
if ($envContent -match "TAILSCALE_EXTRA_ARGS=--advertise-tags=tag:sahabi") {
    Write-Host "Tag trouve, suppression..." -ForegroundColor Green
    $envContent = $envContent -replace "TAILSCALE_EXTRA_ARGS=--advertise-tags=tag:sahabi", "TAILSCALE_EXTRA_ARGS="
    Set-Content ".env" $envContent -NoNewline
    Write-Host "Fichier .env corrige" -ForegroundColor Green
} elseif ($envContent -match "TAILSCALE_EXTRA_ARGS=") {
    Write-Host "La ligne TAILSCALE_EXTRA_ARGS existe deja sans tag" -ForegroundColor Blue
} else {
    Write-Host "Ligne TAILSCALE_EXTRA_ARGS non trouvee, ajout..." -ForegroundColor Yellow
    $envContent += "`nTAILSCALE_EXTRA_ARGS="
    Set-Content ".env" $envContent -NoNewline
}

Write-Host ""

# 3. Arreter Tailscale
Write-Host "Arret de Tailscale..." -ForegroundColor Yellow
docker-compose stop tailscale 2>$null

# 4. Supprimer le conteneur
Write-Host "Suppression du conteneur Tailscale..." -ForegroundColor Yellow
docker-compose rm -f tailscale 2>$null

# 5. Supprimer le volume pour repartir a zero
Write-Host "Suppression du volume Tailscale (reinitialisation)..." -ForegroundColor Yellow
docker volume rm sahabiguide_tailscale_data 2>$null

Write-Host ""
Write-Host "Nettoyage termine !" -ForegroundColor Green
Write-Host ""

# 6. Redemarrer Tailscale
Write-Host "Redemarrage de Tailscale..." -ForegroundColor Cyan
docker-compose --profile production up -d tailscale

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Tailscale redemarre avec succes !" -ForegroundColor Green
    Write-Host ""
    Write-Host "Attente de 15 secondes pour que Tailscale demarre..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    Write-Host ""
    Write-Host "Logs de Tailscale :" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    docker-compose logs --tail=30 tailscale
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Verifier l'etat
    $status = docker-compose ps tailscale | Select-String "Up"
    if ($status) {
        Write-Host "Tailscale fonctionne correctement !" -ForegroundColor Green
        Write-Host ""
        Write-Host "Prochaines etapes :" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Verifier le statut Tailscale :" -ForegroundColor White
        Write-Host "   docker exec sahabi-tailscale tailscale status" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "2. Configurer Tailscale Serve :" -ForegroundColor White
        Write-Host "   docker exec -it sahabi-tailscale sh" -ForegroundColor Cyan
        Write-Host "   tailscale serve https / http://frontend:80" -ForegroundColor Cyan
        Write-Host "   exit" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "3. (Optionnel) Activer Funnel pour acces public :" -ForegroundColor White
        Write-Host "   docker exec -it sahabi-tailscale sh" -ForegroundColor Cyan
        Write-Host "   tailscale funnel 443 on" -ForegroundColor Cyan
        Write-Host "   exit" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "Tailscale est toujours en cours de demarrage..." -ForegroundColor Yellow
        Write-Host "Verifiez les logs avec : docker-compose logs -f tailscale" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "ERREUR lors du demarrage de Tailscale" -ForegroundColor Red
    Write-Host "Consultez les logs avec : docker-compose logs tailscale" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Script termine !" -ForegroundColor Green
Write-Host ""
