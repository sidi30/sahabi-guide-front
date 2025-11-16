# 🚀 Scripts de Déploiement Google Cloud Run

Scripts automatisés pour déployer Sahabi Guide sur Google Cloud Run.

## 📋 Scripts Disponibles

### 1. Script Bash (Linux/macOS)

```bash
./scripts/deployment/deploy-cloud-run.sh
```

### 2. Script PowerShell (Windows)

```powershell
.\scripts\deployment\deploy-cloud-run.ps1
```

## 🎯 Fonctionnalités

Les scripts effectuent automatiquement :

✅ Vérification des prérequis (gcloud, Docker)  
✅ Configuration du projet Google Cloud  
✅ Activation des APIs nécessaires  
✅ Création de l'Artifact Registry  
✅ Création de Cloud SQL PostgreSQL  
✅ Configuration des secrets (Secret Manager)  
✅ Build et déploiement de Keycloak  
✅ Build et déploiement du Backend (Spring Boot)  
✅ Build et déploiement du Frontend (React)  
✅ Configuration automatique des CORS  

## 📋 Prérequis

### 1. Outils Installés

- **Google Cloud SDK** : https://cloud.google.com/sdk/docs/install
- **Docker** : https://docs.docker.com/get-docker/
- **Bash** (Linux/macOS) ou **PowerShell** (Windows)

### 2. Authentification Google Cloud

```bash
# Se connecter à Google Cloud
gcloud auth login

# Lister les projets
gcloud projects list

# Sélectionner un projet (optionnel)
gcloud config set project VOTRE_PROJECT_ID
```

### 3. Permissions Requises

Votre compte doit avoir les rôles suivants :

- `roles/run.admin` - Cloud Run Admin
- `roles/sql.admin` - Cloud SQL Admin
- `roles/artifactregistry.admin` - Artifact Registry Admin
- `roles/secretmanager.admin` - Secret Manager Admin
- `roles/iam.serviceAccountUser` - Service Account User

## 🚀 Utilisation

### Déploiement Complet

#### Linux/macOS

```bash
# Se positionner à la racine du projet
cd sahabiGuide

# Rendre le script exécutable
chmod +x scripts/deployment/deploy-cloud-run.sh

# Exécuter le script
./scripts/deployment/deploy-cloud-run.sh
```

#### Windows

```powershell
# Se positionner à la racine du projet
cd sahabiGuide

# Exécuter le script PowerShell
.\scripts\deployment\deploy-cloud-run.ps1

# Si vous avez une erreur de politique d'exécution :
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\deployment\deploy-cloud-run.ps1
```

### Déploiement Interactif

Le script vous demandera :

1. **PROJECT_ID** : Votre ID de projet Google Cloud
2. **REGION** : La région de déploiement (défaut : `europe-west1`)
3. **Mots de passe** :
   - Mot de passe DB pour l'utilisateur `sahabi`
   - Mot de passe DB pour l'utilisateur `keycloak`
   - Mot de passe admin Keycloak
4. **Twilio** (optionnel) : Configuration Twilio si nécessaire

## 📊 Déroulement du Déploiement

```
1️⃣  Vérification des prérequis
    ✅ gcloud CLI installé
    ✅ Docker installé
    ✅ Authentification Google Cloud

2️⃣  Configuration
    ⚙️  PROJECT_ID
    ⚙️  REGION
    ⚙️  ARTIFACT_REGISTRY

3️⃣  Activation des APIs
    🔌 Cloud Run API
    🔌 Cloud SQL Admin API
    🔌 Artifact Registry API
    🔌 Secret Manager API
    🔌 Cloud Build API

4️⃣  Infrastructure
    📦 Artifact Registry
    🗄️  Cloud SQL PostgreSQL
    🔐 Secret Manager

5️⃣  Déploiement des Services
    🔐 Keycloak (Auth)
    🔧 Backend (Spring Boot)
    🎨 Frontend (React)

6️⃣  Configuration Post-Déploiement
    🌐 CORS
    ✅ Vérifications

7️⃣  Résumé
    📌 URLs des services
    ⚠️  Actions requises
```

## 📝 Après le Déploiement

### 1. Configurer Keycloak

1. Accéder à l'Admin Console :
   ```
   https://sahabi-keycloak-XXXXX.run.app/admin
   ```

2. Se connecter avec le mot de passe admin configuré

3. Aller dans **Clients** → **sahabi-dashboard**

4. Ajouter les **Valid Redirect URIs** :
   - `https://sahabi-frontend-XXXXX.run.app/*`
   - `http://localhost:3000/*` (pour le dev local)

5. Ajouter les **Web Origins** :
   - `https://sahabi-frontend-XXXXX.run.app`
   - `http://localhost:3000`

6. **Save**

### 2. Tester l'Application

Ouvrir l'URL du frontend dans votre navigateur :
```
https://sahabi-frontend-XXXXX.run.app
```

### 3. Vérifier les Services

```bash
# Healthcheck Backend
curl https://sahabi-backend-XXXXX.run.app/actuator/health

# Healthcheck Keycloak
curl https://sahabi-keycloak-XXXXX.run.app/health/ready

# Healthcheck Frontend
curl https://sahabi-frontend-XXXXX.run.app/health
```

## 🔧 Personnalisation

### Variables d'Environnement

Vous pouvez définir les variables avant d'exécuter le script :

```bash
# Bash
export PROJECT_ID="mon-projet"
export REGION="us-central1"
./scripts/deployment/deploy-cloud-run.sh

# PowerShell
$env:PROJECT_ID="mon-projet"
$env:REGION="us-central1"
.\scripts\deployment\deploy-cloud-run.ps1
```

### Modification des Ressources

Pour modifier les ressources (CPU, mémoire, instances), éditez le script :

```bash
# Exemple : Augmenter la mémoire du backend
--memory=1Gi  # au lieu de 768Mi
```

## 🐛 Dépannage

### Erreur : "gcloud: command not found"

**Solution** : Installer Google Cloud SDK
```bash
# Linux
curl https://sdk.cloud.google.com | bash

# macOS
brew install --cask google-cloud-sdk

# Windows
# Télécharger depuis https://cloud.google.com/sdk/docs/install
```

### Erreur : "docker: command not found"

**Solution** : Installer Docker Desktop
```
https://docs.docker.com/get-docker/
```

### Erreur : "You do not currently have an active account selected"

**Solution** : Se connecter à Google Cloud
```bash
gcloud auth login
gcloud config set project VOTRE_PROJECT_ID
```

### Erreur : "Permission denied"

**Solution** : Vérifier les permissions IAM
```bash
# Lister les rôles de votre compte
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:VOTRE_EMAIL"
```

### Le script échoue à mi-parcours

**Solution** : Relancer le script, il ignorera les ressources déjà créées

## 📚 Documentation

- [Guide Complet de Déploiement](../../docs/deployment/GOOGLE_CLOUD_RUN_DEPLOYMENT.md)
- [Déploiement Backend](../../sahabi-guide-api/CLOUD_RUN_DEPLOY.md)
- [Déploiement Frontend](../../sahabi-guide-dashboard/CLOUD_RUN_DEPLOY.md)
- [Déploiement Keycloak](../../sahabi-guide-keycloak/CLOUD_RUN_DEPLOY.md)
- [README Principal](../../DEPLOIEMENT_CLOUD_RUN.md)

## 🔗 Ressources

- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)

## 💡 Conseils

### Développement Local

Pour tester localement avant de déployer :

```bash
# Tester la build Docker
docker build -t test-backend ./sahabi-guide-api
docker run -p 8080:8080 -e PORT=8080 test-backend
```

### Déploiement Incrémental

Pour ne déployer qu'un service :

```bash
# Déployer uniquement le backend
cd sahabi-guide-api
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/backend:latest
gcloud run services update sahabi-backend --region=$REGION --image=...
```

### Monitoring

Activer les alertes dans Cloud Console :
- CPU > 80%
- Mémoire > 80%
- Taux d'erreur 5xx > 5%

---

**Version** : 1.0.0  
**Dernière mise à jour** : 16 novembre 2025

🎉 **Bon déploiement !**

