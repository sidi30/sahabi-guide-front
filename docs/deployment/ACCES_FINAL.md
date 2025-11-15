# 🎉 SAHABI GUIDE - TOUS LES SERVICES SONT OPÉRATIONNELS !

## ✅ État Actuel (Confirmé)

| Service | Statut | Port | URL |
|---------|--------|------|-----|
| **Keycloak** | ✅ HEALTHY | 8080 | http://localhost:8080 |
| **Backend API** | ✅ HEALTHY | 8084 | http://localhost:8084 |
| **PostgreSQL** | ✅ HEALTHY | 5432 | localhost:5432 |
| **Frontend** | ✅ RUNNING | 3000 | http://localhost:3000 |

## 🔐 1. KEYCLOAK - Console d'Administration

### Accès Direct
```
URL : http://localhost:8080
Username : admin
Password : admin
```

### Étapes :
1. Ouvrez http://localhost:8080 dans votre navigateur
2. Cliquez sur **"Administration Console"**
3. Connectez-vous avec `admin` / `admin`
4. Sélectionnez le realm **"sahabi"** (en haut à gauche)

### Realm Sahabi
Le realm `sahabi` est déjà configuré avec :
- ✅ Clients : `sahabi-dashboard`, `sahabi-mobile`
- ✅ Rôles : ADMIN, COORDINATOR, PILGRIM, etc.
- ✅ Configuration OAuth2/OIDC complète

## 🎨 2. DASHBOARD REACT

### Accès Direct
```
URL : http://localhost:3000
```

### Première Connexion
1. Ouvrez http://localhost:3000
2. Vous serez **automatiquement redirigé vers Keycloak**
3. Authentifiez-vous (créez un utilisateur dans Keycloak d'abord)
4. Après connexion, vous accédez au dashboard

### Créer un Utilisateur de Test
1. Dans Keycloak Admin Console
2. Sélectionnez le realm "sahabi"
3. Allez dans **"Users"** → **"Add user"**
4. Créez un utilisateur (ex: test@sahabi.com)
5. Allez dans l'onglet **"Credentials"**
6. Définissez un mot de passe (décochez "Temporary")

## 🔧 3. API BACKEND

### URLs Importantes
```
Health Check : http://localhost:8084/actuator/health
API Docs : http://localhost:8084/swagger-ui.html
API Base : http://localhost:8084/api/v1
```

### Test Rapide (PowerShell)
```powershell
Invoke-WebRequest -Uri http://localhost:8084/actuator/health | Select-Object -Expand Content
```

Résultat attendu : `{"status":"UP"}`

## 📊 4. POSTGRESQL

### Connexion Directe
```
Host : localhost
Port : 5432
Database : sahabi_db
Username : sahabi
Password : sahabi
```

### Via psql (PowerShell)
```powershell
docker exec -it sahabi-postgres psql -U sahabi -d sahabi_db
```

### Commandes SQL Utiles
```sql
-- Voir toutes les tables
\dt

-- Voir les utilisateurs Keycloak
SELECT username, email FROM user_entity;

-- Voir les agences
SELECT * FROM agencies;

-- Voir les groupes
SELECT * FROM groups;
```

## 🎯 Ordre de Test Recommandé

### 1️⃣ Tester Keycloak
```powershell
Start-Process "http://localhost:8080"
```
- Connectez-vous à la console admin
- Explorez le realm "sahabi"
- Créez un utilisateur de test

### 2️⃣ Tester l'API
```powershell
Start-Process "http://localhost:8084/swagger-ui.html"
```
- Explorez les endpoints disponibles
- Testez quelques requêtes

### 3️⃣ Tester le Dashboard
```powershell
Start-Process "http://localhost:3000"
```
- Authentifiez-vous avec l'utilisateur créé
- Explorez l'interface

## 📋 Commandes Docker Compose Utiles

### Voir l'état de tous les services
```powershell
docker-compose ps
```

### Voir les logs d'un service
```powershell
docker-compose logs -f keycloak
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Redémarrer un service
```powershell
docker-compose restart keycloak
docker-compose restart backend
docker-compose restart frontend
```

### Arrêter tous les services
```powershell
docker-compose down
```

### Démarrer tous les services
```powershell
docker-compose up -d
```

### Voir tous les conteneurs Docker
```powershell
docker ps
```

## 🔑 Identifiants par Défaut

### Keycloak Admin
```
URL : http://localhost:8080
Username : admin
Password : admin
```

### PostgreSQL
```
Host : localhost
Port : 5432
Database : sahabi_db
Username : sahabi
Password : sahabi
```

### Variables d'Environnement
Toutes les configurations sont dans le fichier `.env` (copie de `env.template`)

## 🐛 Si un Service ne Répond Pas

### Keycloak
```powershell
# Voir les logs
docker-compose logs keycloak --tail=50

# Redémarrer
docker-compose restart keycloak

# Attendre 1 minute
Start-Sleep -Seconds 60
```

### Backend
```powershell
# Voir les logs
docker-compose logs backend --tail=50

# Redémarrer
docker-compose restart backend
```

### Frontend
```powershell
# Voir les logs
docker-compose logs frontend --tail=50

# Redémarrer
docker-compose restart frontend
```

### Pour Tout Redémarrer
```powershell
docker-compose down
docker-compose up -d
Start-Sleep -Seconds 60
docker-compose ps
```

## 🎊 Configuration OAuth2 (Pour Information)

### Keycloak (Inter-conteneurs)
```
Issuer URI : http://keycloak:8080/realms/sahabi
```

### Keycloak (Depuis le navigateur)
```
URL : http://localhost:8080/realms/sahabi
```

### Clients Configurés
1. **sahabi-dashboard** (Frontend)
   - Type : Public
   - Redirect URIs : http://localhost:3000/*
   - Web Origins : http://localhost:3000

2. **sahabi-mobile** (Application mobile)
   - Type : Public
   - Support PKCE

## 📝 Notes Importantes

- ⚠️ **Mode Développement** : Keycloak est en mode `dev`, ne pas utiliser en production
- ✅ **Volumes Persistants** : Les données sont conservées dans des volumes Docker
- ✅ **Communication Interne** : Les services communiquent via le réseau Docker `sahabi-network`
- ✅ **Import Automatique** : Le realm Sahabi est importé automatiquement au démarrage

## 🚀 Vous Êtes Prêt !

Tous vos services sont maintenant **100% opérationnels** et configurés !

**Commencez par ouvrir Keycloak** : http://localhost:8080

Bon développement ! 🎉





