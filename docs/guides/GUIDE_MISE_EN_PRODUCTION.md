# 🚀 GUIDE COMPLET - MISE EN PRODUCTION SAHABI GUIDE

Ce guide vous accompagne **étape par étape** pour mettre votre projet en production **sans galère** !

---

## 📋 PRÉ-REQUIS

Avant de commencer, assurez-vous d'avoir :

- [ ] Un serveur avec Docker installé (VPS, cloud, etc.)
- [ ] Un nom de domaine (ex: `sahabi.com`)
- [ ] Accès SSH au serveur
- [ ] Compte Twilio (pour SMS/OTP)
- [ ] Certificats SSL (ou utiliser Let's Encrypt avec Caddy)

---

## 🎯 ÉTAPE 1 : CONFIGURATION DNS

Configurez vos sous-domaines DNS pour pointer vers l'IP de votre serveur :

```
Type    Nom                          Valeur              TTL
A       dashboard.sahabi.com         <IP_SERVEUR>        3600
A       api.sahabi.com               <IP_SERVEUR>        3600
A       auth.sahabi.com              <IP_SERVEUR>        3600
```

**Vérifiez** que les DNS sont propagés :
```bash
nslookup dashboard.sahabi.com
nslookup api.sahabi.com
nslookup auth.sahabi.com
```

---

## 🔐 ÉTAPE 2 : CONFIGURATION DES VARIABLES D'ENVIRONNEMENT

### 2.1 Copier le fichier exemple

```bash
cp .env.production.example .env.production
```

### 2.2 Éditer les valeurs

Ouvrez `.env.production` et remplacez :

#### **PostgreSQL** (Changez OBLIGATOIREMENT le mot de passe)
```bash
POSTGRES_PASSWORD=V0treM0tD3P4sseF0rtEtS3curis3!
```

#### **Keycloak** (Changez OBLIGATOIREMENT)
```bash
KEYCLOAK_ADMIN_PASSWORD=V0treM0tD3P4sseAdm1nK3ycl0ak!
KEYCLOAK_HOSTNAME=auth.sahabi.com  # Votre domaine
```

#### **Backend**
```bash
# URL publique de Keycloak
OIDC_ISSUER_URI=https://auth.sahabi.com/realms/sahabi

# JWT Secret - GÉNÉREZ UNE CHAÎNE ALÉATOIRE
# Commande pour générer un secret fort :
openssl rand -base64 512 | tr -d '\n'

JWT_SECRET=<COLLEZ_LE_RESULTAT_ICI>

# CORS - vos URLs publiques
CORS_ALLOWED_ORIGINS=https://dashboard.sahabi.com,https://api.sahabi.com,https://auth.sahabi.com

# Twilio
TWILIO_ENABLED=true
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+33612345678
```

#### **Dashboard**
```bash
VITE_API_BASE_URL=https://api.sahabi.com
VITE_KEYCLOAK_URL=https://auth.sahabi.com
VITE_ENABLE_KEYCLOAK=true  # ⚠️ OBLIGATOIRE
```

#### **Caddy** (Reverse Proxy)
```bash
DOMAIN=sahabi.com
ACME_EMAIL=admin@sahabi.com  # Pour Let's Encrypt
```

---

## 🐳 ÉTAPE 3 : DÉPLOIEMENT DOCKER

### 3.1 Transférer les fichiers sur le serveur

```bash
# Depuis votre machine locale
scp -r sahabiGuide/ user@<IP_SERVEUR>:/home/user/
```

Ou clonez depuis Git :
```bash
# Sur le serveur
git clone https://github.com/votre-repo/sahabiGuide.git
cd sahabiGuide
```

### 3.2 Préparer l'environnement

```bash
# Sur le serveur
cd sahabiGuide

# Copier le fichier de configuration
cp .env.production.example .env.production

# Éditer avec vos valeurs
nano .env.production
```

### 3.3 Lancer les services

```bash
# Lancer tous les services (avec profil production)
docker-compose --env-file .env.production --profile production up -d

# Vérifier que tout fonctionne
docker-compose ps
```

**Services attendus :**
- `sahabi-postgres` - ✅ Running
- `sahabi-keycloak` - ✅ Running
- `sahabi-backend` - ✅ Running
- `sahabi-frontend` - ✅ Running
- `sahabi-caddy` - ✅ Running

### 3.4 Vérifier les logs

```bash
# Logs de tous les services
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f keycloak
docker-compose logs -f frontend
```

---

## 🔑 ÉTAPE 4 : CONFIGURATION KEYCLOAK

### 4.1 Accéder à Keycloak Admin

Ouvrez https://auth.sahabi.com/admin dans votre navigateur

**Credentials :**
- Username : `admin`
- Password : (celui défini dans `KEYCLOAK_ADMIN_PASSWORD`)

### 4.2 Créer le Realm "sahabi"

1. Cliquez sur **"Create realm"** (en haut à gauche)
2. Nom : `sahabi`
3. Enabled : **ON**
4. Cliquez sur **"Create"**

### 4.3 Créer les Clients

#### **Client 1 : sahabi-dashboard**

1. Allez dans **Clients** → **Create client**
2. Remplissez :
   - Client ID : `sahabi-dashboard`
   - Client type : `OpenID Connect`
   - Cliquez sur **Next**
3. Paramètres :
   - Client authentication : **OFF**
   - Authorization : **OFF**
   - Standard flow : **ON**
   - Direct access grants : **OFF**
   - Cliquez sur **Next**
4. Valid redirect URIs : `https://dashboard.sahabi.com/*`
5. Valid post logout redirect URIs : `https://dashboard.sahabi.com/*`
6. Web origins : `https://dashboard.sahabi.com`
7. Cliquez sur **Save**

#### **Client 2 : sahabi-mobile**

1. **Clients** → **Create client**
2. Remplissez :
   - Client ID : `sahabi-mobile`
   - Client type : `OpenID Connect`
3. Paramètres :
   - Client authentication : **OFF**
   - Standard flow : **ON**
   - Direct access grants : **ON**
4. Valid redirect URIs : `sahabiguide://oauth-callback`
5. Cliquez sur **Save**

### 4.4 Créer les Rôles

1. Allez dans **Realm roles** → **Create role**
2. Créez ces rôles :

```
- SUPER_ADMIN  (accès complet au dashboard)
- AGENCE_ADMIN (gestion d'une agence)
- AGENCE_USER  (lecture agence)
- PILGRIM      (application mobile)
```

### 4.5 Créer un Utilisateur Admin

1. **Users** → **Add user**
2. Remplissez :
   - Username : `superadmin`
   - Email : `admin@sahabi.com`
   - First name : `Super`
   - Last name : `Admin`
   - Email verified : **ON**
   - Enabled : **ON**
3. Cliquez sur **Create**
4. Onglet **Credentials** :
   - Set password : `<VotreMotDePasse>`
   - Temporary : **OFF**
   - Cliquez sur **Save**
5. Onglet **Role mappings** :
   - **Assign role** → Cochez `SUPER_ADMIN`
   - Cliquez sur **Assign**

---

## ✅ ÉTAPE 5 : VÉRIFICATION

### 5.1 Vérifier Keycloak

```bash
# Test connexion Keycloak
curl -k https://auth.sahabi.com/realms/sahabi/.well-known/openid-configuration
```

Vous devez voir un JSON avec la configuration OpenID Connect.

### 5.2 Vérifier le Backend

```bash
# Test health check
curl https://api.sahabi.com/actuator/health
```

Réponse attendue :
```json
{"status":"UP"}
```

### 5.3 Vérifier le Dashboard

Ouvrez https://dashboard.sahabi.com dans votre navigateur.

**Attendu :**
1. Redirection vers Keycloak (https://auth.sahabi.com)
2. Formulaire de connexion Keycloak
3. Après connexion → retour au dashboard

**Connectez-vous** avec l'utilisateur créé précédemment.

---

## 🔧 ÉTAPE 6 : CONFIGURATION BACKEND (Optionnel)

### 6.1 Créer des données de test

```bash
# Accéder au conteneur backend
docker exec -it sahabi-backend sh

# Ou exécuter directement une commande
docker exec -it sahabi-backend ./mvnw liquibase:update
```

### 6.2 Vérifier les migrations Liquibase

```bash
# Vérifier les logs
docker-compose logs backend | grep -i liquibase
```

Vous devez voir :
```
Successfully acquired change log lock
...
Liquibase command 'update' was executed successfully.
```

---

## 📱 ÉTAPE 7 : CONFIGURATION MOBILE (Optionnel)

### 7.1 Build de production

```bash
cd sahabi-guide-front

# Android
flutter build apk -t lib/main_prod.dart --release \
  --dart-define=API_BASE_URL=https://api.sahabi.com \
  --dart-define=KEYCLOAK_URL=https://auth.sahabi.com

# iOS
flutter build ios -t lib/main_prod.dart --release \
  --dart-define=API_BASE_URL=https://api.sahabi.com \
  --dart-define=KEYCLOAK_URL=https://auth.sahabi.com
```

### 7.2 Tester l'APK

```bash
# Installer sur un device Android
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🛡️ ÉTAPE 8 : SÉCURISATION

### 8.1 Firewall (UFW)

```bash
# Autoriser uniquement les ports nécessaires
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (redirect to HTTPS)
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 8.2 Fail2Ban (Protection SSH)

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 8.3 Backup automatique

Créez un script de backup :

```bash
#!/bin/bash
# /home/user/backup-sahabi.sh

BACKUP_DIR="/home/user/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup PostgreSQL
docker exec sahabi-postgres pg_dump -U sahabi sahabi_db > "$BACKUP_DIR/sahabi_db_$DATE.sql"

# Garder seulement les 7 derniers backups
find $BACKUP_DIR -name "sahabi_db_*.sql" -mtime +7 -delete

echo "Backup terminé : $BACKUP_DIR/sahabi_db_$DATE.sql"
```

Ajoutez au cron :
```bash
crontab -e

# Backup tous les jours à 2h du matin
0 2 * * * /home/user/backup-sahabi.sh
```

---

## 🚨 DÉPANNAGE

### Problème : "Connection refused" sur Keycloak

**Solution :**
```bash
# Vérifier que Keycloak est bien démarré
docker-compose ps keycloak

# Vérifier les logs
docker-compose logs keycloak

# Redémarrer si nécessaire
docker-compose restart keycloak
```

### Problème : Dashboard ne se connecte pas à Keycloak

**Vérifications :**
1. `VITE_KEYCLOAK_URL` est bien l'URL **publique** (https://auth.sahabi.com)
2. Le client `sahabi-dashboard` est créé dans Keycloak
3. Les redirect URIs sont corrects dans Keycloak

**Rebuild du frontend :**
```bash
docker-compose --env-file .env.production build frontend
docker-compose --env-file .env.production up -d frontend
```

### Problème : Backend renvoie 401 Unauthorized

**Vérifications :**
1. `OIDC_ISSUER_URI` est correct (https://auth.sahabi.com/realms/sahabi)
2. `APP_SECURITY_ENABLED=true`
3. Le token JWT est bien envoyé dans les headers

**Redémarrer le backend :**
```bash
docker-compose restart backend
docker-compose logs -f backend
```

### Problème : SSL ne fonctionne pas

**Solution :**
```bash
# Vérifier les logs Caddy
docker-compose logs caddy

# Vérifier que le port 80 et 443 sont ouverts
sudo netstat -tuln | grep -E '(80|443)'

# Vérifier les DNS
nslookup dashboard.sahabi.com
nslookup api.sahabi.com
nslookup auth.sahabi.com
```

---

## 📊 MONITORING

### Logs en temps réel

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f keycloak
```

### Métriques

Accédez aux endpoints Actuator :
- Health : https://api.sahabi.com/actuator/health
- Info : https://api.sahabi.com/actuator/info
- Metrics : https://api.sahabi.com/actuator/metrics

---

## ✅ CHECKLIST FINALE

- [ ] DNS configurés et propagés
- [ ] Fichier `.env.production` complété avec vos valeurs
- [ ] Tous les services Docker lancés
- [ ] Keycloak accessible (https://auth.sahabi.com)
- [ ] Realm `sahabi` créé
- [ ] Clients créés (dashboard + mobile)
- [ ] Rôles créés (SUPER_ADMIN, etc.)
- [ ] Utilisateur admin créé
- [ ] Backend accessible (https://api.sahabi.com)
- [ ] Dashboard accessible (https://dashboard.sahabi.com)
- [ ] Connexion au dashboard fonctionne
- [ ] SSL/HTTPS fonctionnel partout
- [ ] Backups configurés
- [ ] Firewall activé
- [ ] Twilio configuré (SMS/OTP)

---

## 🎉 FÉLICITATIONS !

Votre application **SahabiGuide** est maintenant en production ! 🚀

### Prochaines étapes :

1. Créez les agences et utilisateurs dans le dashboard
2. Importez les pèlerins
3. Configurez les rituals et duas
4. Testez l'application mobile
5. Formez vos utilisateurs

### Support :

- Documentation : Consultez les fichiers `docs/`
- Profils : Voir `PROFILS_HARMONISES.md`
- Dépannage Keycloak : Voir `docs/guides/DEMARRAGE_AVEC_KEYCLOAK.md`

**Bonne utilisation ! 🕋**


