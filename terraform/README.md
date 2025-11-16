# 🚀 Déploiement Sahabi Guide avec Terraform sur Google Cloud

Guide complet pour déployer toute l'infrastructure sur Google Cloud Run en une seule commande.

## 📋 Ce qui sera déployé

| Service | Description | Configuration |
|---------|-------------|---------------|
| **Cloud SQL PostgreSQL** | Base de données | db-f1-micro, 2 bases (sahabi_db, keycloak_db) |
| **Keycloak** | Serveur d'authentification | 2Gi RAM, 2 CPU, min 1 instance |
| **Backend API** | API Spring Boot | 768Mi RAM, 2 CPU, min 1 instance |
| **Frontend** | Dashboard React | 256Mi RAM, 1 CPU, min 0 instance |
| **Artifact Registry** | Registry Docker | Stockage images |
| **Secret Manager** | Gestion des secrets | Mots de passe, JWT |

**Coût estimé** : ~95-125 USD/mois

---

## 🛠️ Prérequis

### 1. Outils Nécessaires

- ✅ **Google Cloud SDK** (gcloud) - [Installer](https://cloud.google.com/sdk/docs/install)
- ✅ **Terraform** (v1.0+) - [Installer](https://www.terraform.io/downloads)
- ✅ **Docker** - [Installer](https://docs.docker.com/get-docker/)
- ✅ **Git** (pour cloner le projet)

#### Installation Terraform

**Windows (PowerShell Administrateur)** :
```powershell
# Avec Chocolatey
choco install terraform

# Avec Scoop
scoop install terraform

# Vérifier
terraform --version
```

**Linux/macOS** :
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y terraform

# macOS
brew install terraform

# Vérifier
terraform --version
```

### 2. Configuration Google Cloud

```powershell
# Se connecter à Google Cloud
gcloud auth login

# Configurer le projet
gcloud config set project sahabiguide-478323

# Configurer Docker pour Artifact Registry
gcloud auth configure-docker europe-west1-docker.pkg.dev
```

---

## 📦 Déploiement Complet (Méthode Recommandée)

### Étape 1 : Préparer la Configuration

Le fichier `terraform.tfvars` devrait déjà exister avec vos secrets. Sinon, créez-le :

```powershell
# Copier l'exemple
cp terraform.tfvars.example terraform.tfvars

# Éditer avec vos valeurs
notepad terraform.tfvars  # Windows
nano terraform.tfvars     # Linux/macOS
```

**Contenu minimum** :
```hcl
project_id = "sahabiguide-478323"
region     = "europe-west1"

# IMPORTANT: Utilisez des mots de passe forts !
db_password              = "VotreMotDePasseSecuriseDB123!"
keycloak_admin_password  = "VotreMotDePasseAdminKeycloak456!"
jwt_secret              = "VotreSecretJWT64CaracteresMinimum789012345678901234567890"

# Images Docker (optionnel, sera construit automatiquement)
keycloak_image = ""
backend_image  = ""
frontend_image = ""
```

### Étape 2 : Build et Push des Images Docker

```powershell
# Windows
.\push-images.ps1

# Linux/macOS
chmod +x push-images.sh
./push-images.sh
```

Ce script va :
1. ✅ Build l'image Keycloak
2. ✅ Build l'image Backend (API)
3. ✅ Build l'image Frontend (Dashboard)
4. ✅ Push vers Artifact Registry

**Durée estimée** : 5-10 minutes

### Étape 3 : Déployer l'Infrastructure

```powershell
# Initialiser Terraform (première fois uniquement)
terraform init

# Voir ce qui sera créé
terraform plan

# Déployer ! 🚀
terraform apply
```

Terraform vous demandera de confirmer. Tapez `yes`.

**Ce qui sera créé** :
1. ✅ Cloud SQL PostgreSQL (instance + 2 bases de données)
2. ✅ 2 utilisateurs PostgreSQL (sahabi, keycloak)
3. ✅ 3 secrets dans Secret Manager
4. ✅ Artifact Registry repository
5. ✅ 3 services Cloud Run
6. ✅ IAM roles et permissions
7. ✅ Configurations réseau

**Durée estimée** : 10-15 minutes

### Étape 4 : Vérifier la Base de Données

**IMPORTANT** : Avant que Keycloak puisse démarrer, vérifions que la base de données est correctement configurée :

```powershell
# Exécuter le script de vérification
.\verify-db.ps1
```

Si tout est OK, vous verrez :
```
✅ Instance Cloud SQL trouvée
✅ Base de données 'keycloak_db' trouvée
✅ Utilisateur 'keycloak' trouvé
```

**Si Keycloak ne démarre toujours pas**, donnez les permissions manuellement :

```powershell
# Se connecter à Cloud SQL en tant qu'utilisateur postgres
gcloud sql connect sahabi-postgres --user=postgres

# Dans le shell PostgreSQL, exécutez :
```

```sql
-- Se connecter à keycloak_db
\c keycloak_db;

-- Donner tous les privilèges à keycloak
GRANT ALL PRIVILEGES ON DATABASE keycloak_db TO keycloak;
GRANT ALL PRIVILEGES ON SCHEMA public TO keycloak;
ALTER SCHEMA public OWNER TO keycloak;

-- Vérifier
\l keycloak_db
\q
```

### Étape 5 : Vérifier le Déploiement

```powershell
# Récupérer les URLs des services
terraform output

# Tester Keycloak
$KEYCLOAK_URL = terraform output -raw keycloak_url
Invoke-WebRequest -Uri "$KEYCLOAK_URL/health/ready"

# Tester le Backend
$BACKEND_URL = terraform output -raw backend_url
Invoke-WebRequest -Uri "$BACKEND_URL/actuator/health"

# Tester le Frontend
$FRONTEND_URL = terraform output -raw frontend_url
Start-Process $FRONTEND_URL
```

### Étape 6 : Configurer Keycloak

1. **Accéder à l'Admin Console** :
   ```powershell
   $KEYCLOAK_URL = terraform output -raw keycloak_url
   Start-Process "$KEYCLOAK_URL/admin"
   ```

2. **Se connecter** :
   - Username: `admin`
   - Password: (celui dans `terraform.tfvars` - `keycloak_admin_password`)

3. **Configurer le Client** :
   - Realm: `sahabi` → Clients → `sahabi-dashboard`
   - **Valid Redirect URIs** : `<FRONTEND_URL>/*` + `http://localhost:3000/*`
   - **Valid Post Logout Redirect URIs** : `<FRONTEND_URL>/*` + `http://localhost:3000/*`
   - **Web Origins** : `<FRONTEND_URL>` + `http://localhost:3000`
   - **Save**

4. **Vérifier le Realm** :
   - Le realm `sahabi` devrait être importé automatiquement
   - Vérifier les rôles, clients, etc.

---

## 📊 Surveillance et Logs

### Consulter les Logs

```powershell
# Logs Keycloak
gcloud run services logs read sahabi-keycloak --region=europe-west1 --limit=50

# Logs Backend
gcloud run services logs read sahabi-backend --region=europe-west1 --limit=50

# Logs Frontend
gcloud run services logs read sahabi-frontend --region=europe-west1 --limit=50

# Logs en temps réel
gcloud run services logs tail sahabi-keycloak --region=europe-west1
```

### Surveiller les Services

```powershell
# État des services
gcloud run services list --region=europe-west1

# Détails d'un service
gcloud run services describe sahabi-keycloak --region=europe-west1

# Métriques dans la console
echo "https://console.cloud.google.com/run?project=sahabiguide-478323"
```

### Se Connecter à la Base de Données

```powershell
# Connexion interactive
gcloud sql connect sahabi-postgres --user=keycloak --database=keycloak_db

# Lister les bases
gcloud sql databases list --instance=sahabi-postgres

# Lister les utilisateurs
gcloud sql users list --instance=sahabi-postgres
```

---

## 🔧 Commandes Terraform Utiles

### Gestion de l'Infrastructure

```bash
# Voir l'état actuel
terraform show

# Rafraîchir l'état
terraform refresh

# Voir les outputs
terraform output

# Formater les fichiers
terraform fmt

# Valider la configuration
terraform validate
```

### Mises à Jour

```bash
# Mettre à jour seulement Keycloak
terraform apply -target=google_cloud_run_v2_service.keycloak

# Mettre à jour seulement le Backend
terraform apply -target=google_cloud_run_v2_service.backend

# Mettre à jour seulement le Frontend
terraform apply -target=google_cloud_run_v2_service.frontend
```

### Destruction

```bash
# Détruire TOUTE l'infrastructure (ATTENTION !)
terraform destroy

# Détruire un service spécifique
terraform destroy -target=google_cloud_run_v2_service.frontend
```

---

## 🐛 Dépannage

### Problème : Keycloak ne démarre pas - "Failed to obtain JDBC connection"

**Cause** : L'utilisateur `keycloak` n'a pas les permissions sur la base `keycloak_db`.

**Solution** :
```powershell
# 1. Exécuter le script de vérification
.\verify-db.ps1

# 2. Se connecter à Cloud SQL
gcloud sql connect sahabi-postgres --user=postgres

# 3. Donner les permissions (voir Étape 4 ci-dessus)
```

### Problème : "STARTUP TCP probe failed"

**Cause** : Keycloak prend trop de temps à démarrer.

**Solution** : Les sondes sont déjà configurées dans `main.tf` avec 3 minutes de timeout. Si ça persiste :

```hcl
# Dans main.tf, augmenter failure_threshold
failure_threshold = 24  # Au lieu de 18
```

Puis :
```bash
terraform apply
```

### Problème : "Image not found"

**Cause** : Les images Docker n'ont pas été pushées vers Artifact Registry.

**Solution** :
```powershell
# Re-build et push
.\push-images.ps1

# Vérifier que les images existent
gcloud artifacts docker images list europe-west1-docker.pkg.dev/sahabiguide-478323/sahabi-registry
```

### Problème : "Error 403: Forbidden"

**Cause** : Permissions insuffisantes dans Google Cloud.

**Solution** :
```bash
# Vérifier le compte actif
gcloud auth list

# Se reconnecter
gcloud auth login

# Vérifier les rôles
gcloud projects get-iam-policy sahabiguide-478323 \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:VOTRE_EMAIL"
```

Rôles requis :
- `roles/owner` OU
- `roles/editor` + `roles/iam.serviceAccountAdmin`

### Problème : "Out of Memory" (OOM)

**Cause** : Pas assez de RAM allouée.

**Solution** : Augmenter la mémoire dans `main.tf` :
```hcl
# Pour Keycloak
memory = "3Gi"  # Au lieu de 2Gi

# Pour Backend
memory = "1Gi"  # Au lieu de 768Mi
```

Puis :
```bash
terraform apply
```

### Problème : Cloud SQL ne se connecte pas

**Solutions** :
```bash
# 1. Vérifier que l'instance est UP
gcloud sql instances describe sahabi-postgres

# 2. Vérifier l'IP publique
gcloud sql instances describe sahabi-postgres \
  --format="value(ipAddresses[0].ipAddress)"

# 3. Vérifier les IPs autorisées
gcloud sql instances describe sahabi-postgres \
  --format="value(settings.ipConfiguration.authorizedNetworks)"

# 4. Tester la connexion manuellement
gcloud sql connect sahabi-postgres --user=keycloak --database=keycloak_db
```

---

## 📁 Structure du Projet

```
terraform/
├── provider.tf              # Configuration GCP
├── variables.tf             # Variables d'entrée
├── main.tf                  # Ressources principales (535 lignes)
├── outputs.tf               # Outputs après déploiement
├── terraform.tfvars         # Vos valeurs (NE PAS COMMITER)
├── terraform.tfvars.example # Exemple de configuration
├── push-images.ps1          # Script build/push Windows
├── push-images.sh           # Script build/push Linux
├── verify-db.ps1            # Script vérification DB
├── init-keycloak-db.sql     # Script init permissions
├── DEPLOYER.ps1             # Déploiement automatisé complet
├── FIX_KEYCLOAK_STARTUP.md  # Guide correction Keycloak
└── README.md                # Ce fichier
```

---

## 🔐 Sécurité

### Bonnes Pratiques

1. **Ne JAMAIS commiter `terraform.tfvars`** :
   ```bash
   # Vérifier .gitignore
   cat ../.gitignore | grep tfvars
   ```

2. **Utiliser des mots de passe forts** :
   - Minimum 16 caractères
   - Mélange de majuscules, minuscules, chiffres, symboles
   - Générateur : `openssl rand -base64 32`

3. **Restreindre les IPs autorisées** (Production) :
   ```hcl
   # Dans main.tf
   authorized_networks {
     name  = "office"
     value = "VOTRE_IP/32"
   }
   ```

4. **Activer SSL/TLS** :
   - Utiliser un Load Balancer avec certificat SSL
   - Forcer HTTPS

5. **Backup régulier** :
   ```bash
   # Cloud SQL fait des backups automatiques (03:00)
   # Vérifier :
   gcloud sql backups list --instance=sahabi-postgres
   ```

---

## 📚 Ressources

### Documentation

- **Terraform Google Provider** : https://registry.terraform.io/providers/hashicorp/google/latest/docs
- **Cloud Run** : https://cloud.google.com/run/docs
- **Cloud SQL** : https://cloud.google.com/sql/docs
- **Keycloak** : https://www.keycloak.org/documentation

### Guides du Projet

- `../DEPLOIEMENT_GOOGLE_CLOUD.md` - Vue d'ensemble
- `FIX_KEYCLOAK_STARTUP.md` - Résolution problèmes Keycloak
- `../sahabi-guide-keycloak/CLOUD_RUN_DEPLOY.md` - Déploiement manuel Keycloak
- `../sahabi-guide-api/CLOUD_RUN_DEPLOY.md` - Déploiement manuel Backend

---

## 💡 Astuces

### Réduire les Coûts

```hcl
# Dans main.tf

# Keycloak : Scale to zero (démarrage à froid ~2-3 min)
min_instance_count = 0

# Backend : Scale to zero si peu utilisé
min_instance_count = 0

# Cloud SQL : Utiliser une instance plus petite en dev
tier = "db-f1-micro"  # Déjà configuré
```

### Activer les Logs Détaillés

```hcl
# Dans main.tf, pour Keycloak
env {
  name  = "KC_LOG_LEVEL"
  value = "DEBUG"  # Au lieu de INFO
}
```

### Export de la Configuration Keycloak

```bash
# Exporter le realm après modifications
curl -H "Authorization: Bearer $TOKEN" \
  "$KEYCLOAK_URL/admin/realms/sahabi" > sahabi-realm-backup.json
```

---

## 🎯 Checklist de Déploiement

- [ ] Prérequis installés (gcloud, terraform, docker)
- [ ] Authentifié à Google Cloud (`gcloud auth login`)
- [ ] Fichier `terraform.tfvars` créé avec secrets
- [ ] Images Docker buildées et pushées
- [ ] `terraform init` exécuté
- [ ] `terraform plan` vérifié
- [ ] `terraform apply` réussi
- [ ] Base de données vérifiée (`verify-db.ps1`)
- [ ] Permissions SQL accordées si nécessaire
- [ ] Services Cloud Run UP et READY
- [ ] URLs récupérées (`terraform output`)
- [ ] Keycloak accessible et realm importé
- [ ] Clients Keycloak configurés (Redirect URIs)
- [ ] Backend API répond (`/actuator/health`)
- [ ] Frontend accessible

---

**Dernière mise à jour** : 16 novembre 2025  
**Version Terraform** : 1.0+  
**Version Google Provider** : 5.x+

🎉 **Votre infrastructure est maintenant déployée sur Google Cloud !**
