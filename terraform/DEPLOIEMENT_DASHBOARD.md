# 🚀 Déploiement Dashboard React en Production

## ✅ Configuration Prête

### URLs de Production Configurées

- **Backend API** : `https://sahabi-backend-520537349678.europe-west1.run.app`
- **Keycloak** : `https://sahabi-keycloak-520537349678.europe-west1.run.app`
- **Dashboard** : `https://sahabi-dashboard-520537349678.europe-west1.run.app` (après déploiement)

---

## 📋 Checklist Pré-Déploiement

### ✅ Vérifications Effectuées

- [x] Service `sahabi-dashboard` configuré dans Terraform
- [x] URLs backend et Keycloak mises à jour
- [x] Health checks configurés (`/health`)
- [x] IAM public configuré (`allUsers` peut accéder)
- [x] Script de build Cloud Build créé
- [x] Image Docker configurée : `dashboard:latest`

---

## 🚀 Étapes de Déploiement

### **Étape 1 : Build l'image Docker du Dashboard**

```powershell
cd C:\Users\ramzi\Desktop\devs\sahabiGuide\terraform

# Build avec Cloud Build (recommandé)
.\build-dashboard.ps1

# Ou avec Mapbox token (optionnel)
.\build-dashboard.ps1 -MapboxToken "pk.eyJ1Ijoi..."
```

**Ce que fait le script :**
- Build l'image avec les URLs de production
- Injecte `VITE_API_BASE_URL` = URL backend
- Injecte `VITE_KEYCLOAK_URL` = URL Keycloak
- Push automatiquement vers Artifact Registry

---

### **Étape 2 : Déployer avec Terraform**

```powershell
cd C:\Users\ramzi\Desktop\devs\sahabiGuide\terraform

# Déployer uniquement le dashboard
terraform apply -target=google_cloud_run_v2_service.dashboard

# Ou déployer tout
terraform apply
```

---

### **Étape 3 : Vérifier le Déploiement**

```powershell
# Vérifier les logs
gcloud run services logs read sahabi-dashboard --region=europe-west1 --limit=30

# Vérifier l'URL
gcloud run services describe sahabi-dashboard --region=europe-west1 --format="value(status.url)"

# Health check
Invoke-WebRequest -Uri "https://sahabi-dashboard-520537349678.europe-west1.run.app/health"
```

**Attendu :**
- ✅ Status Code : 200
- ✅ Response : "healthy"

---

## 🔧 Configuration Technique

### Variables d'Environnement Injectées au Build

| Variable | Valeur | Description |
|----------|--------|-------------|
| `VITE_API_BASE_URL` | `https://sahabi-backend-520537349678.europe-west1.run.app` | URL du backend API |
| `VITE_API_BASE_PATH` | `/api/v1` | Chemin de base de l'API |
| `VITE_KEYCLOAK_URL` | `https://sahabi-keycloak-520537349678.europe-west1.run.app` | URL de Keycloak |
| `VITE_KEYCLOAK_REALM` | `sahabi` | Realm Keycloak |
| `VITE_KEYCLOAK_CLIENT_ID` | `sahabi-dashboard` | Client ID Keycloak |
| `VITE_ENABLE_KEYCLOAK` | `true` | Activation Keycloak |
| `VITE_MAPBOX_ACCESS_TOKEN` | (optionnel) | Token Mapbox pour les cartes |

---

## 🎯 Ressources Cloud Run

### Dashboard

- **Nom** : `sahabi-dashboard`
- **Image** : `europe-west1-docker.pkg.dev/sahabiguide-478323/sahabi-registry/dashboard:latest`
- **CPU** : 1
- **Mémoire** : 512Mi
- **Min instances** : 0 (scale-to-zero)
- **Max instances** : 10
- **Health check** : `/health`

---

## 🔐 Sécurité

### IAM

- ✅ **Public** : `allUsers` peut accéder (nécessaire pour le dashboard web)
- ✅ **Keycloak** : Authentification requise pour les endpoints protégés

### Headers de Sécurité

Le dashboard inclut automatiquement :
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`

---

## 🐛 Dépannage

### Erreur : "Image not found"

```powershell
# Vérifier que l'image existe
gcloud artifacts docker images list europe-west1-docker.pkg.dev/sahabiguide-478323/sahabi-registry/dashboard

# Si vide, rebuilder
.\build-dashboard.ps1
```

### Erreur : "Health check failed"

```powershell
# Vérifier les logs
gcloud run services logs read sahabi-dashboard --region=europe-west1 --limit=50

# Vérifier que le endpoint /health répond
Invoke-WebRequest -Uri "https://sahabi-dashboard-520537349678.europe-west1.run.app/health"
```

### Erreur : "Keycloak connection failed"

Vérifier que :
1. Keycloak est démarré : `https://sahabi-keycloak-520537349678.europe-west1.run.app`
2. Le realm `sahabi` existe
3. Le client `sahabi-dashboard` existe dans Keycloak

---

## 📝 Notes Importantes

1. **Build Time vs Runtime** : Les variables `VITE_*` sont injectées au **build time**, pas au runtime. Il faut rebuilder l'image si les URLs changent.

2. **Mapbox Token** : Optionnel. Si non fourni, les cartes avancées seront désactivées, mais le dashboard fonctionnera.

3. **Keycloak Client** : Assure-toi que le client `sahabi-dashboard` existe dans Keycloak avec les bonnes configurations (redirect URIs, etc.).

---

## ✅ Résumé

| Étape | Commande | Status |
|-------|----------|--------|
| Build image | `.\build-dashboard.ps1` | ⏳ À faire |
| Déployer | `terraform apply -target=google_cloud_run_v2_service.dashboard` | ⏳ À faire |
| Vérifier | `gcloud run services describe sahabi-dashboard` | ⏳ À faire |

---

**Une fois déployé, le dashboard sera accessible à :**
`https://sahabi-dashboard-520537349678.europe-west1.run.app` 🎉

