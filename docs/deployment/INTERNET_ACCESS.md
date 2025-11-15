# 🌐 Guide d'Accès Internet - Sahabi Guide

Ce guide vous explique **comment rendre votre application accessible depuis Internet** via Docker Compose.

Vous avez **3 options** selon vos besoins :
1. ⚡ **Tailscale** (le plus simple - recommandé pour commencer)
2. 🚀 **Caddy avec nom de domaine** (professionnel)
3. 🔓 **Exposition directe** (simple mais moins sécurisé)

---

## 📋 Table des matières

1. [Option 1 : Tailscale (Recommandé)](#option-1--tailscale-recommandé)
2. [Option 2 : Caddy avec nom de domaine](#option-2--caddy-avec-nom-de-domaine)
3. [Option 3 : Exposition directe des ports](#option-3--exposition-directe-des-ports)
4. [Comparaison des options](#-comparaison-des-options)
5. [Sécurisation supplémentaire](#-sécurisation-supplémentaire)

---

## Option 1 : ⚡ Tailscale (Recommandé)

### 🎯 Pourquoi Tailscale ?

✅ **Le plus simple** - Aucune configuration réseau complexe  
✅ **Sécurisé par défaut** - Chiffrement WireGuard  
✅ **Pas de domaine nécessaire** - Fonctionne immédiatement  
✅ **Gratuit** - Jusqu'à 100 appareils  
✅ **Déjà configuré** dans votre `docker-compose.yml` !

### 📝 Étapes d'installation

#### 1️⃣ Créer un compte Tailscale

Allez sur [https://login.tailscale.com/start](https://login.tailscale.com/start) et créez un compte (gratuit).

#### 2️⃣ Générer une clé d'authentification

1. Connectez-vous à [https://login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys)
2. Cliquez sur **"Generate auth key"**
3. Configurez :
   - ✅ **Reusable** (réutilisable)
   - ✅ **Ephemeral** (optionnel - se supprime quand déconnecté)
   - Tag : `tag:sahabi` (optionnel)
4. Copiez la clé (commence par `tskey-auth-...`)

#### 3️⃣ Configurer votre fichier `.env`

Si vous n'avez pas encore de fichier `.env`, créez-en un :

```powershell
# Copier le template
Copy-Item env.template .env
```

Ensuite, modifiez `.env` et mettez à jour la clé Tailscale :

```env
#############################
# 🔒 TAILSCALE
#############################
TAILSCALE_AUTHKEY=tskey-auth-VOTRE_CLE_ICI
TAILSCALE_HOSTNAME=sahabi-guide
TAILSCALE_EXTRA_ARGS=--advertise-tags=tag:sahabi
```

#### 4️⃣ Démarrer avec Tailscale

```powershell
# Démarrer TOUS les services avec le profil production
docker-compose --profile production up -d

# Ou uniquement Tailscale si les autres services tournent déjà
docker-compose --profile production up -d tailscale
```

#### 5️⃣ Vérifier la connexion

```powershell
# Voir les logs Tailscale
docker-compose logs -f tailscale
```

Vous devriez voir quelque chose comme :
```
✅ Logged in as: votre-email@example.com
✅ Machine name: sahabi-guide
✅ Tailscale IP: 100.x.x.x
```

#### 6️⃣ Configurer Tailscale Serve (exposition des services)

Tailscale Serve permet d'exposer vos services via HTTPS avec certificat automatique.

**Méthode 1 : Via la configuration actuelle (recommandé)**

Votre `tailscale-serve.json` est déjà configuré pour exposer Caddy sur le port 443.

Activez Tailscale Serve :

```powershell
# Entrer dans le conteneur
docker exec -it sahabi-tailscale sh

# Activer Tailscale Serve
tailscale serve https / http://caddy:443
tailscale serve status
exit
```

**Méthode 2 : Exposition directe du frontend**

Si vous n'utilisez pas Caddy, vous pouvez exposer directement le frontend :

```powershell
docker exec -it sahabi-tailscale sh
tailscale serve https / http://frontend:80
exit
```

#### 7️⃣ Accéder à votre application

Une fois Tailscale configuré, vous pouvez accéder à votre application :

1. **Depuis n'importe quel appareil avec Tailscale installé** :
   - Installez Tailscale sur votre téléphone/ordinateur
   - Connectez-vous avec le même compte
   - Accédez à : `https://sahabi-guide.VOTRE-TAILNET.ts.net`

2. **Avec Tailscale Funnel (accès public)** :
   ```powershell
   # Activer Funnel pour rendre public (pas besoin de Tailscale installé)
   docker exec -it sahabi-tailscale sh
   tailscale funnel 443 on
   exit
   ```
   
   Votre application sera accessible publiquement via : `https://sahabi-guide.VOTRE-TAILNET.ts.net`

### 🔍 Commandes utiles Tailscale

```powershell
# Voir le statut
docker exec sahabi-tailscale tailscale status

# Voir l'IP Tailscale
docker exec sahabi-tailscale tailscale ip

# Voir la configuration Serve
docker exec sahabi-tailscale tailscale serve status

# Désactiver Funnel
docker exec sahabi-tailscale tailscale funnel 443 off

# Redémarrer Tailscale
docker-compose restart tailscale
```

### ⚠️ Limitations Tailscale

- **Gratuit** : 100 appareils max, 1 utilisateur
- **Payant** (50$/mois) : Utilisateurs illimités, ACLs avancés

---

## Option 2 : 🚀 Caddy avec nom de domaine

### 🎯 Pourquoi Caddy + Domaine ?

✅ **Professionnel** - Votre propre domaine (ex: `sahabi-guide.com`)  
✅ **SSL automatique** - Certificats Let's Encrypt gratuits  
✅ **Performant** - Reverse proxy moderne avec HTTP/3  
✅ **Déjà configuré** dans votre `docker-compose.yml` !

### 📝 Prérequis

1. **Un nom de domaine** (ex: `sahabi-guide.com`)
   - Acheter sur [Namecheap](https://www.namecheap.com), [OVH](https://www.ovh.com), [Cloudflare](https://www.cloudflare.com), etc.
   - Prix : ~10-15€/an

2. **Un serveur avec IP publique**
   - VPS (ex: [DigitalOcean](https://www.digitalocean.com), [Hetzner](https://www.hetzner.com), [OVH](https://www.ovh.com))
   - Prix : ~5-10€/mois pour un VPS basique

### 📝 Étapes d'installation

#### 1️⃣ Configurer les DNS

Dans votre registrar de domaine (Namecheap, OVH, etc.), ajoutez ces enregistrements DNS :

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | `VOTRE_IP_SERVEUR` | 3600 |
| A | api | `VOTRE_IP_SERVEUR` | 3600 |
| A | auth | `VOTRE_IP_SERVEUR` | 3600 |
| A | db | `VOTRE_IP_SERVEUR` | 3600 |

**Exemple avec le domaine `sahabi-guide.com` et IP `203.0.113.45` :**
```
A    @     203.0.113.45    3600  → https://sahabi-guide.com
A    api   203.0.113.45    3600  → https://api.sahabi-guide.com
A    auth  203.0.113.45    3600  → https://auth.sahabi-guide.com
A    db    203.0.113.45    3600  → https://db.sahabi-guide.com
```

⏰ **Attendez 10-30 minutes** que les DNS se propagent.

#### 2️⃣ Configurer le pare-feu

Sur votre serveur, ouvrez les ports nécessaires :

**Sous Linux (Ubuntu/Debian) :**
```bash
# Installer UFW si nécessaire
sudo apt update && sudo apt install ufw -y

# Autoriser les ports
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 443/udp     # HTTP/3

# Activer le pare-feu
sudo ufw enable
sudo ufw status
```

**Sous Windows Server :**
```powershell
# Autoriser HTTP/HTTPS
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTP/3" -Direction Inbound -Protocol UDP -LocalPort 443 -Action Allow
```

**Sur votre box Internet (si serveur local) :**
- Redirigez les ports 80 et 443 vers l'IP locale de votre serveur
- Consultez le manuel de votre box

#### 3️⃣ Configurer votre fichier `.env`

Modifiez `.env` avec votre domaine :

```env
#############################
# 🌐 CADDY (Reverse Proxy + SSL)
#############################
DOMAIN=sahabi-guide.com
ACME_EMAIL=votre-email@example.com

#############################
# 🔐 KEYCLOAK
#############################
KEYCLOAK_HOSTNAME=auth.sahabi-guide.com

#############################
# 🔧 BACKEND (Spring Boot)
#############################
CORS_ALLOWED_ORIGINS=https://sahabi-guide.com,https://api.sahabi-guide.com,https://auth.sahabi-guide.com

#############################
# 🎨 FRONTEND (React Dashboard)
#############################
VITE_API_BASE_URL=https://api.sahabi-guide.com
VITE_KEYCLOAK_URL=https://auth.sahabi-guide.com
```

#### 4️⃣ Mettre à jour Keycloak Realm

Modifiez `sahabi-guide-api/keycloak/import/sahabi-realm.json` pour ajouter les bonnes URLs de redirection.

Cherchez le client `sahabi-dashboard` et mettez à jour :

```json
{
  "clientId": "sahabi-dashboard",
  "redirectUris": [
    "http://localhost:3000/*",
    "https://sahabi-guide.com/*",
    "https://www.sahabi-guide.com/*"
  ],
  "webOrigins": [
    "http://localhost:3000",
    "https://sahabi-guide.com",
    "https://www.sahabi-guide.com"
  ]
}
```

#### 5️⃣ Rebuild le Frontend avec les nouvelles variables

Le frontend doit être reconstruit avec les nouvelles URLs :

```powershell
# Arrêter les services
docker-compose down

# Supprimer l'image frontend pour forcer un rebuild
docker rmi sahabi-guide-dashboard-frontend

# Rebuild et redémarrer avec Caddy
docker-compose --profile production up -d --build
```

#### 6️⃣ Vérifier les certificats SSL

```powershell
# Voir les logs Caddy
docker-compose logs -f caddy
```

Vous devriez voir :
```
✅ certificate obtained successfully
✅ serving HTTPS on https://sahabi-guide.com
```

#### 7️⃣ Accéder à votre application

Votre application est maintenant accessible :

- 🎨 **Frontend** : https://sahabi-guide.com
- 🔧 **API** : https://api.sahabi-guide.com
- 🔐 **Keycloak** : https://auth.sahabi-guide.com
- 📊 **PgAdmin** : https://db.sahabi-guide.com

### 🔍 Commandes utiles Caddy

```powershell
# Voir les certificats
docker exec sahabi-caddy caddy list-certificates

# Forcer le renouvellement
docker exec sahabi-caddy caddy reload --config /etc/caddy/Caddyfile

# Voir les logs
docker-compose logs -f caddy

# Tester la configuration
docker exec sahabi-caddy caddy validate --config /etc/caddy/Caddyfile
```

### ⚠️ Dépannage Caddy

**Erreur : "failed to obtain certificate"**
```powershell
# Vérifier que les DNS pointent bien vers votre serveur
nslookup sahabi-guide.com

# Vérifier que les ports sont ouverts
Test-NetConnection -ComputerName sahabi-guide.com -Port 80
Test-NetConnection -ComputerName sahabi-guide.com -Port 443

# Redémarrer Caddy
docker-compose restart caddy
```

**Erreur : "too many certificates already issued"**
- Let's Encrypt limite à 5 certificats/semaine pour le même domaine
- Utilisez le serveur staging pour tester (décommentez dans `Caddyfile`)

---

## Option 3 : 🔓 Exposition directe des ports

### 🎯 Pourquoi l'exposition directe ?

✅ **Le plus simple** - Pas de reverse proxy  
✅ **Gratuit** - Aucun service externe  
⚠️ **Moins sécurisé** - Pas de SSL automatique  
⚠️ **Pas professionnel** - Ports non standard (ex: `:3000`)

### 📝 Étapes

#### 1️⃣ Vérifier les ports exposés

Votre `docker-compose.yml` expose déjà ces ports :

```yaml
ports:
  - "5432:5432"   # PostgreSQL
  - "8080:8080"   # Keycloak (localhost uniquement actuellement)
  - "8084:8084"   # Backend
  - "3000:80"     # Frontend
  - "5050:80"     # PgAdmin
```

#### 2️⃣ Exposer Keycloak publiquement

Modifiez `docker-compose.yml` :

```yaml
keycloak:
  # ...
  ports:
    - "${KEYCLOAK_PORT:-8080}:8080"  # Au lieu de 127.0.0.1:8080:8080
```

#### 3️⃣ Configurer le pare-feu

**Sous Linux :**
```bash
sudo ufw allow 3000/tcp    # Frontend
sudo ufw allow 8080/tcp    # Keycloak
sudo ufw allow 8084/tcp    # Backend
```

**Sous Windows :**
```powershell
New-NetFirewallRule -DisplayName "Frontend" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
New-NetFirewallRule -DisplayName "Keycloak" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
New-NetFirewallRule -DisplayName "Backend" -Direction Inbound -Protocol TCP -LocalPort 8084 -Action Allow
```

**Sur votre box Internet (si serveur local) :**
- Redirigez ces ports vers l'IP locale de votre serveur

#### 4️⃣ Redémarrer les services

```powershell
docker-compose down
docker-compose up -d
```

#### 5️⃣ Accéder à votre application

Votre application est accessible (remplacez `VOTRE_IP` par votre IP publique) :

- 🎨 **Frontend** : http://VOTRE_IP:3000
- 🔧 **API** : http://VOTRE_IP:8084
- 🔐 **Keycloak** : http://VOTRE_IP:8080

### ⚠️ Avertissement

Cette méthode **n'est PAS recommandée en production** car :
- ❌ Pas de SSL (données non chiffrées)
- ❌ Ports non standard (pas professionnel)
- ❌ Exposition directe des services (moins sécurisé)

**Utilisez cette méthode uniquement pour des tests !**

---

## 📊 Comparaison des options

| Critère | Tailscale ⚡ | Caddy + Domaine 🚀 | Exposition directe 🔓 |
|---------|-------------|-------------------|---------------------|
| **Difficulté** | 🟢 Facile | 🟡 Moyenne | 🟢 Facile |
| **Coût** | 🟢 Gratuit | 🟡 ~10-20€/mois | 🟢 Gratuit |
| **Sécurité** | 🟢 Excellente | 🟢 Excellente | 🔴 Faible |
| **SSL** | ✅ Automatique | ✅ Automatique | ❌ Non |
| **Domaine personnalisé** | ❌ Non | ✅ Oui | ❌ Non |
| **IP publique requise** | ❌ Non | ✅ Oui | ✅ Oui |
| **Configuration réseau** | ❌ Non | ✅ Oui (DNS, pare-feu) | ✅ Oui (pare-feu) |
| **Idéal pour** | Tests, démo, développement | Production | Tests locaux uniquement |

### 🏆 Recommandations

1. **Pour commencer rapidement** : Utilisez **Tailscale** (Option 1)
2. **Pour la production** : Utilisez **Caddy + Domaine** (Option 2)
3. **Pour des tests locaux** : Utilisez **Exposition directe** (Option 3)

---

## 🔒 Sécurisation supplémentaire

Quelle que soit l'option choisie, voici des mesures de sécurité importantes :

### 1️⃣ Changer les mots de passe par défaut

Modifiez `.env` :

```env
# PostgreSQL
POSTGRES_PASSWORD=UN_MOT_DE_PASSE_TRES_SECURISE_ICI

# Keycloak
KEYCLOAK_ADMIN_PASSWORD=UN_AUTRE_MOT_DE_PASSE_SECURISE

# JWT
JWT_SECRET=UNE_CLE_SECRETE_TRES_LONGUE_ET_ALEATOIRE_AU_MOINS_64_CARACTERES

# PgAdmin
PGADMIN_PASSWORD=ENCORE_UN_MOT_DE_PASSE_SECURISE
```

Puis recréez les conteneurs :

```powershell
docker-compose down -v
docker-compose up -d
```

⚠️ **Attention** : `-v` supprime les volumes (toutes les données). Faites une sauvegarde avant !

### 2️⃣ Limiter l'accès à PgAdmin et PostgreSQL

Dans `docker-compose.yml`, ne pas exposer publiquement :

```yaml
postgres:
  ports:
    - "127.0.0.1:5432:5432"  # Accessible uniquement depuis localhost

pgadmin:
  ports:
    - "127.0.0.1:5050:80"    # Accessible uniquement depuis localhost
```

### 3️⃣ Activer le rate limiting

Dans `.env`, ajustez les limites :

```env
RATE_LIMIT_MAX_LOGIN=5
RATE_LIMIT_MAX_OTP_REQUESTS=3
RATE_LIMIT_MAX_OTP_VERIFICATIONS=5
```

### 4️⃣ Activer HTTPS strict

Si vous utilisez Caddy, HTTPS est automatique. Sinon, forcez HTTPS :

```env
# Dans .env
KEYCLOAK_HOSTNAME_STRICT_HTTPS=true
KC_HTTP_ENABLED=false
```

### 5️⃣ Sauvegardes régulières

Créez des sauvegardes automatiques de la base de données :

```bash
# Exemple de script de sauvegarde (Linux)
#!/bin/bash
docker exec sahabi-postgres pg_dump -U sahabi sahabi_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

Vous avez déjà `backup-db.sh` et `restore-db.sh` dans votre projet !

### 6️⃣ Monitoring et logs

Activez les logs pour surveiller les accès :

```powershell
# Voir les logs en temps réel
docker-compose logs -f

# Voir uniquement les erreurs
docker-compose logs --tail=100 | Select-String "ERROR"
```

### 7️⃣ Mettre à jour régulièrement

```powershell
# Mettre à jour les images Docker
docker-compose pull
docker-compose up -d --build
```

---

## 🚀 Démarrage rapide

### Pour Tailscale (recommandé pour commencer)

```powershell
# 1. Créer le fichier .env
Copy-Item env.template .env

# 2. Éditer .env et ajouter votre clé Tailscale
# TAILSCALE_AUTHKEY=tskey-auth-VOTRE_CLE

# 3. Démarrer avec Tailscale
docker-compose --profile production up -d

# 4. Configurer Tailscale Serve
docker exec -it sahabi-tailscale sh
tailscale serve https / http://frontend:80
exit
```

### Pour Caddy + Domaine (production)

```powershell
# 1. Configurer les DNS de votre domaine
# 2. Créer le fichier .env
Copy-Item env.template .env

# 3. Éditer .env avec votre domaine
# DOMAIN=votre-domaine.com
# ACME_EMAIL=votre-email@example.com

# 4. Mettre à jour les URLs dans keycloak/import/sahabi-realm.json

# 5. Démarrer avec Caddy
docker-compose --profile production up -d --build
```

---

## 📞 Support et dépannage

### Vérifier que tout fonctionne

```powershell
# Statut des conteneurs
docker-compose ps

# Logs généraux
docker-compose logs --tail=50

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f caddy
docker-compose logs -f tailscale

# Health checks
docker inspect sahabi-postgres | Select-String "Health"
docker inspect sahabi-backend | Select-String "Health"
```

### Problèmes courants

**1. Les services ne démarrent pas**
```powershell
# Vérifier les logs
docker-compose logs

# Vérifier les ports
netstat -an | Select-String "LISTEN"

# Redémarrer proprement
docker-compose down
docker-compose up -d
```

**2. Erreur de connexion à la base de données**
```powershell
# Vérifier que PostgreSQL est prêt
docker exec -it sahabi-postgres psql -U sahabi -d sahabi_db -c "\l"

# Redémarrer PostgreSQL
docker-compose restart postgres
```

**3. Keycloak ne démarre pas**
```powershell
# Supprimer les volumes et recréer
docker-compose down -v
docker-compose up -d
```

**4. Frontend ne se connecte pas à l'API**
- Vérifiez les CORS dans `.env`
- Vérifiez les URLs dans le frontend
- Rebuild le frontend : `docker-compose up -d --build frontend`

---

## 📚 Ressources utiles

- **Docker Compose** : https://docs.docker.com/compose/
- **Caddy** : https://caddyserver.com/docs/
- **Tailscale** : https://tailscale.com/kb/
- **Keycloak** : https://www.keycloak.org/documentation
- **Let's Encrypt** : https://letsencrypt.org/fr/

---

## ✅ Checklist de déploiement

- [ ] Choisir une option d'accès Internet (Tailscale, Caddy, ou Direct)
- [ ] Créer le fichier `.env` à partir de `env.template`
- [ ] Configurer les variables d'environnement (domaine, clés, mots de passe)
- [ ] Configurer le pare-feu (ports 80, 443 pour Caddy)
- [ ] Configurer les DNS (si Caddy)
- [ ] Mettre à jour les URLs de redirection Keycloak
- [ ] Démarrer les services avec le bon profil
- [ ] Vérifier les logs
- [ ] Tester l'accès depuis Internet
- [ ] Changer les mots de passe par défaut
- [ ] Configurer les sauvegardes

---

**Version du document** : 1.0  
**Dernière mise à jour** : 2025-11-08  
**Auteur** : Assistant IA

**Besoin d'aide ?** Consultez les logs avec `docker-compose logs` et référez-vous à la section dépannage ci-dessus.

