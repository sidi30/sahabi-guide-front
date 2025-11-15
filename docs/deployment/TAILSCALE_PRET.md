# ✅ Tailscale Configuré et Prêt !

Votre application **Sahabi Guide** est maintenant **accessible depuis Internet** via Tailscale !

---

## 🌐 URL d'Accès

```
https://sahabi-guide.tail2479c5.ts.net
```

---

## 📱 Comment y Accéder

### Option 1 : Accès Privé (via Tailscale)

1. **Installez Tailscale** sur votre appareil :
   - 📱 Mobile : Cherchez "Tailscale" dans le Play Store / App Store
   - 💻 Desktop : https://tailscale.com/download

2. **Connectez-vous** avec votre compte : `sirtecnologie@gmail.com`

3. **Accédez à** : `https://sahabi-guide.tail2479c5.ts.net`

4. **Login** :
   - Username : `admin`
   - Password : `admin123`

### Option 2 : Accès Public (Funnel)

Pour rendre votre app accessible **sans installer Tailscale** :

```powershell
docker exec sahabi-tailscale tailscale funnel --bg 443 on
```

L'URL sera accessible publiquement depuis n'importe quel navigateur ! 🌍

---

## 🏗️ Architecture Actuelle

```
Internet (Tailscale)
         ↓
https://sahabi-guide.tail2479c5.ts.net
         ↓
    Tailscale Serve (port 443)
         ↓
    Nginx (proxy local, port 8080)
         ↓
    ┌──────────┬──────────┬──────────┐
    ↓          ↓          ↓          ↓
Frontend   Backend    Keycloak   Caddy
  :80        :8084      :8080      :80
```

**Tous les services sont accessibles via l'URL Tailscale !**

---

## 📋 Vérifications

### Voir le statut Tailscale

```powershell
docker exec sahabi-tailscale tailscale status
```

### Voir la configuration Serve

```powershell
docker exec sahabi-tailscale tailscale serve status
```

### Tester le proxy nginx

```powershell
# Frontend
docker exec sahabi-tailscale wget -qO- http://127.0.0.1:8080/ | Select-String "doctype"

# Keycloak
docker exec sahabi-tailscale wget -qO- http://127.0.0.1:8080/realms/sahabi | Select-String "issuer"

# Backend
docker exec sahabi-tailscale wget -qO- http://127.0.0.1:8080/api/v1/actuator/health
```

---

## 🔧 Commandes Utiles

### Redémarrer tout

```powershell
docker-compose --profile production restart
```

### Voir les logs

```powershell
docker-compose logs -f
docker-compose logs -f tailscale
docker-compose logs -f keycloak
```

### Arrêter

```powershell
docker-compose --profile production down
```

### Redémarrer

```powershell
docker-compose --profile production up -d
```

---

## ⚙️ Configuration Actuelle

### Frontend
- Construit avec `VITE_KEYCLOAK_URL=https://sahabi-guide.tail2479c5.ts.net`
- Construit avec `VITE_API_BASE_URL=https://sahabi-guide.tail2479c5.ts.net`

### Keycloak  
- Client `sahabi-dashboard` configuré avec les URLs Tailscale autorisées
- Accessible via `/realms/`, `/resources/`, `/js/`

### Backend
- Accessible via `/api/`

### Nginx (dans Tailscale)
- Route tout le trafic vers les bons conteneurs
- Écoute sur `127.0.0.1:8080`

---

## 🚀 Si Vous Redémarrez Docker

Le container Tailscale perd nginx à chaque redémarrage. Voici le script pour tout reconfigurer :

```powershell
# Réinstaller nginx
docker exec sahabi-tailscale apk add --no-cache nginx

# Récréer la config nginx
docker exec sahabi-tailscale sh -c 'cat > /etc/nginx/nginx.conf << "EOF"
events {
    worker_connections 1024;
}

http {
    server {
        listen 127.0.0.1:8080;
        listen [::1]:8080;
        
        location /api/ {
            proxy_pass http://172.28.0.5:8084/api/;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        location /realms/ {
            proxy_pass http://172.28.0.4:8080/realms/;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
        
        location /resources/ {
            proxy_pass http://172.28.0.4:8080/resources/;
            proxy_set_header Host \$host;
        }
        
        location /js/ {
            proxy_pass http://172.28.0.4:8080/js/;
            proxy_set_header Host \$host;
        }
        
        location / {
            proxy_pass http://172.28.0.6:80/;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto https;
        }
    }
}
EOF'

# Démarrer nginx
docker exec -d sahabi-tailscale nginx

# Reconfigurer Tailscale Serve
docker exec sahabi-tailscale tailscale serve off
docker exec sahabi-tailscale tailscale serve --bg http://127.0.0.1:8080
```

**Note** : Adaptez les IPs (172.28.0.x) si elles changent.

---

## 🔒 Sécurité

### Changer les mots de passe par défaut

⚠️ **IMPORTANT** : En production, changez ces mots de passe !

Dans `.env` :
```env
POSTGRES_PASSWORD=CHANGEZ_MOI
KEYCLOAK_ADMIN_PASSWORD=CHANGEZ_MOI
JWT_SECRET=UNE_LONGUE_CLE_ALEATOIRE_TRES_SECURISEE
```

Puis recréez :
```powershell
docker-compose --profile production down -v
docker-compose --profile production up -d
```

---

## 📞 Support

Si quelque chose ne fonctionne pas :

1. Vérifiez les logs : `docker-compose logs`
2. Vérifiez Tailscale : `docker exec sahabi-tailscale tailscale status`
3. Vérifiez nginx : `docker exec sahabi-tailscale ps aux | Select-String nginx`

---

## ✅ Checklist

- [x] Tailscale installé et configuré
- [x] Frontend rebuilded avec URLs Tailscale
- [x] Keycloak configuré avec URLs Tailscale autorisées
- [x] Nginx configuré pour router tous les services
- [x] Tailscale Serve configuré
- [x] Application accessible via Internet

---

**🎉 FÉLICITATIONS ! Votre application est maintenant accessible depuis Internet ! 🎉**

**URL** : https://sahabi-guide.tail2479c5.ts.net  
**Login** : admin / admin123

---

**Date de configuration** : 2025-11-08  
**Version** : Finale

