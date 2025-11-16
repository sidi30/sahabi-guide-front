# 🚀 Déploiement Keycloak sur Google Cloud Run

Guide spécifique pour déployer Keycloak (serveur d'authentification) sur Cloud Run.

## 📋 Prérequis

- Google Cloud SDK installé et configuré
- Docker installé
- Accès au projet Google Cloud
- Cloud SQL PostgreSQL créé avec la base `keycloak_db`

## 🔧 Variables d'Environnement Requises

### Variables Obligatoires

| Variable | Description | Exemple |
|----------|-------------|---------|
| `KC_HOSTNAME` | Hostname public | `sahabi-keycloak-xxx.run.app` |
| `DB_HOST` | Hôte PostgreSQL | `/cloudsql/PROJECT:REGION:INSTANCE` |
| `DB_PORT` | Port PostgreSQL | `5432` |
| `DB_NAME` | Nom de la base | `keycloak_db` |
| `DB_USER` | Utilisateur DB | `keycloak` |
| `DB_PASSWORD` | Mot de passe DB | `***` (secret) |
| `KEYCLOAK_ADMIN` | Admin username | `admin` |
| `KEYCLOAK_ADMIN_PASSWORD` | Admin password | `***` (secret) |

### Variables Optionnelles

| Variable | Description | Défaut |
|----------|-------------|--------|
| `KC_LOG_LEVEL` | Niveau de log | `INFO` |
| `KC_DB_SCHEMA` | Schéma DB | `public` |

## 📦 Fichiers Requis

Le dossier `sahabi-guide-keycloak` doit contenir :
- `Dockerfile` : Configuration Cloud Run
- `sahabi-realm.json` : Configuration du realm Sahabi (importé automatiquement)

## 🚢 Déploiement

### 1. Configuration des Variables

```bash
# Définir les variables de projet
export PROJECT_ID="votre-project-id"
export REGION="europe-west1"
export ARTIFACT_REGISTRY="sahabi-registry"
```

### 2. Créer les Secrets (première fois uniquement)

```bash
# Mot de passe de la base de données Keycloak
echo -n "VOTRE_MOT_DE_PASSE_DB_SECURISE" | \
  gcloud secrets create keycloak-db-password --data-file=-

# Mot de passe admin Keycloak
echo -n "VOTRE_MOT_DE_PASSE_ADMIN_SECURISE" | \
  gcloud secrets create keycloak-admin-password --data-file=-
```

### 3. Vérifier le Realm JSON

```bash
# Vérifier que le fichier realm existe
ls -lh sahabi-realm.json

# Vérifier le contenu (optionnel)
cat sahabi-realm.json | jq '.realm'
```

### 4. Build et Push de l'Image

```bash
# Build l'image Docker
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest .

# Vérifier l'image localement (optionnel, nécessite PostgreSQL local)
# docker run -p 8080:8080 \
#   -e PORT=8080 \
#   -e KC_HOSTNAME=localhost \
#   -e DB_HOST=host.docker.internal \
#   $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest

# Push vers Artifact Registry
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest
```

### 5. Déployer sur Cloud Run

```bash
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
  --concurrency=80 \
  --port=8080 \
  --set-env-vars="KC_HOSTNAME=sahabi-keycloak-xxx-ew.a.run.app" \
  --set-env-vars="KC_HOSTNAME_STRICT=false" \
  --set-env-vars="KC_HOSTNAME_STRICT_HTTPS=false" \
  --set-env-vars="KC_HTTP_ENABLED=true" \
  --set-env-vars="KC_PROXY_HEADERS=xforwarded" \
  --set-env-vars="KC_PROXY=edge" \
  --set-env-vars="KC_DB=postgres" \
  --set-env-vars="KC_DB_URL_HOST=/cloudsql/$PROJECT_ID:$REGION:sahabi-postgres" \
  --set-env-vars="KC_DB_URL_PORT=5432" \
  --set-env-vars="KC_DB_URL_DATABASE=keycloak_db" \
  --set-env-vars="KC_DB_USERNAME=keycloak" \
  --set-env-vars="KC_DB_SCHEMA=public" \
  --set-env-vars="KC_HEALTH_ENABLED=true" \
  --set-env-vars="KC_METRICS_ENABLED=true" \
  --set-env-vars="KC_LOG_LEVEL=INFO" \
  --set-secrets="KC_DB_PASSWORD=keycloak-db-password:latest" \
  --set-secrets="KC_BOOTSTRAP_ADMIN_PASSWORD=keycloak-admin-password:latest" \
  --add-cloudsql-instances=$PROJECT_ID:$REGION:sahabi-postgres
```

⚠️ **Important** : Remplacez `sahabi-keycloak-xxx-ew.a.run.app` par l'URL réelle après le déploiement.

### 6. Mettre à Jour le Hostname

Après le premier déploiement, récupérer l'URL et mettre à jour :

```bash
# Récupérer l'URL du service
export KEYCLOAK_URL=$(gcloud run services describe sahabi-keycloak \
  --region=$REGION --format="value(status.url)")

# Extraire le hostname (sans https://)
export KEYCLOAK_HOSTNAME=$(echo $KEYCLOAK_URL | sed 's|https://||')

echo "Keycloak URL: $KEYCLOAK_URL"
echo "Keycloak Hostname: $KEYCLOAK_HOSTNAME"

# Mettre à jour le service avec le bon hostname
gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --update-env-vars="KC_HOSTNAME=$KEYCLOAK_HOSTNAME"
```

### 7. Vérifier le Déploiement

```bash
# Tester le healthcheck
curl $KEYCLOAK_URL/health/ready

# Tester l'accès à la page de login
curl -I $KEYCLOAK_URL

# Ouvrir l'interface admin
echo "Admin Console: $KEYCLOAK_URL/admin"
echo "Username: admin"
echo "Password: [celui défini dans le secret]"
```

## 🔐 Configuration Post-Déploiement

### 1. Accéder à l'Admin Console

```bash
# Ouvrir dans le navigateur
open $KEYCLOAK_URL/admin
# ou
xdg-open $KEYCLOAK_URL/admin  # Linux
```

### 2. Vérifier le Realm Sahabi

1. Se connecter avec les identifiants admin
2. Dans le dropdown en haut à gauche, sélectionner le realm **sahabi**
3. Vérifier que le realm a été importé correctement

### 3. Configurer les Clients

#### Client : sahabi-dashboard

1. **Realm** → **Clients** → **sahabi-dashboard**
2. **Settings** :
   - **Valid Redirect URIs** : 
     - `https://sahabi-frontend-xxx.run.app/*`
     - `http://localhost:3000/*` (pour le dev)
   - **Valid Post Logout Redirect URIs** :
     - `https://sahabi-frontend-xxx.run.app/*`
     - `http://localhost:3000/*`
   - **Web Origins** :
     - `https://sahabi-frontend-xxx.run.app`
     - `http://localhost:3000`
   - **Access Type** : `public`
3. **Save**

#### Client : sahabi-backend (optionnel)

Si vous avez un client pour le backend :
1. Vérifier les **Client Authenticator** settings
2. Configurer les **Service Account Roles** si nécessaire

### 4. Créer des Utilisateurs de Test

1. **Realm** → **Users** → **Add User**
2. Remplir les informations
3. **Credentials** → Définir un mot de passe
4. Désactiver **Temporary** si nécessaire

## 📊 Monitoring

### Consulter les Logs

```bash
# Logs récents
gcloud run services logs read sahabi-keycloak --region=$REGION --limit=50

# Logs en temps réel
gcloud run services logs tail sahabi-keycloak --region=$REGION

# Filtrer les erreurs
gcloud run services logs read sahabi-keycloak \
  --region=$REGION \
  --filter="severity>=ERROR" \
  --limit=100

# Logs de démarrage
gcloud run services logs read sahabi-keycloak \
  --region=$REGION \
  --filter="textPayload:Keycloak" \
  --limit=50
```

### Métriques

```bash
# Health endpoint
curl $KEYCLOAK_URL/health

# Detailed health
curl $KEYCLOAK_URL/health/ready

# Metrics (nécessite authentification)
curl $KEYCLOAK_URL/metrics
```

### Console Cloud Run

```bash
echo "https://console.cloud.google.com/run/detail/$REGION/sahabi-keycloak/metrics?project=$PROJECT_ID"
```

## 🔄 Mise à Jour

### Rebuild et Redeploy

```bash
# Si vous modifiez le realm ou la configuration
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest

gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest
```

### Mise à Jour du Realm

⚠️ **Important** : Les modifications via l'UI Keycloak ne persistent pas entre les redéploiements.

Pour persister les changements :

1. **Exporter le realm depuis Keycloak** :
   ```bash
   # Via l'API (nécessite token admin)
   curl -X GET "$KEYCLOAK_URL/admin/realms/sahabi" \
     -H "Authorization: Bearer $TOKEN" \
     > sahabi-realm-new.json
   ```

2. **Remplacer le fichier** :
   ```bash
   cp sahabi-realm-new.json sahabi-realm.json
   ```

3. **Rebuild et redeploy** (voir ci-dessus)

### Rollback

```bash
# Lister les révisions
gcloud run revisions list --service=sahabi-keycloak --region=$REGION

# Revenir à une révision précédente
gcloud run services update-traffic sahabi-keycloak \
  --region=$REGION \
  --to-revisions=sahabi-keycloak-00001-xxx=100
```

## 🐛 Dépannage

### Keycloak ne démarre pas

```bash
# Vérifier les logs de démarrage
gcloud run services logs read sahabi-keycloak \
  --region=$REGION \
  --filter="textPayload:ERROR OR textPayload:Exception" \
  --limit=100

# Vérifier la connexion à Cloud SQL
gcloud sql instances describe sahabi-postgres

# Augmenter le timeout de démarrage
gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --timeout=600
```

### Erreur "Failed to start server in (database) mode"

Cela signifie généralement un problème de connexion à la base de données :

```bash
# Vérifier les variables DB
gcloud run services describe sahabi-keycloak --region=$REGION

# Vérifier que Cloud SQL est attaché
gcloud run services describe sahabi-keycloak --region=$REGION \
  --format="value(spec.template.spec.containers[0].resources.limits)"

# Tester la connexion DB manuellement
gcloud sql connect sahabi-postgres --user=keycloak --database=keycloak_db
```

### OOM (Out of Memory)

Keycloak consomme beaucoup de mémoire au démarrage :

```bash
# Augmenter la mémoire
gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --memory=2Gi
```

### Erreur "Invalid hostname"

```bash
# Mettre à jour le hostname pour correspondre à l'URL Cloud Run
export KEYCLOAK_HOSTNAME=$(gcloud run services describe sahabi-keycloak \
  --region=$REGION --format="value(status.url)" | sed 's|https://||')

gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --update-env-vars="KC_HOSTNAME=$KEYCLOAK_HOSTNAME"
```

### Le Realm n'est pas importé

```bash
# Vérifier que le fichier est dans l'image
docker run --rm --entrypoint ls \
  $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/keycloak:latest \
  -la /opt/keycloak/data/import/

# Vérifier les logs d'import
gcloud run services logs read sahabi-keycloak \
  --region=$REGION \
  --filter="textPayload:import" \
  --limit=50
```

## 🔐 Sécurité

### Utiliser un Service Account Dédié

```bash
# Créer un service account
gcloud iam service-accounts create sahabi-keycloak-sa \
  --display-name="Sahabi Keycloak Service Account"

# Permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:sahabi-keycloak-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"

gcloud secrets add-iam-policy-binding keycloak-db-password \
  --member="serviceAccount:sahabi-keycloak-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# Déployer avec le service account
gcloud run deploy sahabi-keycloak \
  --service-account=sahabi-keycloak-sa@$PROJECT_ID.iam.gserviceaccount.com \
  [autres options...]
```

### Restreindre l'Accès

Pour la production, ne pas utiliser `--allow-unauthenticated` :

```bash
gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --no-allow-unauthenticated

# Créer un Load Balancer avec Cloud Armor pour la sécurité
```

## 📝 Checklist

- [ ] Cloud SQL créé avec la base `keycloak_db`
- [ ] Utilisateur `keycloak` créé dans PostgreSQL
- [ ] Secrets créés dans Secret Manager
- [ ] Fichier `sahabi-realm.json` présent
- [ ] Image Docker buildée et pushée
- [ ] Service déployé sur Cloud Run
- [ ] Hostname mis à jour après déploiement
- [ ] Healthcheck répond correctement
- [ ] Admin console accessible
- [ ] Realm sahabi importé et visible
- [ ] Clients configurés (Redirect URIs)
- [ ] Logs vérifiés

## 🔗 Liens Utiles

- [Keycloak Official Docs](https://www.keycloak.org/documentation)
- [Keycloak on Containers](https://www.keycloak.org/server/containers)
- [Cloud Run Best Practices](https://cloud.google.com/run/docs/best-practices)
- [Keycloak Realm Export/Import](https://www.keycloak.org/server/importExport)

## 💡 Astuces

### Activer les Logs Debug

```bash
gcloud run services update sahabi-keycloak \
  --region=$REGION \
  --update-env-vars="KC_LOG_LEVEL=DEBUG"
```

### Exporter les Metrics Keycloak

Keycloak expose des metrics Prometheus sur `/metrics` (nécessite configuration additionnelle).

### Backup de la Configuration

```bash
# Exporter régulièrement le realm
./scripts/export-keycloak-realm.sh

# Versionner dans Git
git add sahabi-realm.json
git commit -m "Update Keycloak realm configuration"
```

---

**Dernière mise à jour** : 16 novembre 2025

