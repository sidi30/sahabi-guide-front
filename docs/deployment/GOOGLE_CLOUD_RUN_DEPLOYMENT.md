# 🚀 Guide de Déploiement Google Cloud Run - Sahabi Guide

Ce guide détaille le déploiement complet de l'application Sahabi Guide sur **Google Cloud Run**.

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Architecture Cloud Run](#architecture-cloud-run)
3. [Configuration de l'Infrastructure](#configuration-de-linfrastructure)
4. [Déploiement des Services](#déploiement-des-services)
5. [Configuration Post-Déploiement](#configuration-post-déploiement)
6. [Variables d'Environnement](#variables-denvironnement)
7. [Monitoring et Logs](#monitoring-et-logs)
8. [Dépannage](#dépannage)

---

## 🎯 Prérequis

### Outils Requis

```bash
# 1. Google Cloud SDK
gcloud --version

# 2. Docker
docker --version

# 3. Authentification Google Cloud
gcloud auth login
gcloud config set project VOTRE_PROJECT_ID
```

### Services Google Cloud à Activer

```bash
# Activer les APIs nécessaires
gcloud services enable \
  run.googleapis.com \
  sqladmin.googleapis.com \
  cloudscheduler.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  cloudbuild.googleapis.com
```

### Variables d'Environnement Locales

```bash
export PROJECT_ID="votre-project-id"
export REGION="europe-west1"  # ou votre région préférée
export ARTIFACT_REGISTRY="sahabi-registry"
```

---

## 🏗️ Architecture Cloud Run

```
┌─────────────────────────────────────────────────────────────┐
│                     Google Cloud Run                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Frontend   │  │   Backend    │  │   Keycloak   │      │
│  │   (React)    │  │ (Spring Boot)│  │    (Auth)    │      │
│  │   Port: 8080 │  │   Port: 8080 │  │   Port: 8080 │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                            ▼                                 │
│                   ┌─────────────────┐                        │
│                   │  Cloud SQL      │                        │
│                   │  (PostgreSQL)   │                        │
│                   └─────────────────┘                        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Services Déployés

1. **sahabi-frontend** : Application React (Dashboard)
2. **sahabi-backend** : API Spring Boot
3. **sahabi-keycloak** : Serveur d'authentification Keycloak
4. **sahabi-db** : Base de données PostgreSQL (Cloud SQL)

---

## 🗄️ Configuration de l'Infrastructure

### 1. Créer Artifact Registry

```bash
# Créer le registre pour stocker les images Docker
gcloud artifacts repositories create $ARTIFACT_REGISTRY \
  --repository-format=docker \
  --location=$REGION \
  --description="Registre Docker pour Sahabi Guide"

# Configurer Docker pour utiliser Artifact Registry
gcloud auth configure-docker $REGION-docker.pkg.dev
```

### 2. Créer Cloud SQL (PostgreSQL)

```bash
# Créer l'instance PostgreSQL
gcloud sql instances create sahabi-postgres \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=$REGION \
  --database-flags=max_connections=100 \
  --backup-start-time=03:00 \
  --maintenance-window-day=SUN \
  --maintenance-window-hour=4

# Créer les bases de données
gcloud sql databases create sahabi_db \
  --instance=sahabi-postgres

gcloud sql databases create keycloak_db \
  --instance=sahabi-postgres

# Créer les utilisateurs
gcloud sql users create sahabi \
  --instance=sahabi-postgres \
  --password=VOTRE_MOT_DE_PASSE_SECURISE

gcloud sql users create keycloak \
  --instance=sahabi-postgres \
  --password=VOTRE_MOT_DE_PASSE_SECURISE

# Récupérer la connection string
gcloud sql instances describe sahabi-postgres \
  --format="value(connectionName)"
# Résultat : PROJECT_ID:REGION:sahabi-postgres
```

### 3. Configurer les Secrets

```bash
# Créer les secrets dans Secret Manager
echo -n "VOTRE_JWT_SECRET_LONG_ET_SECURISE" | \
  gcloud secrets create jwt-secret --data-file=-

echo -n "VOTRE_MOT_DE_PASSE_DB" | \
  gcloud secrets create db-password --data-file=-

echo -n "VOTRE_KEYCLOAK_ADMIN_PASSWORD" | \
  gcloud secrets create keycloak-admin-password --data-file=-

# Twilio (optionnel)
echo -n "VOTRE_TWILIO_ACCOUNT_SID" | \
  gcloud secrets create twilio-account-sid --data-file=-

echo -n "VOTRE_TWILIO_AUTH_TOKEN" | \
  gcloud secrets create twilio-auth-token --data-file=-
```

---

## 🚢 Déploiement des Services

### 1. Déployer Keycloak

```bash
# Se positionner dans le dossier Keycloak
cd sahabi-guide-keycloak

# Build et push de l'image
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest

# Déployer sur Cloud Run
gcloud run deploy sahabi-keycloak \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --memory=1Gi \
  --cpu=2 \
  --timeout=300 \
  --max-instances=5 \
  --min-instances=1 \
  --set-env-vars="KC_HOSTNAME=sahabi-keycloak-XXXXX-ew.a.run.app" \
  --set-env-vars="DB_HOST=/cloudsql/PROJECT_ID:REGION:sahabi-postgres" \
  --set-env-vars="DB_PORT=5432" \
  --set-env-vars="DB_NAME=keycloak_db" \
  --set-env-vars="DB_USER=keycloak" \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --set-secrets="KEYCLOAK_ADMIN_PASSWORD=keycloak-admin-password:latest" \
  --add-cloudsql-instances=PROJECT_ID:REGION:sahabi-postgres

# Récupérer l'URL de Keycloak
export KEYCLOAK_URL=$(gcloud run services describe sahabi-keycloak \
  --region=$REGION --format="value(status.url)")
echo "Keycloak URL: $KEYCLOAK_URL"
```

### 2. Déployer le Backend (API Spring Boot)

```bash
# Se positionner dans le dossier API
cd ../sahabi-guide-api

# Build et push de l'image
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest

# Déployer sur Cloud Run
gcloud run deploy sahabi-backend \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --memory=768Mi \
  --cpu=2 \
  --timeout=300 \
  --max-instances=10 \
  --min-instances=1 \
  --set-env-vars="SPRING_PROFILES_ACTIVE=prod" \
  --set-env-vars="DB_HOST=/cloudsql/PROJECT_ID:REGION:sahabi-postgres" \
  --set-env-vars="DB_PORT=5432" \
  --set-env-vars="DB_NAME=sahabi_db" \
  --set-env-vars="DB_USERNAME=sahabi" \
  --set-env-vars="OIDC_ISSUER_URI=$KEYCLOAK_URL/realms/sahabi" \
  --set-env-vars="CORS_ALLOWED_ORIGINS=*" \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --set-secrets="JWT_SECRET=jwt-secret:latest" \
  --set-secrets="TWILIO_ACCOUNT_SID=twilio-account-sid:latest" \
  --set-secrets="TWILIO_AUTH_TOKEN=twilio-auth-token:latest" \
  --add-cloudsql-instances=PROJECT_ID:REGION:sahabi-postgres

# Récupérer l'URL du Backend
export BACKEND_URL=$(gcloud run services describe sahabi-backend \
  --region=$REGION --format="value(status.url)")
echo "Backend URL: $BACKEND_URL"
```

### 3. Déployer le Frontend (Dashboard React)

```bash
# Se positionner dans le dossier Dashboard
cd ../sahabi-guide-dashboard

# Build avec les variables d'environnement
docker build \
  --build-arg VITE_API_BASE_URL=$BACKEND_URL \
  --build-arg VITE_API_BASE_PATH=/api/v1 \
  --build-arg VITE_ENABLE_KEYCLOAK=true \
  --build-arg VITE_KEYCLOAK_URL=$KEYCLOAK_URL \
  --build-arg VITE_KEYCLOAK_REALM=sahabi \
  --build-arg VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard \
  -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest .

docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest

# Déployer sur Cloud Run
gcloud run deploy sahabi-frontend \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --memory=256Mi \
  --cpu=1 \
  --timeout=60 \
  --max-instances=10 \
  --min-instances=0

# Récupérer l'URL du Frontend
export FRONTEND_URL=$(gcloud run services describe sahabi-frontend \
  --region=$REGION --format="value(status.url)")
echo "Frontend URL: $FRONTEND_URL"
```

---

## ⚙️ Configuration Post-Déploiement

### 1. Configurer CORS sur le Backend

Mettre à jour le service backend avec les bons CORS :

```bash
gcloud run services update sahabi-backend \
  --region=$REGION \
  --update-env-vars="CORS_ALLOWED_ORIGINS=$FRONTEND_URL,$KEYCLOAK_URL"
```

### 2. Configurer Keycloak

1. Accéder à Keycloak : `$KEYCLOAK_URL`
2. Se connecter avec les identifiants admin
3. Aller dans le realm `sahabi`
4. Configurer les **Valid Redirect URIs** :
   - `$FRONTEND_URL/*`
   - `http://localhost:3000/*` (pour le développement)
5. Configurer les **Web Origins** :
   - `$FRONTEND_URL`
   - `http://localhost:3000`

### 3. Vérifier les Healthchecks

```bash
# Vérifier Keycloak
curl $KEYCLOAK_URL/health/ready

# Vérifier le Backend
curl $BACKEND_URL/actuator/health

# Vérifier le Frontend
curl $FRONTEND_URL/health
```

---

## 🔐 Variables d'Environnement

### Backend (sahabi-backend)

| Variable | Description | Exemple |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | Profil Spring actif | `prod` |
| `DB_HOST` | Hôte de la base de données | `/cloudsql/...` |
| `DB_NAME` | Nom de la base | `sahabi_db` |
| `DB_USERNAME` | Utilisateur DB | `sahabi` |
| `DB_PASSWORD` | Mot de passe DB (secret) | `***` |
| `JWT_SECRET` | Secret JWT (secret) | `***` |
| `OIDC_ISSUER_URI` | URL de Keycloak | `https://keycloak.../realms/sahabi` |
| `CORS_ALLOWED_ORIGINS` | Origines CORS autorisées | `https://frontend...` |

### Keycloak (sahabi-keycloak)

| Variable | Description | Exemple |
|----------|-------------|---------|
| `KC_HOSTNAME` | Hostname public | `sahabi-keycloak-xxx.run.app` |
| `DB_HOST` | Hôte de la base | `/cloudsql/...` |
| `DB_NAME` | Nom de la base | `keycloak_db` |
| `DB_USER` | Utilisateur DB | `keycloak` |
| `DB_PASSWORD` | Mot de passe DB (secret) | `***` |

### Frontend (sahabi-frontend)

Variables définies au **build time** :

| Variable | Description | Exemple |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | URL de l'API | `https://backend-xxx.run.app` |
| `VITE_KEYCLOAK_URL` | URL de Keycloak | `https://keycloak-xxx.run.app` |
| `VITE_ENABLE_KEYCLOAK` | Activer Keycloak | `true` |

---

## 📊 Monitoring et Logs

### Consulter les Logs

```bash
# Logs Keycloak
gcloud run services logs read sahabi-keycloak --region=$REGION --limit=50

# Logs Backend
gcloud run services logs read sahabi-backend --region=$REGION --limit=50

# Logs Frontend
gcloud run services logs read sahabi-frontend --region=$REGION --limit=50

# Logs en temps réel
gcloud run services logs tail sahabi-backend --region=$REGION
```

### Métriques

Accéder aux métriques dans la console Google Cloud :
- **Console Cloud Run** : https://console.cloud.google.com/run
- **Monitoring** : https://console.cloud.google.com/monitoring

---

## 🐛 Dépannage

### Le Backend ne démarre pas

```bash
# Vérifier les logs
gcloud run services logs read sahabi-backend --region=$REGION --limit=100

# Vérifier la connexion Cloud SQL
gcloud sql operations list --instance=sahabi-postgres

# Tester la connexion DB localement
gcloud sql connect sahabi-postgres --user=sahabi
```

### Keycloak ne répond pas

```bash
# Vérifier si l'instance est démarrée
gcloud run services describe sahabi-keycloak --region=$REGION

# Augmenter la mémoire si nécessaire
gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --memory=2Gi \
  --timeout=600
```

### Le Frontend ne se connecte pas au Backend

1. Vérifier les CORS du backend
2. Vérifier les variables d'environnement du build frontend
3. Reconstruire le frontend avec les bonnes URLs

```bash
# Rebuild avec les bonnes URLs
docker build \
  --build-arg VITE_API_BASE_URL=$BACKEND_URL \
  --build-arg VITE_KEYCLOAK_URL=$KEYCLOAK_URL \
  -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest .

docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest

gcloud run services update sahabi-frontend \
  --region=$REGION \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/frontend:latest
```

---

## 🔄 Mise à Jour des Services

### Script de Redéploiement Rapide

Créer un fichier `deploy.sh` :

```bash
#!/bin/bash
set -e

PROJECT_ID="votre-project-id"
REGION="europe-west1"
ARTIFACT_REGISTRY="sahabi-registry"

# Fonction de déploiement
deploy_service() {
  SERVICE=$1
  DIRECTORY=$2
  
  echo "🚀 Déploiement de $SERVICE..."
  cd $DIRECTORY
  
  docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$SERVICE:latest .
  docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$SERVICE:latest
  
  gcloud run services update $SERVICE \
    --region=$REGION \
    --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$SERVICE:latest
  
  cd -
  echo "✅ $SERVICE déployé avec succès"
}

# Déployer les services
deploy_service "sahabi-keycloak" "sahabi-guide-keycloak"
deploy_service "sahabi-backend" "sahabi-guide-api"
deploy_service "sahabi-frontend" "sahabi-guide-dashboard"

echo "🎉 Tous les services ont été redéployés avec succès !"
```

---

## 📝 Checklist de Déploiement

- [ ] APIs Google Cloud activées
- [ ] Artifact Registry créé
- [ ] Cloud SQL créé et configuré
- [ ] Secrets créés dans Secret Manager
- [ ] Keycloak déployé et accessible
- [ ] Backend déployé et connecté à la DB
- [ ] Frontend déployé avec les bonnes variables
- [ ] CORS configuré correctement
- [ ] Keycloak realm configuré
- [ ] Tests de santé (healthchecks) passent
- [ ] Logs vérifiés pour chaque service

---

## 📚 Ressources

- [Documentation Cloud Run](https://cloud.google.com/run/docs)
- [Cloud SQL pour PostgreSQL](https://cloud.google.com/sql/docs/postgres)
- [Secret Manager](https://cloud.google.com/secret-manager/docs)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)

---

**Dernière mise à jour** : 16 novembre 2025
**Version** : 1.0.0

