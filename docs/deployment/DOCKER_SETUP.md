# 📦 Guide de Déploiement Docker - Sahabi Guide

Ce document liste **tous les fichiers et répertoires impliqués** dans le déploiement Docker Compose du projet Sahabi Guide.

## 📋 Table des matières

1. [Fichiers de Configuration Docker](#fichiers-de-configuration-docker)
2. [Structure des Services](#structure-des-services)
3. [Fichiers à Déplacer Obligatoirement](#fichiers-à-déplacer-obligatoirement)
4. [Fichiers Optionnels](#fichiers-optionnels)
5. [Checklist de Déploiement](#checklist-de-déploiement)

---

## 🔧 Fichiers de Configuration Docker

### Fichiers Principaux (Racine du projet)

| Fichier | Obligatoire | Description |
|---------|-------------|-------------|
| `docker-compose.yml` | ✅ **OUI** | Configuration principale de tous les services (Postgres, Keycloak, Backend, Frontend, Caddy, Tailscale, PgAdmin) |
| `Caddyfile` | ⚠️ Si production | Configuration du reverse proxy Caddy (SSL automatique) |
| `tailscale-serve.json` | ⚠️ Si production | Configuration Tailscale pour accès distant sécurisé |
| `.env` ou `env.template` | ⚠️ Recommandé | Variables d'environnement (secrets, ports, domaines) |

---

## 🏗️ Structure des Services

### 1️⃣ Backend (Spring Boot API)

**Répertoire** : `sahabi-guide-api/`

#### Fichiers Docker
```
sahabi-guide-api/
├── Dockerfile ✅ OBLIGATOIRE
├── pom.xml ✅ OBLIGATOIRE (dépendances Maven)
├── src/ ✅ OBLIGATOIRE (code source Java)
│   ├── main/
│   │   ├── java/ (code Java)
│   │   └── resources/ (configuration Spring)
│   └── test/
```

#### Fichiers de Configuration Keycloak
```
sahabi-guide-api/
├── keycloak/
│   └── import/
│       └── sahabi-realm.json ✅ OBLIGATOIRE (configuration realm, clients, rôles, utilisateurs)
```

#### Scripts d'Initialisation PostgreSQL
```
postgres-init/
└── 01-init-keycloak-db.sh ✅ OBLIGATOIRE (création base de données Keycloak)
```

#### Fichiers Importants à Vérifier
- `src/main/resources/application.yml` - Configuration Spring Boot
- `src/main/resources/application-dev.yml` - Configuration développement
- `src/main/resources/application-prod.yml` - Configuration production
- `src/main/java/com/sahabiGuide/sahabi/config/OidcSecurityConfig.java` - Configuration sécurité OAuth2

---

### 2️⃣ Frontend (React Dashboard)

**Répertoire** : `sahabi-guide-dashboard/`

#### Fichiers Docker
```
sahabi-guide-dashboard/
├── Dockerfile ✅ OBLIGATOIRE
├── nginx.conf ✅ OBLIGATOIRE (configuration Nginx)
├── package.json ✅ OBLIGATOIRE (dépendances npm)
├── package-lock.json ✅ OBLIGATOIRE
├── vite.config.ts ✅ OBLIGATOIRE (configuration Vite)
├── tsconfig.json ✅ OBLIGATOIRE (configuration TypeScript)
└── src/ ✅ OBLIGATOIRE (code source React)
    ├── main.tsx
    ├── App.tsx
    ├── services/
    ├── components/
    └── pages/
```

#### Variables d'Environnement Build-Time
Ces variables sont définies dans `docker-compose.yml` et utilisées lors du build :
- `VITE_API_BASE_URL` : URL de l'API backend
- `VITE_KEYCLOAK_URL` : URL de Keycloak
- `VITE_KEYCLOAK_REALM` : Nom du realm Keycloak
- `VITE_KEYCLOAK_CLIENT_ID` : ID du client Keycloak

---

### 3️⃣ Base de Données PostgreSQL

#### Scripts d'Initialisation
```
postgres-init/
└── 01-init-keycloak-db.sh ✅ OBLIGATOIRE
```

**Ce script crée** :
- Base de données `sahabi_db` (pour le backend)
- Base de données `keycloak_db` (pour Keycloak)
- Utilisateur `keycloak` avec les privilèges nécessaires

#### Volumes Docker
Les données sont persistées dans des volumes Docker :
- `sahabiguide_postgres_data` : Données PostgreSQL

---

### 4️⃣ Keycloak (Authentification)

#### Configuration
```
sahabi-guide-api/keycloak/import/
└── sahabi-realm.json ✅ OBLIGATOIRE
```

**Contient** :
- Configuration du realm `sahabi`
- Clients OAuth2 : `sahabi-api`, `sahabi-mobile`, `sahabi-dashboard`
- Rôles : `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER`, `PILGRIM`
- Utilisateurs de test : `admin`, `guide`

---

### 5️⃣ Caddy (Reverse Proxy + SSL)

**Fichier** : `Caddyfile`

**Profil Docker** : `production` (activé uniquement en production)

```bash
# Démarrer avec Caddy
docker-compose --profile production up -d
```

---

### 6️⃣ Tailscale (Accès Distant)

**Fichier** : `tailscale-serve.json`

**Profil Docker** : `production`

---

### 7️⃣ PgAdmin (Administration DB)

**Fichier** : `sahabi-guide-api/pgadmin/servers.json`

**Profil Docker** : `tools`

```bash
# Démarrer avec PgAdmin
docker-compose --profile tools up -d pgadmin
```

---

## 📦 Fichiers à Déplacer Obligatoirement

### Pour un déploiement complet, vous DEVEZ déplacer :

#### 🔴 Niveau 1 - Essentiel
```
├── docker-compose.yml ✅
├── sahabi-guide-api/ ✅
│   ├── Dockerfile
│   ├── pom.xml
│   ├── src/
│   └── keycloak/import/sahabi-realm.json
├── sahabi-guide-dashboard/ ✅
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   ├── package-lock.json
│   └── src/
└── postgres-init/ ✅
    └── 01-init-keycloak-db.sh
```

#### 🟡 Niveau 2 - Recommandé pour Production
```
├── Caddyfile ⚠️ (si production avec SSL)
├── tailscale-serve.json ⚠️ (si accès distant)
└── .env ⚠️ (variables d'environnement)
```

#### 🟢 Niveau 3 - Optionnel
```
├── sahabi-guide-api/pgadmin/servers.json (si vous utilisez PgAdmin)
└── sahabi-guide-front/ (application mobile Flutter - non concernée par Docker)
```

---

## 🚫 Fichiers à NE PAS Déplacer

Ces fichiers sont générés ou spécifiques à l'environnement local :

```
❌ sahabi-guide-api/target/ (build Maven - sera régénéré)
❌ sahabi-guide-dashboard/node_modules/ (dépendances npm - sera régénéré)
❌ sahabi-guide-dashboard/dist/ (build Vite - sera régénéré)
❌ .git/ (historique Git)
❌ *.log (fichiers de logs)
❌ volumes Docker locaux
```

---

## 📝 Variables d'Environnement Importantes

### Créer un fichier `.env` à la racine

```env
# PostgreSQL
POSTGRES_DB=sahabi_db
POSTGRES_USER=sahabi
POSTGRES_PASSWORD=votre_mot_de_passe_securise
POSTGRES_PORT=5432

# Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=votre_mot_de_passe_admin_keycloak
KEYCLOAK_HOSTNAME=localhost  # ou votre domaine
KEYCLOAK_PORT=8080

# Backend
BACKEND_PORT=8084
SPRING_PROFILE=prod  # dev ou prod
APP_SECURITY_ENABLED=true

# Frontend
FRONTEND_PORT=3000

# Production uniquement
DOMAIN=votre-domaine.com  # pour Caddy
ACME_EMAIL=votre-email@domaine.com  # pour certificats SSL
TAILSCALE_AUTHKEY=tskey-...  # clé Tailscale
```

---

## ✅ Checklist de Déploiement

### Préparation

- [ ] Copier tous les fichiers essentiels (voir Niveau 1)
- [ ] Créer le fichier `.env` avec les bonnes variables
- [ ] Vérifier que Docker et Docker Compose sont installés

### Configuration

- [ ] Modifier `sahabi-realm.json` avec les bonnes URLs de redirection
- [ ] Ajuster les ports dans `.env` si nécessaire
- [ ] Configurer `Caddyfile` avec votre domaine (si production)

### Déploiement

```bash
# 1. Construire les images
docker-compose build

# 2. Démarrer les services essentiels
docker-compose up -d

# 3. Vérifier les logs
docker-compose logs -f

# 4. (Optionnel) Démarrer avec Caddy pour la production
docker-compose --profile production up -d
```

### Vérification

- [ ] PostgreSQL est accessible : `docker exec -it sahabi-postgres psql -U sahabi -d sahabi_db -c "\l"`
- [ ] Keycloak est accessible : http://localhost:8080
- [ ] Backend est accessible : http://localhost:8084/actuator/health
- [ ] Frontend est accessible : http://localhost:3000
- [ ] Test de connexion au dashboard avec `admin` / `admin123`

---

## 🔍 Commandes Utiles

### Voir l'état des services
```bash
docker-compose ps
```

### Voir les logs en temps réel
```bash
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f keycloak
```

### Redémarrer un service
```bash
docker-compose restart backend
```

### Reconstruire un service
```bash
docker-compose up -d --build backend
```

### Arrêter tous les services
```bash
docker-compose down
```

### Supprimer volumes (⚠️ perte de données)
```bash
docker-compose down -v
```

---

## 📊 Dépendances entre Services

```
┌─────────────┐
│  PostgreSQL │◄─────┬─────────────────┐
└─────────────┘      │                 │
                     │                 │
┌─────────────┐      │                 │
│  Keycloak   │◄─────┤                 │
└─────────────┘      │                 │
       ▲             │                 │
       │             │                 │
┌─────────────┐      │                 │
│   Backend   │──────┴─────────────────┘
└─────────────┘
       ▲
       │
┌─────────────┐
│  Frontend   │
└─────────────┘
       ▲
       │
┌─────────────┐
│    Caddy    │ (Production)
└─────────────┘
```

**Ordre de démarrage** :
1. PostgreSQL (healthcheck)
2. Keycloak (attend PostgreSQL)
3. Backend (attend PostgreSQL et Keycloak)
4. Frontend (attend Backend)
5. Caddy (attend Frontend et Backend)

---

## 🆘 Résolution de Problèmes

### Erreur : Base de données n'existe pas
```bash
# Recréer les volumes
docker-compose down -v
docker-compose up -d
```

### Erreur : Port déjà utilisé
```bash
# Modifier les ports dans .env
POSTGRES_PORT=5433
KEYCLOAK_PORT=8081
BACKEND_PORT=8085
FRONTEND_PORT=3001
```

### Erreur : Keycloak n'importe pas le realm
```bash
# Supprimer le volume keycloak et redémarrer
docker volume rm sahabiguide_postgres_data
docker-compose up -d
```

---

## 📞 Support

Pour plus d'informations :
- Backend API : `sahabi-guide-api/README.md`
- Dashboard : `sahabi-guide-dashboard/README.md`
- Documentation : `documentations/`

---

**Version du document** : 1.0  
**Dernière mise à jour** : 2025-11-08

