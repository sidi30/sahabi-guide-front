# Déploiement sur Google Cloud Run avec Terraform

## ✅ Configuration Complète

Votre projet est **100% prêt** pour le déploiement sur Google Cloud Run avec Terraform.

### Ce qui a été configuré

**Infrastructure as Code (Terraform)** :
- ✅ Cloud SQL PostgreSQL (2 bases de données)
- ✅ Keycloak (authentification OAuth2/OIDC)
- ✅ Backend API Spring Boot
- ✅ Dashboard React
- ✅ Artifact Registry (images Docker)
- ✅ Secret Manager (mots de passe sécurisés)
- ✅ IAM et permissions automatiques

**Dockerfiles optimisés** :
- ✅ `sahabi-guide-api/Dockerfile` - Backend Spring Boot
- ✅ `sahabi-guide-dashboard/Dockerfile` - Frontend React + Nginx
- ✅ `sahabi-guide-keycloak/Dockerfile` - Keycloak avec realm

**Scripts automatisés** :
- ✅ `terraform/DEPLOYER.ps1` - Déploiement complet guidé
- ✅ `terraform/push-images.ps1` - Build et push des images
- ✅ `terraform/build-frontend.ps1` - Build frontend avec URLs

**Secrets générés** :
- ✅ Mot de passe base de données
- ✅ Mot de passe admin Keycloak
- ✅ Secret JWT (64 caractères)

## 🚀 Déploiement en 3 Étapes

### 1. Installer Terraform

**Windows (PowerShell en Administrateur)** :
```powershell
# Option A : Avec Chocolatey
choco install terraform

# Option B : Avec Scoop
scoop install terraform

# Vérifier l'installation
terraform --version
```

**Linux/macOS** :
```bash
# Ubuntu/Debian
sudo apt-get install terraform

# macOS
brew install terraform
```

### 2. Déployer

```powershell
cd terraform
.\DEPLOYER.ps1
```

Le script va automatiquement :
1. ✅ Vérifier les prérequis (Terraform, Docker, gcloud)
2. ✅ Build et push les images Docker
3. ✅ Initialiser Terraform
4. ✅ Montrer ce qui sera créé (plan)
5. ✅ Déployer toute l'infrastructure
6. ✅ Build le frontend avec les bonnes URLs
7. ✅ Afficher les URLs des services

### 3. Configurer Keycloak

Après le déploiement, configurez les redirections :

1. Accéder à l'Admin Console Keycloak
2. Realm `sahabi` → Clients → `sahabi-dashboard`
3. Ajouter les **Valid Redirect URIs** avec l'URL du frontend
4. Ajouter les **Web Origins** avec l'URL du frontend
5. Save

## 📊 Architecture Déployée

```
Google Cloud Run
├── Keycloak (2Gi RAM, 2 CPU, min 1 instance)
│   ├── Startup probe (3 min timeout)
│   ├── Liveness probe
│   └── Connexion Cloud SQL (keycloak_db)
├── Backend API (768Mi RAM, 2 CPU, min 1 instance)
│   └── Connexion Cloud SQL (sahabi_db)
└── Frontend (256Mi RAM, 1 CPU, min 0 instance)

Cloud SQL PostgreSQL
├── sahabi_db (application)
└── keycloak_db (auth)

Secret Manager
├── db-password
├── jwt-secret
└── keycloak-admin-password
```

## 💰 Coûts Estimés

| Service | Configuration | Coût/mois |
|---------|--------------|-----------|
| Cloud SQL | db-f1-micro | ~15-20 USD |
| Keycloak | 2Gi RAM, min 1 | ~40-50 USD |
| Backend | 768Mi RAM, min 1 | ~25-35 USD |
| Frontend | 256Mi RAM, min 0 | ~10-15 USD |
| Registry + Secrets | - | ~5 USD |
| **TOTAL** | | **~95-125 USD** |

> 💡 **Note** : Keycloak nécessite 2Gi RAM pour un démarrage fiable. Pour réduire les coûts, vous pouvez :
> - Réduire à `min_instance_count = 0` pour Keycloak (mais temps de démarrage à froid ~2-3 min)
> - Utiliser une instance Cloud SQL plus petite en dev

## 🔧 Commandes Utiles

```bash
# Voir l'état de l'infrastructure
terraform show

# Récupérer les URLs
terraform output

# Voir les logs d'un service
gcloud run services logs read sahabi-backend --region=europe-west1

# Se connecter à la base de données
gcloud sql connect sahabi-postgres --user=sahabi

# Mettre à jour seulement un service
terraform apply -target=google_cloud_run_v2_service.backend

# Détruire toute l'infrastructure
terraform destroy
```

## 🐛 Dépannage

### Erreur : "STARTUP TCP probe failed" pour Keycloak

Si vous rencontrez cette erreur :
```
Default STARTUP TCP probe failed 1 time consecutively for container "keycloak-1" on port 8080
```

**Solution** : Les corrections ont été appliquées dans `main.tf`. Consultez le guide détaillé :
- 📖 **Guide complet de résolution** : `terraform/FIX_KEYCLOAK_STARTUP.md`

**Résumé des corrections** :
- ✅ Ajout de sondes de démarrage (3 min timeout)
- ✅ Augmentation mémoire (2Gi)
- ✅ Ajout variable `KEYCLOAK_ADMIN`
- ✅ Optimisations Java pour conteneurs
- ✅ Configuration simplifiée de la DB

Pour redéployer avec les corrections :
```powershell
cd terraform
terraform apply
```

### Autres Problèmes Courants

**Service ne démarre pas** :
```powershell
# Consulter les logs
gcloud run services logs read <service-name> --region=europe-west1 --limit=100
```

**Erreur de connexion DB** :
```powershell
# Vérifier Cloud SQL
gcloud sql instances describe sahabi-postgres
```

**Out of Memory** :
- Augmenter la mémoire dans `main.tf`
- Redéployer avec `terraform apply`

## 📚 Documentation

- **Guide complet** : `terraform/README.md`
- **Résumé détaillé** : `TERRAFORM_DEPLOIEMENT.txt`
- **Fichier de configuration** : `terraform/main.tf` (485 lignes)
- **Fix Keycloak startup** : `terraform/FIX_KEYCLOAK_STARTUP.md`

## ❓ Pourquoi Terraform ?

### Avantages
✅ **Infrastructure as Code** : Toute l'infra est versionnée  
✅ **Reproductible** : Recréer l'infra en une commande  
✅ **Automatisé** : Plus d'erreurs manuelles  
✅ **État partagé** : Collaboration facilitée  
✅ **Rollback facile** : Retour arrière si problème  

### Alternative : Déploiement Manuel
Si vous ne voulez pas utiliser Terraform, vous pouvez déployer manuellement :
- Guides individuels dans chaque projet (`CLOUD_RUN_DEPLOY.md`)
- Scripts bash/PowerShell dans `scripts/deployment/`

Mais Terraform est **fortement recommandé** pour la production !

## 🎉 C'est Tout !

Votre infrastructure complète peut être déployée en **10-15 minutes** avec une seule commande :

```powershell
cd terraform
.\DEPLOYER.ps1
```

Le script est **interactif** et vous guide à chaque étape.

---

**Questions ?** Consultez `terraform/README.md` ou les logs de déploiement.

