# 🌐 Configuration Tailscale pour Sahabi Guide

## 📋 Vue d'ensemble

Ce document explique la configuration Tailscale mise en place pour permettre l'accès Internet sécurisé à l'application Sahabi Guide.

## 🏗️ Architecture

```
Internet (Tailscale)
        ↓
https://sahabi-guide.tail2479c5.ts.net
        ↓
    Tailscale Container
        ↓
    Nginx (proxy local sur 127.0.0.1:8080)
        ↓
    ┌─────────────┬──────────────┬────────────────┐
    │             │              │                │
Frontend        Backend      Keycloak         Caddy
(sahabi-        (sahabi-     (sahabi-
frontend:80)    backend:8084) keycloak:8080)
```

## 🔑 Caractéristiques clés

### ✅ Utilisation de noms DNS au lieu d'IPs

**Avant (problématique) :**
```nginx
proxy_pass http://172.28.0.6:80;  # IP fixe qui change au redémarrage
```

**Après (robuste) :**
```nginx
proxy_pass http://sahabi-frontend:80;  # Nom DNS toujours valide
```

### ✅ Avantages

1. **Pas de reconfiguration nécessaire** après redémarrage des containers
2. **Résolution DNS automatique** par Docker
3. **Configuration persistante** même après rebuild
4. **Maintenance simplifiée**

## 🚀 Démarrage rapide

### 1. Lancer tous les services

```powershell
# Windows
docker compose --profile production --profile tools up -d
```

```bash
# Linux/Mac
docker-compose --profile production --profile tools up -d
```

### 2. Configurer Nginx dans Tailscale

```powershell
# Windows
.\scripts\deployment\configure-tailscale-nginx.ps1
```

```bash
# Linux/Mac
./scripts/deployment/configure-tailscale-nginx.sh
```

### 3. Vérifier l'accès

- **Local** : http://localhost:3000
- **Internet** : https://sahabi-guide.tail2479c5.ts.net

## 🔧 Configuration manuelle (si nécessaire)

Si les scripts automatiques ne fonctionnent pas, voici la configuration manuelle :

### Étape 1 : Installer Nginx dans Tailscale

```bash
docker exec sahabi-tailscale sh -c "apk add --no-cache nginx && mkdir -p /run/nginx"
```

### Étape 2 : Configurer Nginx

```bash
docker exec sahabi-tailscale sh -c "cat > /etc/nginx/nginx.conf << 'EOF'
events { worker_connections 1024; }
http {
    resolver 127.0.0.11 valid=30s;
    
    server {
        listen 127.0.0.1:8080;
        listen [::1]:8080;
        
        location /api/ {
            proxy_pass http://sahabi-backend:8084;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        location /realms/ {
            proxy_pass http://sahabi-keycloak:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        location / {
            proxy_pass http://sahabi-frontend:80;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
    }
}
EOF
"
```

### Étape 3 : Démarrer Nginx

```bash
docker exec -d sahabi-tailscale nginx
```

### Étape 4 : Configurer Tailscale Serve

```bash
docker exec sahabi-tailscale tailscale serve --bg http://127.0.0.1:8080
```

## 🧪 Tests

### Test du frontend

```bash
curl https://sahabi-guide.tail2479c5.ts.net/
```

### Test de l'API (nécessite authentification)

```bash
curl https://sahabi-guide.tail2479c5.ts.net/api/v1/health
```

### Test Keycloak

```bash
curl https://sahabi-guide.tail2479c5.ts.net/realms/sahabi
```

## 🐛 Dépannage

### Erreur 502 Bad Gateway

**Cause possible** : Nginx ne peut pas résoudre les noms DNS

**Solution** :
```bash
# Vérifier que le resolver DNS est configuré
docker exec sahabi-tailscale cat /etc/nginx/nginx.conf | grep resolver

# Reconfigurer si nécessaire
.\scripts\deployment\configure-tailscale-nginx.ps1
```

### Services non accessibles

**Vérifier que tous les services sont actifs** :
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

**Vérifier les logs Nginx** :
```bash
docker exec sahabi-tailscale nginx -t  # Test configuration
docker logs sahabi-tailscale           # Logs Tailscale
```

### Redémarrage après problème

```bash
# 1. Arrêter tous les services
docker compose down

# 2. Relancer avec les profils
docker compose --profile production --profile tools up -d

# 3. Reconfigurer Nginx
.\scripts\deployment\configure-tailscale-nginx.ps1
```

## 📝 Notes importantes

1. **Resolver DNS** : `127.0.0.11` est le DNS interne de Docker
2. **Noms de services** : Doivent correspondre aux noms dans `docker-compose.yml`
3. **Profiles Docker** : 
   - `production` : Active Caddy et Tailscale
   - `tools` : Active PgAdmin

## 🔒 Sécurité

- Tailscale fournit l'authentification et le chiffrement
- Pas besoin de SSL supplémentaire (géré par Tailscale)
- L'accès est limité aux membres du réseau Tailscale

## 📚 Ressources

- [Documentation Tailscale Serve](https://tailscale.com/kb/1242/tailscale-serve)
- [Documentation Nginx](https://nginx.org/en/docs/)
- [Docker Networking](https://docs.docker.com/network/)

## 🆘 Support

En cas de problème, vérifier :
1. Les logs Docker : `docker logs <container-name>`
2. L'état des services : `docker ps`
3. La configuration Nginx : `docker exec sahabi-tailscale cat /etc/nginx/nginx.conf`

