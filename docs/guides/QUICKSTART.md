# 🚀 Quick Start - Sahabi Guide

## Installation rapide (5 minutes)

### 1. Prérequis

```bash
# Vérifiez que Docker est installé
docker --version
docker-compose --version
```

Si Docker n'est pas installé : https://docs.docker.com/get-docker/

### 2. Configuration

```bash
# Créez le fichier .env
cp env.template .env

# Éditez les variables d'environnement
nano .env  # Linux/Mac
notepad .env  # Windows
```

**Minimum requis** : Changez les mots de passe !

```env
POSTGRES_PASSWORD=votre_password
KEYCLOAK_ADMIN_PASSWORD=votre_password_admin
JWT_SECRET=une_cle_tres_longue_et_aleatoire_minimum_64_caracteres
```

### 3. Démarrage

#### Linux/Mac

```bash
# Rendre les scripts exécutables
chmod +x start.sh stop.sh logs.sh backup-db.sh restore-db.sh

# Démarrer
./start.sh
```

#### Windows (PowerShell)

```powershell
# Démarrer
.\start.ps1
```

#### Manuel

```bash
docker-compose -f docker-compose.full.yml up -d
```

### 4. Accès

Attendez 2-3 minutes que tous les services démarrent, puis :

- **Frontend** : http://localhost:3000
- **API** : http://localhost:8084
- **Keycloak** : http://localhost:8080

### 5. Identifiants par défaut

**Keycloak** :
- Username : `admin`
- Password : `admin`

**PgAdmin** :
- Email : `admin@sahabi.local`
- Password : `admin`

---

## Commandes utiles

```bash
# Voir les logs
docker-compose -f docker-compose.full.yml logs -f

# Arrêter
docker-compose -f docker-compose.full.yml down

# Redémarrer un service
docker-compose -f docker-compose.full.yml restart backend

# Voir l'état
docker-compose -f docker-compose.full.yml ps
```

---

## Problèmes courants

### Le backend ne démarre pas

```bash
# Vérifier que postgres est prêt
docker-compose -f docker-compose.full.yml logs postgres

# Redémarrer le backend
docker-compose -f docker-compose.full.yml restart backend
```

### Port déjà utilisé

Modifiez les ports dans `.env` :

```env
FRONTEND_PORT=3001
BACKEND_PORT=8085
KEYCLOAK_PORT=8081
```

---

## Documentation complète

Pour plus de détails : [README_DOCKER_ORCHESTRATION.md](./README_DOCKER_ORCHESTRATION.md)

## Support

- Logs : `docker-compose -f docker-compose.full.yml logs -f <service>`
- État : `docker-compose -f docker-compose.full.yml ps`
- Shell : `docker exec -it sahabi-backend sh`

