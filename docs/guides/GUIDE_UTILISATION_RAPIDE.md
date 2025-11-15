# 🚀 Guide d'Utilisation Rapide - Sahabi Guide

**Pour Windows** - Guide simplifié de la nouvelle structure

---

## 🎯 Que voulez-vous faire ?

Cliquez sur votre besoin :

- [Je veux démarrer le projet](#-démarrer-le-projet)
- [Je veux l'exposer sur Internet](#-exposer-sur-internet)
- [Je veux sauvegarder la base](#-sauvegarder-la-base)
- [Je veux voir les logs](#-voir-les-logs)
- [Je veux arrêter tout](#-arrêter-tout)

---

## 🟢 Démarrer le projet

### Commande simple

```powershell
.\scripts\docker\start.ps1
```

### Ce que ça fait

- ✅ Démarre PostgreSQL
- ✅ Démarre Keycloak
- ✅ Démarre le Backend API
- ✅ Démarre le Frontend Dashboard

### Accès après démarrage

| Service | URL | Login |
|---------|-----|-------|
| 🎨 Dashboard | http://localhost:3000 | admin / admin123 |
| 🔐 Keycloak | http://localhost:8080 | admin / admin |
| 🔧 API | http://localhost:8084 | - |

---

## 🌐 Exposer sur Internet

### Avec Tailscale (Recommandé - Gratuit)

#### Étape 1 : Obtenir une clé Tailscale

1. Allez sur https://login.tailscale.com/start
2. Créez un compte (gratuit)
3. Allez sur https://login.tailscale.com/admin/settings/keys
4. Cliquez "Generate auth key"
5. Cochez "Reusable"
6. Copiez la clé (commence par `tskey-auth-...`)

#### Étape 2 : Déployer

```powershell
.\scripts\deployment\deploy-internet.ps1 -Mode tailscale -TailscaleKey "tskey-auth-VOTRE_CLE_ICI"
```

#### Étape 3 : Configurer Serve

```powershell
# Nouvelle syntaxe Tailscale
docker exec sahabi-tailscale tailscale serve --bg http://frontend:80

# Vérifier la configuration
docker exec sahabi-tailscale tailscale serve status
```

#### Étape 4 : Accéder

- Installez Tailscale sur votre téléphone
- Connectez-vous avec le même compte
- Accédez à `https://sahabi-guide`

### Avec votre propre domaine (Production)

```powershell
.\scripts\deployment\deploy-internet.ps1 -Mode caddy -Domain "monsite.com" -Email "email@example.com"
```

📖 **Plus de détails** : [docs/deployment/INTERNET_ACCESS.md](docs/deployment/INTERNET_ACCESS.md)

---

## 💾 Sauvegarder la base

### Créer une sauvegarde

```powershell
# Ouvrir Git Bash ou WSL
./scripts/database/backup.sh
```

Crée un fichier `backup_YYYYMMDD_HHMMSS.sql`

### Restaurer une sauvegarde

```powershell
# Ouvrir Git Bash ou WSL
./scripts/database/restore.sh backup_20250108_120000.sql
```

⚠️ **Attention** : La restauration écrase toutes les données !

---

## 📋 Voir les logs

### Tous les services

```powershell
docker-compose logs -f
```

### Un service spécifique

```powershell
# Backend
docker-compose logs -f backend

# Frontend
docker-compose logs -f frontend

# Keycloak
docker-compose logs -f keycloak

# PostgreSQL
docker-compose logs -f postgres
```

### Arrêter les logs

Appuyez sur `Ctrl+C`

---

## 🛑 Arrêter tout

### Arrêt normal

```powershell
docker-compose down
```

### Arrêt + Suppression des données (⚠️ Perte de données)

```powershell
docker-compose down -v
```

---

## 🔧 Commandes Docker Utiles

### Voir l'état des services

```powershell
docker-compose ps
```

### Redémarrer un service

```powershell
docker-compose restart backend
docker-compose restart frontend
docker-compose restart keycloak
```

### Reconstruire un service

```powershell
docker-compose up -d --build backend
docker-compose up -d --build frontend
```

### Nettoyer Docker

```powershell
# Supprimer les images inutilisées
docker system prune -a

# Supprimer les volumes inutilisés
docker volume prune
```

---

## 📁 Où Trouver Quoi ?

### Scripts

```
scripts/
├── deployment/       # Pour l'accès Internet
│   ├── deploy-internet.ps1      [Déploiement complet]
│   ├── fix-tailscale.ps1        [Corriger Tailscale]
│   └── setup-tailscale-funnel.ps1 [Accès public]
├── docker/           # Pour Docker
│   ├── start.ps1                [Démarrer]
│   └── stop.sh                  [Arrêter]
└── database/         # Pour la base
    ├── backup.sh                [Sauvegarder]
    └── restore.sh               [Restaurer]
```

### Documentation

```
docs/
├── deployment/       # Guides de déploiement
│   ├── README.md                [Guide principal]
│   ├── INTERNET_ACCESS.md       [Accès Internet complet]
│   └── DOCKER_SETUP.md          [Config Docker]
└── guides/           # Guides utilisateur
    ├── QUICKSTART.md            [Démarrage rapide]
    └── GETTING_STARTED.md       [Guide complet]
```

### SQL

```
sql/
├── seed/             # Données de démarrage
├── utils/            # Utilitaires SQL
└── verification/     # Vérifications
```

### Configuration

```
config/
├── docker/           # Config Docker
│   ├── Caddyfile               [Reverse proxy]
│   └── tailscale-serve.json    [Config Tailscale]
└── postgres/         # Init PostgreSQL
    └── 01-init-keycloak-db.sh
```

---

## 🆘 Problèmes Courants

### "Port already in use"

Un service utilise déjà le port. Modifiez `.env` :

```env
POSTGRES_PORT=5433
KEYCLOAK_PORT=8081
BACKEND_PORT=8085
FRONTEND_PORT=3001
```

### "Cannot connect to Docker daemon"

Docker Desktop n'est pas démarré. Lancez Docker Desktop.

### "Permission denied" sur les scripts

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Services qui redémarrent en boucle

```powershell
# Voir les logs
docker-compose logs

# Recréer proprement
docker-compose down -v
docker-compose up -d
```

### Keycloak ne démarre pas

```powershell
# Supprimer et recréer
docker-compose down -v
docker-compose up -d
```

---

## 📖 Documentation Complète

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Guide principal du projet |
| [REORGANISATION_COMPLETE.md](REORGANISATION_COMPLETE.md) | Détails de la réorganisation |
| [docs/deployment/README.md](docs/deployment/README.md) | Guide de déploiement |
| [docs/deployment/INTERNET_ACCESS.md](docs/deployment/INTERNET_ACCESS.md) | Accès Internet (3 options) |
| [scripts/README.md](scripts/README.md) | Guide des scripts |

---

## ⚡ Workflow Typique

### 1️⃣ Développement Local

```powershell
# Démarrer
.\scripts\docker\start.ps1

# Coder...

# Voir les logs si besoin
docker-compose logs -f backend

# Arrêter
docker-compose down
```

### 2️⃣ Déploiement Test (Tailscale)

```powershell
# Déployer
.\scripts\deployment\deploy-internet.ps1 -Mode tailscale -TailscaleKey "tskey-..."

# Configurer Serve
docker exec -it sahabi-tailscale sh
tailscale serve https / http://frontend:80
exit

# Tester depuis votre téléphone
```

### 3️⃣ Production (Domaine)

```powershell
# Déployer
.\scripts\deployment\deploy-internet.ps1 -Mode caddy -Domain "monsite.com" -Email "email@example.com"

# Configurer Keycloak
# Éditer sahabi-guide-api/keycloak/import/sahabi-realm.json

# Redéployer
docker-compose --profile production up -d --build

# Sauvegarder régulièrement
./scripts/database/backup.sh
```

---

## ✅ Checklist de Démarrage

- [ ] Docker Desktop installé et démarré
- [ ] Fichier `.env` créé (copier de `env.template`)
- [ ] Ports 3000, 8080, 8084, 5432 libres
- [ ] Exécuter `.\scripts\docker\start.ps1`
- [ ] Attendre 2-3 minutes
- [ ] Tester http://localhost:3000
- [ ] Login avec admin / admin123

---

**Tout fonctionne ?** 🎉

Si vous avez des questions, consultez la [documentation complète](docs/) !

