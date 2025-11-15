# 🎯 PROFILS HARMONISÉS - SAHABI GUIDE

## 📋 Vue d'ensemble

Ce document décrit tous les profils de configuration harmonisés pour le projet SahabiGuide, garantissant une cohérence parfaite entre développement et production.

---

## 🔧 BACKEND (Spring Boot API)

### Profils disponibles

| Profil | Fichier | Usage | Keycloak | Liquibase |
|--------|---------|-------|----------|-----------|
| **dev** | `application-dev.yml` | Développement local | ✅ Obligatoire | ✅ drop-first |
| **prod** | `application-prod.yml` | Production | ✅ Obligatoire | ✅ migrations only |
| **cloud** | `application-cloud.yml` | Déploiement cloud (Railway, Heroku) | ✅ Obligatoire | ✅ migrations only |
| **default** | `application.yml` | Base commune (pas utilisé seul) | ❌ | ✅ |

### Variables d'environnement OBLIGATOIRES en production

```bash
# Base de données
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/sahabi_db
DB_USERNAME=sahabi
DB_PASSWORD=<SECURE_PASSWORD>

# Keycloak (OBLIGATOIRE)
OIDC_ISSUER_URI=https://auth.sahabi.com/realms/sahabi
APP_SECURITY_ENABLED=true  # ⚠️ TOUJOURS true

# JWT (pour mobile)
JWT_SECRET=<LONG_SECURE_RANDOM_STRING_512_CHARS>

# CORS
CORS_ALLOWED_ORIGINS=https://dashboard.sahabi.com,https://api.sahabi.com

# Twilio (SMS/OTP)
TWILIO_ENABLED=true
TWILIO_ACCOUNT_SID=<YOUR_TWILIO_SID>
TWILIO_AUTH_TOKEN=<YOUR_TWILIO_TOKEN>
TWILIO_PHONE_NUMBER=<YOUR_TWILIO_NUMBER>
```

### Commandes de démarrage

```bash
# DÉVELOPPEMENT (avec Keycloak local)
export APP_SECURITY_ENABLED=true
export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# PRODUCTION
export SPRING_PROFILES_ACTIVE=prod
java -jar sahabi-guide-api.jar

# CLOUD (Railway, Heroku)
export SPRING_PROFILES_ACTIVE=cloud
java -jar sahabi-guide-api.jar
```

### Différences clés par profil

#### DEV
- Port : **8080** (configurable)
- Logs : **DEBUG**
- Swagger : **Activé**
- Liquibase : **drop-first=true** (⚠️ supprime les données à chaque démarrage)
- Twilio : **Désactivé** (OTP en console)
- Rate limiting : **Permissif** (20 tentatives/h)

#### PROD
- Port : **8084** (configurable)
- Logs : **WARN/INFO** (logs dans fichier)
- Swagger : **Désactivé** (sécurité)
- Liquibase : **drop-first=false** (migrations uniquement)
- Twilio : **Activé** (SMS réels)
- Rate limiting : **Strict** (5 tentatives/h)
- Pool DB : **Plus grand** (20 connexions max)

#### CLOUD
- Port : **8080** (standard cloud)
- Compatible **DATABASE_URL** (Railway, Heroku)
- Compatible variables **PGHOST, PGPORT, PGDATABASE** (Docker)
- Logs : **INFO** (console uniquement)
- Configuration identique à PROD pour la sécurité

---

## 🎨 DASHBOARD (React + Vite)

### Environnements

| Environnement | Build | Usage | Keycloak |
|---------------|-------|-------|----------|
| **Development** | `npm run dev` | Développement local | ✅ Obligatoire |
| **Production** | `npm run build` | Build pour production | ✅ Obligatoire |

### Variables d'environnement

#### Développement (fichier `.env.local` ou `.env`)

```bash
# API Backend
VITE_API_BASE_URL=http://localhost:8084
VITE_API_BASE_PATH=/api/v1

# Keycloak (OBLIGATOIRE)
VITE_ENABLE_KEYCLOAK=true  # Par défaut: true
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
```

#### Production (dans Docker Compose ou CI/CD)

```bash
# API Backend
VITE_API_BASE_URL=https://api.sahabi.com
VITE_API_BASE_PATH=/api/v1

# Keycloak (OBLIGATOIRE)
VITE_ENABLE_KEYCLOAK=true
VITE_KEYCLOAK_URL=https://auth.sahabi.com
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
```

### Dockerfile harmonisé

Le Dockerfile accepte maintenant **toutes** les variables nécessaires :

```dockerfile
# Build avec toutes les variables
docker build \
  --build-arg VITE_API_BASE_URL=https://api.sahabi.com \
  --build-arg VITE_API_BASE_PATH=/api/v1 \
  --build-arg VITE_ENABLE_KEYCLOAK=true \
  --build-arg VITE_KEYCLOAK_URL=https://auth.sahabi.com \
  --build-arg VITE_KEYCLOAK_REALM=sahabi \
  --build-arg VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard \
  -t sahabi-dashboard:prod .
```

### Commandes de démarrage

```bash
# DÉVELOPPEMENT
npm run dev

# BUILD PRODUCTION
npm run build
npm run preview  # Prévisualiser le build

# DOCKER PRODUCTION
docker-compose up -d frontend
```

### Configuration par défaut

**Keycloak est maintenant OBLIGATOIRE par défaut** :
- `VITE_ENABLE_KEYCLOAK !== 'false'` (activé si non défini ou = 'true')
- Pour désactiver temporairement (dev uniquement) : `VITE_ENABLE_KEYCLOAK=false`

---

## 📱 MOBILE (Flutter)

### Environnements

| Environnement | Fichier d'entrée | Build | Usage |
|---------------|------------------|-------|-------|
| **Development** | `lib/main_dev.dart` | Debug | Développement local |
| **Staging** | `lib/main_staging.dart` | Profile | Tests pré-prod |
| **Production** | `lib/main_prod.dart` | Release | Production |

### Configuration centralisée

Fichier : `lib/core/config/env_config.dart`

URLs configurées par environnement :

```dart
// Development
API: http://10.0.2.2:8084  (Android emulator)
Keycloak: http://10.0.2.2:8080

// Staging
API: https://api-staging.sahabi.com
Keycloak: https://auth-staging.sahabi.com

// Production
API: https://api.sahabi.com
Keycloak: https://auth.sahabi.com
```

### Commandes de démarrage

```bash
# DÉVELOPPEMENT
flutter run -t lib/main_dev.dart

# STAGING
flutter run -t lib/main_staging.dart \
  --dart-define=API_BASE_URL=https://api-staging.sahabi.com

# PRODUCTION (Release)
flutter run -t lib/main_prod.dart --release \
  --dart-define=API_BASE_URL=https://api.sahabi.com

# BUILD APK PRODUCTION
flutter build apk -t lib/main_prod.dart --release \
  --dart-define=API_BASE_URL=https://api.sahabi.com \
  --dart-define=KEYCLOAK_URL=https://auth.sahabi.com
```

### Variables --dart-define disponibles

```bash
# Surcharge d'URL (optionnel)
--dart-define=API_BASE_URL=https://custom-api.com
--dart-define=KEYCLOAK_URL=https://custom-auth.com
```

---

## 🐳 DOCKER COMPOSE

### Profils Docker Compose

Le fichier `docker-compose.yml` supporte plusieurs profils :

```bash
# Services de base (postgres, keycloak, backend, frontend)
docker-compose up -d

# Avec outils de développement (pgadmin)
docker-compose --profile tools up -d

# Avec reverse proxy et SSL (production)
docker-compose --profile production up -d
```

### Variables d'environnement Docker Compose

Fichier `.env` à la racine :

```bash
# PostgreSQL
POSTGRES_DB=sahabi_db
POSTGRES_USER=sahabi
POSTGRES_PASSWORD=sahabi

# Keycloak (OBLIGATOIRE)
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin123

# Backend
APP_SECURITY_ENABLED=true
OIDC_ISSUER_URI=http://keycloak:8080/realms/sahabi

# Frontend
VITE_ENABLE_KEYCLOAK=true
VITE_KEYCLOAK_URL=http://localhost:8080

# Twilio (optionnel en dev)
TWILIO_ENABLED=false
```

---

## ✅ CHECKLIST DE MISE EN PRODUCTION

### Backend

- [ ] Profil **prod** ou **cloud** activé
- [ ] Variable `APP_SECURITY_ENABLED=true`
- [ ] Variable `OIDC_ISSUER_URI` configurée (URL publique)
- [ ] Variable `JWT_SECRET` configurée (512 caractères minimum)
- [ ] Variables Twilio configurées (si SMS activés)
- [ ] Variable `CORS_ALLOWED_ORIGINS` avec URLs production
- [ ] Logs au niveau **INFO** ou **WARN**
- [ ] Swagger **désactivé** (sécurité)
- [ ] Liquibase `drop-first=false`
- [ ] Pool de connexions DB configuré (min: 5, max: 20)

### Dashboard

- [ ] Build avec `npm run build`
- [ ] Variable `VITE_ENABLE_KEYCLOAK=true`
- [ ] Variable `VITE_KEYCLOAK_URL` avec URL publique
- [ ] Variable `VITE_API_BASE_URL` avec URL publique
- [ ] Variable `VITE_KEYCLOAK_REALM=sahabi`
- [ ] Variable `VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard`
- [ ] Nginx configuré pour SPA (fallback index.html)
- [ ] HTTPS activé (Caddy ou Nginx)

### Mobile

- [ ] Build avec `main_prod.dart`
- [ ] Build en mode `--release`
- [ ] Variable `API_BASE_URL` configurée
- [ ] Variable `KEYCLOAK_URL` configurée
- [ ] Tests sur devices réels (Android + iOS)
- [ ] Permissions configurées (location, notifications)
- [ ] Icons et splash screens générés

### Infrastructure

- [ ] Keycloak accessible publiquement (HTTPS)
- [ ] Realm `sahabi` créé dans Keycloak
- [ ] Clients configurés :
  - `sahabi-dashboard` (public, pour dashboard)
  - `sahabi-mobile` (public, pour mobile)
- [ ] Utilisateurs / rôles créés
- [ ] PostgreSQL sauvegardé régulièrement
- [ ] Monitoring activé (logs, metrics)
- [ ] SSL/TLS configuré partout
- [ ] Firewall configuré

---

## 🔑 KEYCLOAK - Configuration minimale

### Realm : sahabi

#### Clients requis

**1. sahabi-dashboard** (React Dashboard)
```
Client ID: sahabi-dashboard
Client Protocol: openid-connect
Access Type: public
Valid Redirect URIs: https://dashboard.sahabi.com/*
Web Origins: https://dashboard.sahabi.com
```

**2. sahabi-mobile** (Flutter App)
```
Client ID: sahabi-mobile
Client Protocol: openid-connect
Access Type: public
Valid Redirect URIs: sahabiguide://oauth-callback
```

**3. sahabi-backend** (API - optionnel si bearer-only)
```
Client ID: sahabi-backend
Client Protocol: openid-connect
Access Type: bearer-only
```

#### Rôles requis

```
- SUPER_ADMIN  (accès total)
- AGENCE_ADMIN (gestion agence)
- AGENCE_USER  (lecture agence)
- PILGRIM      (application mobile)
```

---

## 📊 MATRICE DE COMPATIBILITÉ

| Composant | Dev | Staging | Prod | Cloud |
|-----------|-----|---------|------|-------|
| **Backend API** | ✅ dev | ✅ prod | ✅ prod | ✅ cloud |
| **Dashboard** | ✅ dev | ✅ build | ✅ build | ✅ build |
| **Mobile** | ✅ debug | ✅ profile | ✅ release | ✅ release |
| **Keycloak** | ✅ local | ✅ externe | ✅ externe | ✅ externe |
| **PostgreSQL** | ✅ local | ✅ externe | ✅ externe | ✅ cloud |
| **Swagger** | ✅ | ❌ | ❌ | ❌ |
| **Logs détaillés** | ✅ | ✅ | ❌ | ❌ |

---

## 🎯 RÉSUMÉ DES CHANGEMENTS

### Backend
✅ Profil `prod` corrigé (ddl-auto: none, Liquibase activé)
✅ Profil `cloud` sécurisé (Keycloak obligatoire)
✅ Configuration cohérente Keycloak partout
✅ Logging approprié par environnement

### Dashboard
✅ Keycloak obligatoire par défaut
✅ Dockerfile mis à jour avec toutes les variables
✅ Mode TEST avec confirmation explicite
✅ Fichier `.env.example` créé

### Mobile
✅ Configuration multi-environnements (EnvConfig)
✅ Points d'entrée séparés (main_dev, main_staging, main_prod)
✅ Support --dart-define pour surcharge
✅ URLs Keycloak configurées par environnement

### Infrastructure
✅ Variables env.template complétées
✅ Documentation complète des profils
✅ Checklist de mise en production

---

## 📞 BESOIN D'AIDE ?

Consultez :
- [Guide de démarrage avec Keycloak](docs/guides/DEMARRAGE_AVEC_KEYCLOAK.md)
- [Analyse connexion sans Keycloak](ANALYSE_CONNEXION_SANS_KEYCLOAK.md)
- [Démarrage rapide](DEMARRAGE_RAPIDE_KEYCLOAK.md)

**Tout est maintenant harmonisé et prêt pour la production ! 🚀**


