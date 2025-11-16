# 🔐 Keycloak pour Sahabi Guide - Google Cloud Run

Configuration Keycloak optimisée pour Google Cloud Run.

## 📦 Contenu

- `Dockerfile` : Image Keycloak optimisée pour Cloud Run
- `sahabi-realm.json` : Configuration du realm Sahabi (importé automatiquement)
- `CLOUD_RUN_DEPLOY.md` : Guide de déploiement complet

## 🚀 Déploiement Rapide

```bash
# 1. Configuration
export PROJECT_ID="votre-project-id"
export REGION="europe-west1"
export ARTIFACT_REGISTRY="sahabi-registry"

# 2. Build et Push
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest

# 3. Deploy
gcloud run deploy sahabi-keycloak \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest \
  --region=$REGION \
  --memory=1Gi \
  --allow-unauthenticated \
  --add-cloudsql-instances=$PROJECT_ID:$REGION:sahabi-postgres \
  [voir CLOUD_RUN_DEPLOY.md pour toutes les variables]
```

## 📖 Documentation

Voir [CLOUD_RUN_DEPLOY.md](./CLOUD_RUN_DEPLOY.md) pour le guide complet.

## 🔧 Configuration

### Realm Sahabi

Le realm `sahabi` est automatiquement importé au démarrage depuis `sahabi-realm.json`.

**Clients configurés** :
- `sahabi-dashboard` : Application React
- `sahabi-backend` : API Spring Boot (optionnel)

### Variables d'Environnement

Voir [CLOUD_RUN_DEPLOY.md](./CLOUD_RUN_DEPLOY.md) pour la liste complète.

## 🔗 Liens

- [Guide de déploiement complet](./CLOUD_RUN_DEPLOY.md)
- [Documentation Keycloak](https://www.keycloak.org/documentation)

---

**Version** : 1.0.0

