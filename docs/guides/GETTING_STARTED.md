# 🚀 COMMENCER ICI - Démarrage Immédiat

## ⏱️ Temps estimé : 5 minutes

---

## 📋 Étape 1 : Vérifier Docker (30 secondes)

Ouvrez un terminal et vérifiez que Docker est installé :

```bash
docker --version
docker-compose --version
```

**Si Docker n'est pas installé** → https://docs.docker.com/get-docker/

---

## ⚙️ Étape 2 : Configuration (2 minutes)

### 2.1 Créer le fichier .env

```bash
# Copier le template
cp env.template .env
```

### 2.2 Éditer le fichier .env

**Linux/Mac :**
```bash
nano .env
```

**Windows :**
```powershell
notepad .env
```

### 2.3 Modifier AU MINIMUM ces lignes

```env
# ⚠️ IMPORTANT : Changez ces mots de passe !
POSTGRES_PASSWORD=VotrePasswordSecure123!
KEYCLOAK_ADMIN_PASSWORD=AdminPassword123!
JWT_SECRET=UneCleAleatoireTresLongueMinimum64Caracteres_ChangezMoi!

# Pour Tailscale (optionnel, pour accès Internet)
# Générez une clé sur : https://login.tailscale.com/admin/settings/keys
TAILSCALE_AUTHKEY=tskey-auth-XXXXXX
```

**Sauvegardez et fermez** (Ctrl+X puis Y pour nano, Ctrl+S pour notepad)

---

## 🚀 Étape 3 : Démarrage (2 minutes)

### Option A : Script interactif (Recommandé)

**Linux/Mac :**
```bash
chmod +x start.sh
./start.sh
```

**Windows PowerShell :**
```powershell
.\start.ps1
```

Sélectionnez l'option **2** (Démarrage progressif) pour la première fois.

### Option B : Make (Linux/Mac uniquement)

```bash
make start-progressive
```

### Option C : Docker Compose direct

```bash
docker-compose -f docker-compose.full.yml up -d
```

---

## ⏳ Étape 4 : Attendre (2-3 minutes)

Suivez les logs pour voir le démarrage :

```bash
docker-compose -f docker-compose.full.yml logs -f
```

**Appuyez sur Ctrl+C pour quitter les logs** (les services continuent de tourner)

---

## ✅ Étape 5 : Tester

Ouvrez votre navigateur :

### Frontend (Dashboard)
```
http://localhost:3000
```

### API (Swagger)
```
http://localhost:8084/swagger-ui.html
```

### Keycloak (Admin)
```
http://localhost:8080
Username: admin
Password: admin (ou celui que vous avez défini)
```

---

## 🎉 Félicitations !

Votre application est maintenant lancée avec :

✅ PostgreSQL (base de données)  
✅ Keycloak (authentification)  
✅ Backend Spring Boot (API)  
✅ Frontend React (Dashboard)  
✅ Caddy (reverse proxy + SSL)  
✅ Tailscale (accès Internet - si configuré)  

---

## 📚 Prochaines étapes

### Mode Local (développement)

Vous êtes prêt ! Utilisez :
- Frontend : http://localhost:3000
- API : http://localhost:8084

### Mode Production (avec domaine)

1. **Configurez vos DNS** :
   ```
   A     @        → IP_de_votre_serveur
   A     api      → IP_de_votre_serveur
   A     auth     → IP_de_votre_serveur
   ```

2. **Modifiez .env** :
   ```env
   DOMAIN=votre-domaine.com
   ACME_EMAIL=votre-email@example.com
   ```

3. **Relancez** :
   ```bash
   docker-compose -f docker-compose.full.yml restart caddy
   ```

4. **Accédez en HTTPS** :
   ```
   https://votre-domaine.com
   https://api.votre-domaine.com
   https://auth.votre-domaine.com
   ```

### Configurer Tailscale (accès Internet sans port forwarding)

Consultez : [GUIDE_TAILSCALE.md](./GUIDE_TAILSCALE.md)

---

## 🛠️ Commandes utiles

```bash
# Voir les logs
docker-compose -f docker-compose.full.yml logs -f

# Arrêter
docker-compose -f docker-compose.full.yml down

# Redémarrer
docker-compose -f docker-compose.full.yml restart

# État des services
docker-compose -f docker-compose.full.yml ps

# Redémarrer un service spécifique
docker-compose -f docker-compose.full.yml restart backend
```

**Avec Make (Linux/Mac) :**
```bash
make help          # Voir toutes les commandes
make logs          # Voir les logs
make stop          # Arrêter
make restart       # Redémarrer
make status        # État
```

---

## 🆘 Problèmes ?

### Le backend ne démarre pas

```bash
# Vérifier postgres
docker-compose -f docker-compose.full.yml logs postgres

# Redémarrer backend
docker-compose -f docker-compose.full.yml restart backend
```

### Port déjà utilisé

Modifiez les ports dans `.env` :

```env
FRONTEND_PORT=3001
BACKEND_PORT=8085
KEYCLOAK_PORT=8081
```

### Plus de détails

Consultez :
- [QUICKSTART.md](./QUICKSTART.md) - Guide rapide
- [README_DOCKER_ORCHESTRATION.md](./README_DOCKER_ORCHESTRATION.md) - Documentation complète
- [RESUME_ORCHESTRATION.md](./RESUME_ORCHESTRATION.md) - Récapitulatif

---

## 📊 Récapitulatif rapide

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | - |
| **API** | http://localhost:8084 | - |
| **Swagger** | http://localhost:8084/swagger-ui.html | - |
| **Keycloak** | http://localhost:8080 | admin / admin |
| **PgAdmin** | http://localhost:5050 | admin@sahabi.local / admin |
| **PostgreSQL** | localhost:5432 | sahabi / sahabi |

---

## 🎯 Vous avez terminé !

Votre infrastructure est opérationnelle. **Bon développement !** 🚀

Pour toute question, consultez la documentation ou les fichiers de support fournis.

---

**Créé le** : 7 novembre 2025  
**Projet** : Sahabi Guide  
**Stack** : PostgreSQL + Keycloak + Spring Boot + React + Caddy + Tailscale

