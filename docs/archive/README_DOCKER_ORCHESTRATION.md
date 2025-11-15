# 🚀 Guide Complet - Orchestration Docker avec SSL et Tailscale

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Démarrage](#démarrage)
- [Accès aux Services](#accès-aux-services)
- [Tailscale - Accès Internet](#tailscale---accès-internet)
- [SSL/HTTPS avec Caddy](#sslhttps-avec-caddy)
- [Dépannage](#dépannage)
- [Production](#production)

---

## 🎯 Vue d'ensemble

Cette stack Docker Compose orchestre tous les services nécessaires pour l'application **Sahabi Guide** :

- ✅ **PostgreSQL** - Base de données
- ✅ **Keycloak** - Authentification OAuth2/OIDC
- ✅ **Backend Spring Boot** - API REST
- ✅ **Frontend React** - Dashboard d'administration
- ✅ **Caddy** - Reverse proxy avec SSL automatique
- ✅ **Tailscale** - VPN pour accès Internet sécurisé
- ✅ **PgAdmin** - Administration de la base de données (optionnel)

---

## 🏗️ Architecture

```
Internet
   ↓
Tailscale (VPN sécurisé)
   ↓
Caddy (Reverse Proxy + SSL)
   ↓
   ├─→ Frontend (React Dashboard) - Port 80
   ├─→ Backend (Spring Boot API) - Port 8084
   └─→ Keycloak (Auth) - Port 8080
        ↓
   PostgreSQL - Port 5432
```

### Domaines (Production)

- **Frontend** : `https://votre-domaine.com`
- **API** : `https://api.votre-domaine.com`
- **Keycloak** : `https://auth.votre-domaine.com`
- **PgAdmin** : `https://db.votre-domaine.com`

### Ports (Développement Local)

- **Frontend** : http://localhost:3000
- **Backend** : http://localhost:8084
- **Keycloak** : http://localhost:8080
- **PostgreSQL** : localhost:5432
- **PgAdmin** : http://localhost:5050

---

## 📦 Prérequis

### 1. Logiciels requis

- **Docker** ≥ 24.0 ([Installer Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** ≥ 2.20
- **Git**
- Au moins **8 GB de RAM** disponible
- **20 GB** d'espace disque

### 2. Compte Tailscale (pour accès Internet)

1. Créez un compte sur [tailscale.com](https://tailscale.com)
2. Installez Tailscale sur votre machine hôte
3. Générez une **Auth Key** :
   - Allez sur https://login.tailscale.com/admin/settings/keys
   - Cliquez sur **Generate auth key**
   - Cochez **Reusable** et **Ephemeral** (optionnel)
   - Copiez la clé générée

### 3. Nom de domaine (pour production)

- Un nom de domaine pointant vers votre serveur
- Accès DNS pour créer des sous-domaines (A records)

---

## 🔧 Installation

### 1. Cloner les projets

Si ce n'est pas déjà fait :

```bash
git clone <url-du-backend> sahabi-guide-api
git clone <url-du-frontend> sahabi-guide-dashboard
```

### 2. Structure des fichiers

Votre dossier doit ressembler à ça :

```
sahabiGuide/
├── sahabi-guide-api/         # Backend Spring Boot
├── sahabi-guide-dashboard/   # Frontend React
├── docker-compose.full.yml   # 🆕 Configuration Docker Compose
├── Caddyfile                 # 🆕 Configuration Caddy
├── tailscale-serve.json      # 🆕 Configuration Tailscale
└── env.template              # 🆕 Template variables d'environnement
```

### 3. Créer le fichier .env

```bash
# Copier le template
cp env.template .env

# Éditer avec vos valeurs
nano .env  # ou code .env, vim .env, etc.
```

**⚠️ IMPORTANT** : Modifiez au minimum ces variables :

```env
# Changez les mots de passe !
POSTGRES_PASSWORD=votre_password_secure
KEYCLOAK_ADMIN_PASSWORD=votre_password_admin
JWT_SECRET=une_cle_tres_longue_et_aleatoire_64_caracteres_minimum

# Ajoutez votre clé Tailscale
TAILSCALE_AUTHKEY=tskey-auth-XXXXXX

# Pour production : votre domaine
DOMAIN=votre-domaine.com
ACME_EMAIL=votre-email@example.com
```

---

## ⚙️ Configuration

### Configuration locale (sans domaine)

Si vous testez en local sans domaine, éditez le `Caddyfile` et décommentez la section **CONFIGURATION LOCALE** à la fin :

```caddyfile
localhost, sahabi.local {
    handle / {
        reverse_proxy frontend:80
    }
    
    handle /api/* {
        reverse_proxy backend:8084
    }
    
    handle /auth/* {
        reverse_proxy keycloak:8080
    }
}
```

### Ajouter sahabi.local à /etc/hosts

Pour tester avec `sahabi.local` :

```bash
# Linux/Mac
sudo nano /etc/hosts

# Windows (en Admin)
notepad C:\Windows\System32\drivers\etc\hosts
```

Ajoutez :

```
127.0.0.1   sahabi.local
127.0.0.1   api.sahabi.local
127.0.0.1   auth.sahabi.local
127.0.0.1   db.sahabi.local
```

### Configuration production (avec domaine)

1. **Configurez vos DNS** :

```
A       @                  → Votre_IP_Serveur
A       api                → Votre_IP_Serveur
A       auth               → Votre_IP_Serveur
A       db                 → Votre_IP_Serveur
```

2. **Modifiez le .env** :

```env
DOMAIN=votre-domaine.com
ACME_EMAIL=admin@votre-domaine.com
```

3. **Caddy générera automatiquement les certificats SSL** via Let's Encrypt !

---

## 🚀 Démarrage

### Méthode 1 : Tout démarrer d'un coup

```bash
docker-compose -f docker-compose.full.yml up -d
```

### Méthode 2 : Démarrage progressif (recommandé pour la première fois)

```bash
# 1. Base de données seule
docker-compose -f docker-compose.full.yml up -d postgres

# Attendre que postgres soit prêt (environ 20 secondes)
docker-compose -f docker-compose.full.yml logs -f postgres

# 2. Keycloak
docker-compose -f docker-compose.full.yml up -d keycloak

# Attendre que Keycloak soit prêt (environ 60 secondes)
docker-compose -f docker-compose.full.yml logs -f keycloak

# 3. Backend
docker-compose -f docker-compose.full.yml up -d backend

# Attendre que le backend soit prêt (environ 90 secondes)
docker-compose -f docker-compose.full.yml logs -f backend

# 4. Frontend
docker-compose -f docker-compose.full.yml up -d frontend

# 5. Caddy (reverse proxy)
docker-compose -f docker-compose.full.yml up -d caddy

# 6. Tailscale (optionnel)
docker-compose -f docker-compose.full.yml up -d tailscale

# 7. PgAdmin (optionnel)
docker-compose -f docker-compose.full.yml --profile tools up -d pgadmin
```

### Vérifier l'état des services

```bash
# Voir tous les conteneurs
docker-compose -f docker-compose.full.yml ps

# Voir les logs
docker-compose -f docker-compose.full.yml logs -f

# Voir les logs d'un service spécifique
docker-compose -f docker-compose.full.yml logs -f backend
```

---

## 🌐 Accès aux Services

### Mode Local (sans SSL)

- **Frontend** : http://localhost:3000 ou http://sahabi.local
- **API** : http://localhost:8084 ou http://api.sahabi.local
- **Keycloak** : http://localhost:8080 ou http://auth.sahabi.local
- **PgAdmin** : http://localhost:5050 ou http://db.sahabi.local

### Mode Production (avec SSL automatique)

- **Frontend** : https://votre-domaine.com
- **API** : https://api.votre-domaine.com
- **Keycloak** : https://auth.votre-domaine.com
- **PgAdmin** : https://db.votre-domaine.com

### Credentials par défaut

**Keycloak Admin** :
- URL : http://localhost:8080 ou https://auth.votre-domaine.com
- Username : `admin` (changez dans .env)
- Password : `admin` (changez dans .env)

**PgAdmin** :
- URL : http://localhost:5050 ou https://db.votre-domaine.com
- Email : `admin@sahabi.local` (changez dans .env)
- Password : `admin` (changez dans .env)

**PostgreSQL** :
- Host : `localhost` (ou `postgres` depuis un conteneur)
- Port : `5432`
- Database : `sahabi_db`
- Username : `sahabi` (changez dans .env)
- Password : `sahabi` (changez dans .env)

---

## 🔒 Tailscale - Accès Internet

Tailscale crée un VPN privé (WireGuard) qui rend votre application accessible depuis n'importe où, sans ouvrir de ports sur votre routeur.

### Configuration

1. **Générez une Auth Key** sur [tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys)

2. **Ajoutez-la au fichier .env** :

```env
TAILSCALE_AUTHKEY=tskey-auth-XXXXXXXXXXXXXXXXX
TAILSCALE_HOSTNAME=sahabi-guide
```

3. **Démarrez Tailscale** :

```bash
docker-compose -f docker-compose.full.yml up -d tailscale
```

4. **Vérifiez la connexion** :

```bash
# Logs Tailscale
docker-compose -f docker-compose.full.yml logs -f tailscale

# Vous devriez voir :
# "Logged in as your-account@email.com"
# "Connected to Tailscale network"
```

### Accès à l'application via Tailscale

1. **Sur votre téléphone/ordinateur distant** :
   - Installez l'app Tailscale
   - Connectez-vous avec le même compte

2. **Trouvez l'IP Tailscale de votre serveur** :

```bash
# Dans le serveur
docker exec sahabi-tailscale tailscale ip -4
# Exemple : 100.64.1.5
```

3. **Accédez à votre app** :

```
https://100.64.1.5
```

### Configuration avancée : MagicDNS

Tailscale peut créer des noms DNS automatiques :

1. Activez **MagicDNS** sur [tailscale.com/admin/dns](https://login.tailscale.com/admin/dns)

2. Accédez via :

```
https://sahabi-guide.your-tailnet.ts.net
```

---

## 🔐 SSL/HTTPS avec Caddy

Caddy gère **automatiquement** les certificats SSL via Let's Encrypt. Aucune configuration manuelle nécessaire !

### Comment ça marche ?

1. **Première requête HTTPS** → Caddy contacte Let's Encrypt
2. **Validation du domaine** → Let's Encrypt vérifie que vous possédez le domaine
3. **Génération du certificat** → Caddy reçoit et stocke le certificat
4. **Renouvellement automatique** → Caddy renouvelle 30 jours avant expiration

### Vérifier les certificats

```bash
# Voir les logs Caddy
docker-compose -f docker-compose.full.yml logs -f caddy

# Vérifier les certificats générés
docker exec sahabi-caddy caddy list-certificates
```

### Tester avec Let's Encrypt Staging (éviter les rate limits)

Éditez le `Caddyfile` (ligne 10) :

```caddyfile
{
    email {$ACME_EMAIL}
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
```

Les certificats seront invalides mais ça évite les limites de production pendant les tests.

---

## 🛠️ Dépannage

### Problème 1 : Backend ne démarre pas

**Erreur** : `Connection refused to postgres`

**Solution** :

```bash
# Vérifier que postgres est bien démarré
docker-compose -f docker-compose.full.yml ps postgres

# Si pas démarré, lancer seul
docker-compose -f docker-compose.full.yml up -d postgres

# Attendre 30 secondes puis relancer backend
docker-compose -f docker-compose.full.yml up -d backend
```

### Problème 2 : Keycloak en boucle de redémarrage

**Erreur** : `Failed to connect to database`

**Solution** :

```bash
# Vérifier les logs
docker-compose -f docker-compose.full.yml logs keycloak

# Reset complet de postgres
docker-compose -f docker-compose.full.yml down -v
docker-compose -f docker-compose.full.yml up -d postgres
# Attendre 30 secondes
docker-compose -f docker-compose.full.yml up -d keycloak
```

### Problème 3 : Frontend affiche "API not reachable"

**Causes possibles** :

1. **Backend pas démarré** :

```bash
docker-compose -f docker-compose.full.yml logs backend
```

2. **Mauvaise URL d'API** :

Vérifiez le .env :

```env
VITE_API_BASE_URL=http://localhost:8084
```

Reconstruisez le frontend :

```bash
docker-compose -f docker-compose.full.yml build frontend
docker-compose -f docker-compose.full.yml up -d frontend
```

### Problème 4 : Caddy ne génère pas de certificat SSL

**Erreur** : `challenge failed`

**Solutions** :

1. **Vérifiez les DNS** :

```bash
nslookup votre-domaine.com
nslookup api.votre-domaine.com
```

Les IPs doivent correspondre à votre serveur.

2. **Ports 80 et 443 ouverts** :

```bash
# Vérifier les ports
sudo netstat -tlnp | grep -E ':(80|443)'

# Si occupés, arrêter le service qui les utilise
sudo systemctl stop apache2  # ou nginx
```

3. **Firewall** :

```bash
# Ubuntu/Debian
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### Problème 5 : Tailscale ne se connecte pas

**Erreur** : `Auth key invalid or expired`

**Solution** :

1. Générez une nouvelle Auth Key sur https://login.tailscale.com/admin/settings/keys
2. Cochez **Reusable**
3. Mettez à jour .env :

```env
TAILSCALE_AUTHKEY=tskey-auth-NOUVELLE_CLE
```

4. Redémarrez :

```bash
docker-compose -f docker-compose.full.yml restart tailscale
```

### Commandes de débogage utiles

```bash
# Voir l'utilisation des ressources
docker stats

# Inspecter un conteneur
docker inspect sahabi-backend

# Shell dans un conteneur
docker exec -it sahabi-backend sh

# Nettoyer tout (⚠️ DÉTRUIT LES DONNÉES)
docker-compose -f docker-compose.full.yml down -v
docker system prune -a --volumes
```

---

## 🚢 Production

### Checklist avant déploiement

- [ ] **Changez TOUS les mots de passe** dans .env
- [ ] **Utilisez un secret JWT fort** (64+ caractères aléatoires)
- [ ] **Configurez un vrai email** pour ACME_EMAIL
- [ ] **Configurez les DNS** vers votre serveur
- [ ] **Activez le firewall** (ports 80, 443, 22 uniquement)
- [ ] **Configurez les sauvegardes PostgreSQL**
- [ ] **Testez le renouvellement SSL** (simulez une expiration)
- [ ] **Monitoring** : ajoutez Prometheus + Grafana (optionnel)

### Sauvegardes automatiques PostgreSQL

Ajoutez un service de backup dans `docker-compose.full.yml` :

```yaml
backup:
  image: postgres:15-alpine
  container_name: sahabi-backup
  restart: unless-stopped
  environment:
    POSTGRES_HOST: postgres
    POSTGRES_DB: ${POSTGRES_DB}
    POSTGRES_USER: ${POSTGRES_USER}
    POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  volumes:
    - ./backups:/backups
    - ./backup.sh:/backup.sh:ro
  command: sh -c "crontab -l | { cat; echo '0 3 * * * /backup.sh'; } | crontab - && crond -f"
  depends_on:
    - postgres
  networks:
    - sahabi-network
```

Créez `backup.sh` :

```bash
#!/bin/sh
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/sahabi_db_$DATE.sql.gz"

pg_dump -h postgres -U sahabi sahabi_db | gzip > "$BACKUP_FILE"

# Garder seulement les 30 dernières sauvegardes
ls -t $BACKUP_DIR/sahabi_db_*.sql.gz | tail -n +31 | xargs rm -f
```

### SSL/TLS Configuration avancée

Pour une sécurité maximale, modifiez le `Caddyfile` :

```caddyfile
{
    email {$ACME_EMAIL}
    
    # Force TLS 1.3
    tls {
        protocols tls1.3
        ciphers TLS_AES_128_GCM_SHA256 TLS_AES_256_GCM_SHA384 TLS_CHACHA20_POLY1305_SHA256
    }
}
```

### Limites de ressources

Les limites sont déjà configurées dans `docker-compose.full.yml` :

- **PostgreSQL** : 512 MB RAM
- **Keycloak** : 1 GB RAM
- **Backend** : 768 MB RAM
- **Frontend** : 128 MB RAM

Ajustez selon vos besoins :

```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '1.0'
```

### Monitoring (optionnel)

Ajoutez Prometheus + Grafana :

```bash
# Télécharger la stack monitoring
curl -O https://raw.githubusercontent.com/stefanprodan/dockprom/master/docker-compose.yml

# Démarrer
docker-compose -f docker-compose.monitoring.yml up -d
```

---

## 📚 Ressources

- **Docker** : https://docs.docker.com
- **Caddy** : https://caddyserver.com/docs
- **Tailscale** : https://tailscale.com/kb
- **Keycloak** : https://www.keycloak.org/documentation
- **PostgreSQL** : https://www.postgresql.org/docs

---

## 🆘 Support

En cas de problème :

1. Consultez les logs : `docker-compose logs -f <service>`
2. Vérifiez la [section Dépannage](#dépannage)
3. Ouvrez une issue sur GitHub

---

## ✅ Récapitulatif des commandes

```bash
# Démarrer tous les services
docker-compose -f docker-compose.full.yml up -d

# Arrêter tous les services
docker-compose -f docker-compose.full.yml down

# Voir les logs
docker-compose -f docker-compose.full.yml logs -f

# Redémarrer un service
docker-compose -f docker-compose.full.yml restart backend

# Reconstruire après modification du code
docker-compose -f docker-compose.full.yml build backend
docker-compose -f docker-compose.full.yml up -d backend

# Nettoyer tout (⚠️ SUPPRIME LES DONNÉES)
docker-compose -f docker-compose.full.yml down -v
```

**🎉 Vous êtes prêt ! Lancez `docker-compose -f docker-compose.full.yml up -d` et tout fonctionnera automatiquement.**

