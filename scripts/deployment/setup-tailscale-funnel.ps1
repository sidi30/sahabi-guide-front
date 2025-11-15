# Configuration Tailscale Funnel pour acces public

Write-Host "Configuration de Tailscale Funnel..." -ForegroundColor Cyan
Write-Host ""

# 1. Activer HTTPS sur le tailnet
Write-Host "Etape 1: Activer HTTPS sur votre tailnet" -ForegroundColor Yellow
Write-Host "Allez sur : https://login.tailscale.com/admin/settings/dns" -ForegroundColor White
Write-Host "Dans la section 'HTTPS Certificates', activez 'Enable HTTPS'"
Write-Host ""
Read-Host "Appuyez sur Entree quand c'est fait"

Write-Host ""
Write-Host "Etape 2: Configuration de Tailscale Serve (nouvelle syntaxe)..." -ForegroundColor Yellow
docker exec sahabi-tailscale tailscale serve --bg http://frontend:80

Write-Host ""
Write-Host "Etape 3: Activation de Funnel (acces public)..." -ForegroundColor Yellow
docker exec sahabi-tailscale tailscale funnel --bg 443 on

Write-Host ""
Write-Host "Verification de la configuration..." -ForegroundColor Yellow
docker exec sahabi-tailscale tailscale serve status

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "SUCCES ! Votre application est maintenant accessible publiquement !" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# Obtenir le nom de domaine Tailscale
$tailnetDomain = docker exec sahabi-tailscale tailscale status --json | ConvertFrom-Json | Select-Object -ExpandProperty MagicDNSSuffix

if ($tailnetDomain) {
    Write-Host "URL publique : https://sahabi-guide.$tailnetDomain" -ForegroundColor Cyan
} else {
    Write-Host "URL publique : https://sahabi-guide.VOTRE-TAILNET.ts.net" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Cette URL est accessible depuis n'importe quel navigateur dans le monde !" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pour desactiver l'acces public :" -ForegroundColor White
Write-Host "  docker exec sahabi-tailscale tailscale funnel 443 off" -ForegroundColor Cyan
Write-Host ""

