# 🚀 Guide de Déploiement Internet - Sahabi Guide

Ce guide vous explique comment **rendre votre application accessible depuis Internet** en quelques minutes.

---

## 📋 3 Options Disponibles

| Option | Difficulté | Coût | Recommandé pour |
|--------|-----------|------|----------------|
| 🚀 **Tailscale** | 🟢 Facile | Gratuit | Tests, démos, développement |
| 🌐 **Caddy + Domaine** | 🟡 Moyen | ~10-20€/mois | Production |
| 🔓 **Direct** | 🟢 Facile | Gratuit | Tests locaux uniquement |

---

## ⚡ Démarrage Rapide (Tailscale - Recommandé)

### 1️⃣ Créer un compte Tailscale (gratuit)

Allez sur [https://login.tailscale.com/start](https://login.tailscale.com/start) et créez un compte.

### 2️⃣ Générer une clé d'authentification

1. Allez sur [https://login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys)
2. Cliquez sur **"Generate auth key"**
3. Cochez **"Reusable"**
4. Copiez la clé (commence par `tskey-auth-...`)

### 3️⃣ Déployer avec le script

**Sous Windows :**
```powershell
.\deploy-internet.ps1 -Mode tailscale -TailscaleKey "tskey-auth-VOTRE_CLE_ICI"
```

**Sous Linux/Mac :**
```bash
chmod +x deploy-internet.sh
./deploy-internet.sh tailscale --key "tskey-auth-VOTRE_CLE_ICI"
```

### 4️⃣ Activer Tailscale Serve

```bash
docker exec -it sahabi-tailscale sh
tailscale serve https / http://frontend:80
exit
```

### 5️⃣ Accéder à votre application

- Installez Tailscale sur votre téléphone/ordinateur
- Connectez-vous avec le même compte
- Accédez à : `https://sahabi-guide.VOTRE-TAILNET.ts.net`

**Pour un accès public (sans installation Tailscale) :**
```bash
docker exec -it sahabi-tailscale sh
tailscale funnel 443 on
exit
```

✅ **C'est tout ! Votre application est accessible depuis Internet.**

---

## 🌐 Déploiement Production (Caddy + Domaine)

### Prérequis

- Un nom de domaine (ex: `sahabi-guide.com`)
- Un serveur avec IP publique (VPS)

### 1️⃣ Configurer les DNS

Dans votre registrar de domaine, ajoutez ces enregistrements A :

| Name | Type | Value |
|------|------|-------|
| @ | A | VOTRE_IP_SERVEUR |
| api | A | VOTRE_IP_SERVEUR |
| auth | A | VOTRE_IP_SERVEUR |

### 2️⃣ Ouvrir les ports

**Sous Linux :**
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp
```

**Sous Windows :**
```powershell
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow
```

### 3️⃣ Déployer avec le script

**Sous Windows :**
```powershell
.\deploy-internet.ps1 -Mode caddy -Domain "sahabi-guide.com" -Email "admin@example.com"
```

**Sous Linux/Mac :**
```bash
./deploy-internet.sh caddy --domain "sahabi-guide.com" --email "admin@example.com"
```

### 4️⃣ Mettre à jour Keycloak Realm

Éditez `sahabi-guide-api/keycloak/import/sahabi-realm.json` et ajoutez vos URLs :

```json
{
  "clientId": "sahabi-dashboard",
  "redirectUris": [
    "https://sahabi-guide.com/*"
  ],
  "webOrigins": [
    "https://sahabi-guide.com"
  ]
}
```

### 5️⃣ Accéder à votre application

Votre application est maintenant accessible :

- 🎨 **Frontend** : https://sahabi-guide.com
- 🔧 **API** : https://api.sahabi-guide.com
- 🔐 **Keycloak** : https://auth.sahabi-guide.com

✅ **SSL automatique avec Let's Encrypt !**

---

## 🔓 Exposition Directe (Tests uniquement)

⚠️ **Non recommandé en production** (pas de SSL)

**Sous Windows :**
```powershell
.\deploy-internet.ps1 -Mode direct
```

**Sous Linux/Mac :**
```bash
./deploy-internet.sh direct
```

Votre application sera accessible via :
- Frontend : http://VOTRE_IP:3000
- API : http://VOTRE_IP:8084
- Keycloak : http://VOTRE_IP:8080

---

## 📚 Documentation Complète

Pour plus de détails, consultez :

- **[ACCES_INTERNET.md](ACCES_INTERNET.md)** - Guide complet avec toutes les options
- **[DEPLOIEMENT-DOCKER.md](DEPLOIEMENT-DOCKER.md)** - Guide de déploiement Docker

---

## 🛠️ Commandes Utiles

### Voir l'état des services
```bash
docker-compose ps
```

### Voir les logs
```bash
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f caddy
docker-compose logs -f tailscale
```

### Redémarrer un service
```bash
docker-compose restart backend
```

### Arrêter tous les services
```bash
docker-compose down
```

### Mettre à jour les images
```bash
docker-compose pull
docker-compose up -d --build
```

---

## 🔒 Sécurité

### Changer les mots de passe par défaut

Éditez `.env` et modifiez :

```env
POSTGRES_PASSWORD=UN_MOT_DE_PASSE_TRES_SECURISE
KEYCLOAK_ADMIN_PASSWORD=UN_AUTRE_MOT_DE_PASSE_SECURISE
JWT_SECRET=UNE_CLE_SECRETE_TRES_LONGUE_ET_ALEATOIRE
```

Puis recréez les conteneurs :

```bash
docker-compose down -v
docker-compose up -d
```

⚠️ **Attention** : `-v` supprime les volumes (toutes les données). Faites une sauvegarde avant !

### Sauvegarder la base de données

```bash
# Sauvegarde
./backup-db.sh

# Restauration
./restore-db.sh backup_YYYYMMDD_HHMMSS.sql
```

---

## 🆘 Dépannage

### Les services ne démarrent pas
```bash
docker-compose logs
docker-compose down
docker-compose up -d
```

### Erreur de connexion à la base de données
```bash
docker exec -it sahabi-postgres psql -U sahabi -d sahabi_db -c "\l"
docker-compose restart postgres
```

### Keycloak ne démarre pas
```bash
docker-compose down -v
docker-compose up -d
```

### Certificat SSL ne se génère pas (Caddy)
```bash
# Vérifier les DNS
nslookup sahabi-guide.com

# Vérifier les ports
telnet sahabi-guide.com 80
telnet sahabi-guide.com 443

# Voir les logs Caddy
docker-compose logs -f caddy
```

---

## 📊 Comparaison des Options

| Critère | Tailscale | Caddy + Domaine | Direct |
|---------|-----------|----------------|--------|
| Difficulté | 🟢 Facile | 🟡 Moyenne | 🟢 Facile |
| Coût | 🟢 Gratuit | 🟡 10-20€/mois | 🟢 Gratuit |
| Sécurité | 🟢 Excellente | 🟢 Excellente | 🔴 Faible |
| SSL | ✅ Auto | ✅ Auto | ❌ Non |
| Domaine | ❌ Non | ✅ Oui | ❌ Non |
| Production | ⚠️ Limité | ✅ Oui | ❌ Non |

---

## ✅ Checklist de Déploiement

- [ ] Choisir une option (Tailscale, Caddy, ou Direct)
- [ ] Créer le fichier `.env` (copier de `env.template`)
- [ ] Configurer les variables d'environnement
- [ ] Exécuter le script de déploiement
- [ ] Vérifier les logs (`docker-compose logs`)
- [ ] Tester l'accès depuis Internet
- [ ] Changer les mots de passe par défaut
- [ ] Configurer les sauvegardes automatiques

---

## 🎯 Recommandations

1. **Pour commencer rapidement** → **Tailscale** (5 minutes)
2. **Pour la production** → **Caddy + Domaine** (30 minutes)
3. **Pour des tests locaux** → **Direct** (10 minutes)

---

## 📞 Support

- Consultez la documentation complète : [ACCES_INTERNET.md](ACCES_INTERNET.md)
- Vérifiez les logs : `docker-compose logs`
- Issues GitHub : [Créer une issue](https://github.com/votre-repo/issues)

---

**Version** : 1.0  
**Dernière mise à jour** : 2025-11-08

**Bon déploiement ! 🚀**

