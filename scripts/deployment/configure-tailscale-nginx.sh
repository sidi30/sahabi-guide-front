#!/bin/bash
# Script pour configurer Nginx dans Tailscale avec noms DNS
# Usage: ./scripts/deployment/configure-tailscale-nginx.sh

echo "🔧 Configuration de Nginx dans Tailscale..."

# Vérifier que le container Tailscale existe
if ! docker ps -a --filter "name=sahabi-tailscale" --format "{{.Names}}" | grep -q "sahabi-tailscale"; then
    echo "❌ Erreur: Container sahabi-tailscale introuvable !"
    exit 1
fi

# Vérifier que Tailscale est en cours d'exécution
if ! docker ps --filter "name=sahabi-tailscale" --format "{{.Names}}" | grep -q "sahabi-tailscale"; then
    echo "❌ Erreur: Container sahabi-tailscale n'est pas en cours d'exécution !"
    exit 1
fi

# Installer Nginx si nécessaire
echo "📦 Installation de Nginx si nécessaire..."
docker exec sahabi-tailscale sh -c "command -v nginx > /dev/null || (apk add --no-cache nginx && mkdir -p /run/nginx)"

# Configurer Nginx avec noms DNS
echo "⚙️  Configuration de Nginx avec noms DNS..."
docker exec sahabi-tailscale sh -c 'cat > /etc/nginx/nginx.conf << '"'"'EOF'"'"'
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
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Host $host;
        }
        
        # Swagger et Actuator - Utilise le nom DNS
        location ~ ^/(swagger-ui|v3/api-docs|actuator) {
            proxy_pass http://sahabi-backend:8084;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        # Keycloak - Utilise le nom DNS
        location /realms/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Port 443;
        }
        
        location /resources/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host $host;
        }
        
        location /js/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host $host;
        }
        
        # Frontend - Utilise le nom DNS
        location / {
            proxy_pass http://sahabi-frontend:80;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Host $host;
        }
    }
}
EOF
'

# Démarrer Nginx
echo "🚀 Démarrage de Nginx..."
docker exec sahabi-tailscale sh -c "pkill nginx 2>/dev/null; true"
docker exec -d sahabi-tailscale nginx

sleep 2

# Vérifier que Nginx est bien démarré
if docker exec sahabi-tailscale sh -c "ps aux | grep 'nginx: master' | grep -v grep" > /dev/null; then
    echo "✅ Nginx démarré avec succès !"
else
    echo "❌ Erreur: Nginx n'a pas démarré correctement"
    exit 1
fi

# Configurer Tailscale Serve
echo "🌐 Configuration de Tailscale Serve..."
docker exec sahabi-tailscale tailscale serve --https 443 off 2>&1 > /dev/null || true
docker exec sahabi-tailscale tailscale serve --bg http://127.0.0.1:8080

echo ""
echo "✅ Configuration terminée !"
echo "🌍 Accès: https://sahabi-guide.tail2479c5.ts.net"

