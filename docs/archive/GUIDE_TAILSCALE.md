# 🔒 Guide Tailscale - Accès Internet sans Port Forwarding

## 📖 Table des matières

- [Qu'est-ce que Tailscale ?](#quest-ce-que-tailscale)
- [Pourquoi l'utiliser ?](#pourquoi-lutiliser)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Dépannage](#dépannage)

---

## 🤔 Qu'est-ce que Tailscale ?

**Tailscale** est un VPN moderne basé sur **WireGuard** qui crée un réseau privé sécurisé entre vos appareils, **sans avoir à configurer votre routeur** ou ouvrir des ports.

### Caractéristiques

- ✅ **Zéro configuration réseau** : Pas besoin de toucher au routeur
- ✅ **Chiffrement bout-en-bout** : WireGuard (performances maximales)
- ✅ **NAT traversal** : Fonctionne derrière n'importe quel pare-feu
- ✅ **Cross-platform** : Windows, Mac, Linux, iOS, Android
- ✅ **MagicDNS** : Noms de domaine automatiques
- ✅ **Gratuit** : Jusqu'à 100 appareils

---

## 💡 Pourquoi l'utiliser ?

### Problème classique

Sans Tailscale, pour accéder à votre application depuis Internet :

```
Internet → Routeur (port forwarding) → Firewall → Application
```

**Problèmes** :
- ❌ Configuration complexe du routeur
- ❌ Exposition publique (risques de sécurité)
- ❌ IP dynamique à gérer
- ❌ Certificats SSL compliqués

### Solution Tailscale

Avec Tailscale :

```
Internet → Tailscale (réseau privé chiffré) → Application
```

**Avantages** :
- ✅ Aucune configuration réseau
- ✅ Chiffrement automatique
- ✅ Fonctionne partout
- ✅ SSL inclus (avec certificats Tailscale)

---

## 🚀 Installation

### 1. Créer un compte Tailscale

1. Allez sur https://tailscale.com
2. Cliquez sur **Get Started**
3. Connectez-vous avec :
   - Google
   - Microsoft
   - GitHub
   - Apple
   - Ou email

### 2. Installer Tailscale sur votre serveur

#### Linux (Debian/Ubuntu)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

#### Linux (Manuel via Docker)

C'est déjà inclus dans le `docker-compose.full.yml` ! Pas besoin d'installer sur l'hôte.

#### Windows

1. Téléchargez : https://tailscale.com/download/windows
2. Installez l'exécutable
3. Lancez Tailscale

#### Mac

```bash
brew install tailscale
```

Ou téléchargez : https://tailscale.com/download/mac

---

## ⚙️ Configuration

### Étape 1 : Générer une Auth Key

1. Allez sur https://login.tailscale.com/admin/settings/keys

2. Cliquez sur **Generate auth key**

3. Configurez :
   - ☑️ **Reusable** : Permet de réutiliser la clé
   - ☑️ **Ephemeral** : (Optionnel) Le nœud disparaît quand il se déconnecte
   - ☑️ **Preauthorized** : (Recommandé) Approuve automatiquement
   - **Tags** : `tag:sahabi` (optionnel, pour organiser)

4. Copiez la clé générée (format : `tskey-auth-XXXXXX-XXXXXXXXXXXXXXXXX`)

### Étape 2 : Configurer le fichier .env

Éditez votre fichier `.env` :

```env
# Tailscale
TAILSCALE_AUTHKEY=tskey-auth-VOTRE_CLE_ICI
TAILSCALE_HOSTNAME=sahabi-guide
TAILSCALE_EXTRA_ARGS=--advertise-tags=tag:sahabi
```

### Étape 3 : Démarrer Tailscale

```bash
# Avec Docker Compose
docker-compose -f docker-compose.full.yml up -d tailscale

# Avec Make
make start
```

### Étape 4 : Vérifier la connexion

```bash
# Voir les logs
docker-compose -f docker-compose.full.yml logs -f tailscale

# Vous devriez voir :
# ✓ "Logged in as votre-email@example.com"
# ✓ "Connected to Tailscale"
```

---

## 🌐 Utilisation

### Accès depuis un autre appareil

#### 1. Installer Tailscale sur votre téléphone/ordinateur

- **iOS** : https://apps.apple.com/app/tailscale/id1470499037
- **Android** : https://play.google.com/store/apps/details?id=com.tailscale.ipn
- **Windows** : https://tailscale.com/download/windows
- **Mac** : https://tailscale.com/download/mac

#### 2. Se connecter avec le même compte

Ouvrez l'app Tailscale et connectez-vous avec le même compte que sur le serveur.

#### 3. Trouver l'IP de votre serveur

Sur votre serveur :

```bash
# Récupérer l'IP Tailscale du conteneur
docker exec sahabi-tailscale tailscale ip -4
```

**Exemple de sortie** : `100.64.1.5`

#### 4. Accéder à votre application

Dans votre navigateur (sur le téléphone/ordinateur distant) :

```
https://100.64.1.5
```

Ou avec l'API :

```
https://100.64.1.5:8084
```

### Utiliser MagicDNS (noms au lieu d'IPs)

#### 1. Activer MagicDNS

1. Allez sur https://login.tailscale.com/admin/dns
2. Activez **MagicDNS**

#### 2. Trouver le nom de votre machine

```bash
docker exec sahabi-tailscale tailscale status
```

**Exemple de sortie** :

```
100.64.1.5    sahabi-guide    votre-email@    linux   -
```

#### 3. Accéder avec le nom

Votre domaine Tailscale sera automatiquement :

```
https://sahabi-guide.your-tailnet.ts.net
```

Remplacez `your-tailnet` par votre nom Tailnet (visible dans le dashboard Tailscale).

---

## 🎯 Configuration avancée

### Exposer plusieurs services

Éditez `tailscale-serve.json` :

```json
{
  "TCP": {
    "443": {
      "HTTPS": true
    },
    "8084": {
      "HTTPS": false
    }
  },
  "Web": {
    "${TS_CERT_DOMAIN}:443": {
      "Handlers": {
        "/": {
          "Proxy": "http://caddy:443"
        },
        "/api": {
          "Proxy": "http://backend:8084"
        }
      }
    }
  }
}
```

### Utiliser les certificats Tailscale pour HTTPS

Tailscale fournit des certificats SSL automatiques pour vos machines !

#### 1. Activer HTTPS

```bash
docker exec sahabi-tailscale tailscale cert sahabi-guide.your-tailnet.ts.net
```

Cela génère :
- `sahabi-guide.your-tailnet.ts.net.crt`
- `sahabi-guide.your-tailnet.ts.net.key`

#### 2. Utiliser avec Caddy

Modifiez le `Caddyfile` pour utiliser ces certificats :

```caddyfile
sahabi-guide.your-tailnet.ts.net {
    tls /path/to/cert.crt /path/to/cert.key
    reverse_proxy frontend:80
}
```

---

## 🔐 Sécurité

### Access Control Lists (ACL)

Tailscale permet de définir qui peut accéder à quoi.

1. Allez sur https://login.tailscale.com/admin/acls

2. Exemple d'ACL :

```json
{
  "acls": [
    {
      "action": "accept",
      "users": ["votre-email@example.com"],
      "ports": [
        "sahabi-guide:80",
        "sahabi-guide:443",
        "sahabi-guide:8084"
      ]
    }
  ]
}
```

Cela autorise uniquement `votre-email@example.com` à accéder à votre serveur.

### Partager l'accès

Pour partager l'accès à votre application avec d'autres personnes :

#### Option 1 : Inviter dans votre Tailnet

1. Allez sur https://login.tailscale.com/admin/settings/users
2. Cliquez sur **Invite user**
3. Entrez l'email de la personne

#### Option 2 : Partage temporaire

```bash
docker exec sahabi-tailscale tailscale share 100.64.1.5
```

Cela génère un lien de partage temporaire.

---

## 🛠️ Dépannage

### Problème 1 : Conteneur Tailscale ne démarre pas

**Erreur** : `Auth key invalid or expired`

**Solution** :

1. Générez une nouvelle Auth Key sur https://login.tailscale.com/admin/settings/keys
2. Mettez à jour `.env` :

```env
TAILSCALE_AUTHKEY=tskey-auth-NOUVELLE_CLE
```

3. Redémarrez :

```bash
docker-compose -f docker-compose.full.yml restart tailscale
```

### Problème 2 : Impossible de se connecter depuis l'extérieur

**Vérifications** :

1. **Tailscale est-il connecté ?**

```bash
docker exec sahabi-tailscale tailscale status
```

Devrait afficher votre machine avec l'IP.

2. **Êtes-vous sur le même Tailnet ?**

Sur votre appareil distant, vérifiez que vous êtes connecté au même compte Tailscale.

3. **IP correcte ?**

```bash
docker exec sahabi-tailscale tailscale ip -4
```

Utilisez cette IP dans votre navigateur.

### Problème 3 : Certificats SSL non valides

Si vous utilisez MagicDNS et voyez une erreur SSL :

1. **Activez HTTPS dans Tailscale** :

```bash
docker exec sahabi-tailscale tailscale cert sahabi-guide
```

2. **Ou utilisez l'IP Tailscale** (sans HTTPS) :

```
http://100.64.1.5
```

### Problème 4 : Connexion lente

Tailscale utilise le NAT traversal pour des connexions directes. Si c'est lent :

1. **Vérifiez le relais DERP** :

```bash
docker exec sahabi-tailscale tailscale netcheck
```

2. **Activez UPnP sur votre routeur** (pour améliorer les connexions directes)

---

## 📊 Monitoring

### Voir l'état du réseau

```bash
# État des connexions
docker exec sahabi-tailscale tailscale status

# Qualité de la connexion
docker exec sahabi-tailscale tailscale netcheck

# Logs en temps réel
docker-compose -f docker-compose.full.yml logs -f tailscale
```

### Dashboard Tailscale

Le dashboard web : https://login.tailscale.com/admin/machines

Affiche :
- 📊 Liste des machines connectées
- 📈 Utilisation de la bande passante
- 🔒 Statut de sécurité
- 🌍 Localisation géographique

---

## 🎯 Cas d'usage

### 1. Développement distant

Travaillez sur votre projet depuis n'importe où :

```bash
# Sur votre serveur
docker-compose -f docker-compose.full.yml up -d

# Sur votre laptop (connecté à Tailscale)
curl http://sahabi-guide.your-tailnet.ts.net/api/health
```

### 2. Démo client

Partagez temporairement votre application :

```bash
docker exec sahabi-tailscale tailscale share sahabi-guide
```

Envoyez le lien au client → il peut accéder sans installer quoi que ce soit.

### 3. Équipe distante

Ajoutez tous les membres de l'équipe au Tailnet → accès instantané à l'application.

### 4. CI/CD

Utilisez Tailscale dans vos pipelines pour accéder à des environnements de staging privés.

---

## 💰 Tarification

| Plan | Prix | Machines | Utilisateurs | ACLs |
|------|------|----------|--------------|------|
| **Personal** | Gratuit | 100 | 1 | Non |
| **Premium** | $5/user/mois | Illimité | 3 | Oui |
| **Enterprise** | Contact | Illimité | Illimité | Oui |

Pour une utilisation personnelle ou une petite équipe, le plan **gratuit** est largement suffisant !

---

## 📚 Ressources

- **Documentation officielle** : https://tailscale.com/kb
- **Blog Tailscale** : https://tailscale.com/blog
- **Forum** : https://forum.tailscale.com
- **Status** : https://status.tailscale.com

---

## ✅ Récapitulatif

1. ✅ Créez un compte sur tailscale.com
2. ✅ Générez une Auth Key
3. ✅ Ajoutez la clé dans `.env`
4. ✅ Lancez `docker-compose up -d tailscale`
5. ✅ Installez Tailscale sur votre téléphone/ordinateur
6. ✅ Connectez-vous avec le même compte
7. ✅ Accédez à `https://sahabi-guide.your-tailnet.ts.net`

**Vous avez maintenant un accès Internet sécurisé à votre application, sans configuration réseau !** 🎉

---

## 🆘 Support

En cas de problème :

1. Consultez les logs : `docker-compose logs -f tailscale`
2. Vérifiez le statut : `docker exec sahabi-tailscale tailscale status`
3. Consultez le [dépannage](#dépannage)
4. Forum Tailscale : https://forum.tailscale.com

---

**Créé le** : 7 novembre 2025  
**Version** : 1.0  
**Projet** : Sahabi Guide

