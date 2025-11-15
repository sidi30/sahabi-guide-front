# Script pour configurer Nginx dans Tailscale avec noms DNS
# Usage: .\scripts\deployment\configure-tailscale-nginx.ps1

Write-Host "Configuration de Nginx dans Tailscale..." -ForegroundColor Cyan

# Vérifier que le container Tailscale existe
$tailscaleExists = docker ps -a --filter "name=sahabi-tailscale" --format "{{.Names}}"
if (-not $tailscaleExists) {
    Write-Host "Erreur: Container sahabi-tailscale introuvable !" -ForegroundColor Red
    exit 1
}

# Vérifier que Tailscale est en cours d'exécution
$tailscaleRunning = docker ps --filter "name=sahabi-tailscale" --format "{{.Names}}"
if (-not $tailscaleRunning) {
    Write-Host "Erreur: Container sahabi-tailscale n'est pas en cours d'execution !" -ForegroundColor Red
    exit 1
}

# Installer Nginx si nécessaire
Write-Host "Installation de Nginx si necessaire..." -ForegroundColor Yellow
docker exec sahabi-tailscale sh -c "command -v nginx > /dev/null || (apk add --no-cache nginx && mkdir -p /run/nginx)"

# Configurer Nginx avec noms DNS
Write-Host "Configuration de Nginx avec noms DNS..." -ForegroundColor Yellow
docker exec sahabi-tailscale sh -c "cat > /etc/nginx/nginx.conf << 'EOF'
events { worker_connections 1024; }
http {
    # Configuration du resolver DNS Docker
    resolver 127.0.0.11 valid=30s;
    
    server {
        listen 127.0.0.1:8080;
        listen [::1]:8080;
        
        # Backend API - Utilise le nom DNS
        location /api/ {
            proxy_pass http://sahabi-backend:8084;
            proxy_set_header Host \`$host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Host \`$host;
        }
        
        # Swagger et Actuator - Utilise le nom DNS
        location ~ ^/(swagger-ui|v3/api-docs|actuator) {
            proxy_pass http://sahabi-backend:8084;
            proxy_set_header Host \`$host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        # Keycloak - Utilise le nom DNS
        location /realms/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host \`$host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Port 443;
        }
        
        location /resources/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host \`$host;
        }
        
        location /js/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host \`$host;
        }
        
        # Frontend - Utilise le nom DNS
        location / {
            proxy_pass http://sahabi-frontend:80;
            proxy_set_header Host \`$host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Host \`$host;
        }
    }
}
EOF
"

# Démarrer Nginx
Write-Host "Demarrage de Nginx..." -ForegroundColor Yellow
docker exec sahabi-tailscale sh -c "pkill nginx 2>/dev/null; true"
docker exec -d sahabi-tailscale nginx

Start-Sleep -Seconds 2

# Vérifier que Nginx est bien démarré
$nginxRunning = docker exec sahabi-tailscale sh -c "ps aux | grep 'nginx: master' | grep -v grep"
if ($nginxRunning) {
    Write-Host "Nginx demarre avec succes !" -ForegroundColor Green
} else {
    Write-Host "Erreur: Nginx n'a pas demarre correctement" -ForegroundColor Red
    exit 1
}

# Configurer Tailscale Serve
Write-Host "Configuration de Tailscale Serve..." -ForegroundColor Yellow
docker exec sahabi-tailscale tailscale serve --https 443 off 2>&1 | Out-Null
docker exec sahabi-tailscale tailscale serve --bg http://127.0.0.1:8080

Write-Host ""
Write-Host "Configuration terminee !" -ForegroundColor Green
Write-Host "Acces: https://sahabi-guide.tail2479c5.ts.net" -ForegroundColor Cyan

