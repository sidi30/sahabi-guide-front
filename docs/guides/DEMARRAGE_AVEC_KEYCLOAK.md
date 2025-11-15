# 🔐 Guide : Démarrage avec Keycloak

## 🎯 Objectif

Ce guide explique comment démarrer le projet **SahabiGuide** avec Keycloak **obligatoirement activé**, pour éviter de travailler en mode TEST non sécurisé.

## ❓ Pourquoi ce guide ?

Par défaut, le projet peut fonctionner en **mode TEST** sans Keycloak, ce qui est pratique pour le développement rapide mais **dangereux** et **ne reflète pas l'environnement de production**.

### Problème identifié

- **Dashboard** : Par défaut, `VITE_ENABLE_KEYCLOAK` n'est pas défini → Mode TEST activé
- **Backend** : Par défaut, `APP_SECURITY_ENABLED=true` mais peut être désactivé
- **Résultat** : Le système peut fonctionner sans authentification réelle

Pour plus de détails, consultez : [`ANALYSE_CONNEXION_SANS_KEYCLOAK.md`](../../ANALYSE_CONNEXION_SANS_KEYCLOAK.md)

---

## 🚀 Méthode 1 : Script automatique (RECOMMANDÉ)

### Windows (PowerShell)

```powershell
# Depuis la racine du projet
.\scripts\start-with-keycloak.ps1
```

### Linux / macOS (Bash)

```bash
# Rendre le script exécutable (première fois)
chmod +x scripts/start-with-keycloak.sh

# Exécuter le script
./scripts/start-with-keycloak.sh
```

### Fonctionnalités du script

Le script automatique :
- ✅ Vérifie la présence de Docker
- ✅ Crée le fichier `.env` depuis le template si nécessaire
- ✅ Force `VITE_ENABLE_KEYCLOAK=true` et `APP_SECURITY_ENABLED=true`
- ✅ Démarre PostgreSQL et Keycloak avec Docker Compose
- ✅ Attend que Keycloak soit prêt (jusqu'à 2 minutes)
- ✅ Propose plusieurs options de démarrage

---

## 🛠️ Méthode 2 : Démarrage manuel

### Étape 1 : Créer le fichier `.env`

```powershell
# Windows
Copy-Item env.template .env

# Linux / macOS
cp env.template .env
```

### Étape 2 : Vérifier les variables dans `.env`

Ouvrez `.env` et assurez-vous que ces variables sont à `true` :

```bash
# Dashboard
VITE_ENABLE_KEYCLOAK=true
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
VITE_API_BASE_URL=http://localhost:8084

# Backend
APP_SECURITY_ENABLED=true
OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi
```

### Étape 3 : Démarrer PostgreSQL et Keycloak

```bash
docker-compose up -d postgres keycloak
```

### Étape 4 : Attendre que Keycloak soit prêt

```bash
# Vérifier l'état de Keycloak
docker logs -f sahabi-keycloak

# Attendre le message :
# "Keycloak 24.x.x started in Xms"
```

Ou visitez : http://localhost:8080/health

### Étape 5 : Démarrer le Backend

```powershell
# Windows PowerShell
cd sahabi-guide-api
$env:APP_SECURITY_ENABLED="true"
$env:OIDC_ISSUER_URI="http://localhost:8080/realms/sahabi"
./mvnw spring-boot:run
```

```bash
# Linux / macOS
cd sahabi-guide-api
export APP_SECURITY_ENABLED=true
export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi
./mvnw spring-boot:run
```

### Étape 6 : Démarrer le Dashboard

**Dans un nouveau terminal :**

```powershell
# Windows PowerShell
cd sahabi-guide-dashboard
$env:VITE_ENABLE_KEYCLOAK="true"
$env:VITE_KEYCLOAK_URL="http://localhost:8080"
npm run dev
```

```bash
# Linux / macOS
cd sahabi-guide-dashboard
export VITE_ENABLE_KEYCLOAK=true
export VITE_KEYCLOAK_URL=http://localhost:8080
npm run dev
```

---

## 🔑 Accès à Keycloak

### Console d'administration

**URL :** http://localhost:8080/admin

**Credentials par défaut :**
- Username : `admin`
- Password : `admin123` (ou selon votre fichier `.env`)

### Configuration du Realm "sahabi"

Le realm `sahabi` doit être configuré avec :
- **Client ID** : `sahabi-dashboard`
- **Redirect URIs** : `http://localhost:3000/*`
- **Web Origins** : `http://localhost:3000`
- **Access Type** : `public` (pour les applications frontend)

### Créer un utilisateur de test

1. Aller dans **Keycloak Admin Console** → Realm `sahabi`
2. Menu **Users** → **Add user**
3. Remplir :
   - Username : `testadmin`
   - Email : `testadmin@sahabi.local`
   - Email Verified : `ON`
   - Enabled : `ON`
4. Onglet **Credentials** → Set Password :
   - Password : `admin123`
   - Temporary : `OFF`
5. Onglet **Role Mappings** :
   - Assign Role → Filter by `realm roles`
   - Ajouter le rôle `SUPER_ADMIN` ou `AGENCE_ADMIN`

---

## 🧪 Tester l'authentification

### 1. Démarrer le Dashboard

Ouvrez http://localhost:3000

### 2. Vérifier la redirection Keycloak

Vous devez être redirigé vers :
```
http://localhost:8080/realms/sahabi/protocol/openid-connect/auth?...
```

### 3. Se connecter

Utilisez les credentials de l'utilisateur créé :
- Username : `testadmin`
- Password : `admin123`

### 4. Vérification réussie

Après connexion, vous devez :
- Être redirigé vers le dashboard (http://localhost:3000/dashboard)
- Voir votre nom d'utilisateur dans la navigation
- Avoir accès aux fonctionnalités selon votre rôle

---

## 🔍 Vérifications

### Vérifier que Keycloak est utilisé

#### Dashboard

Ouvrez la console du navigateur (F12) et cherchez :
```
🔐 Initialisation Keycloak...
✅ Keycloak initialisé - Authentifié: true
👤 Token stocké, utilisateur: testadmin
```

**Si vous voyez :**
```
🔓 Mode TEST activé - Keycloak désactivé
```
→ ❌ Keycloak n'est PAS activé ! Vérifiez `VITE_ENABLE_KEYCLOAK=true`

#### Backend

Dans les logs du backend, cherchez :
```
Using generated security password: ...
```

**Si vous voyez ce message :**
→ ❌ La sécurité OAuth2 n'est PAS activée ! Vérifiez `APP_SECURITY_ENABLED=true`

**Si vous voyez :**
```
JwtDecoder configured with issuer: http://localhost:8080/realms/sahabi
```
→ ✅ Keycloak est bien configuré

### Vérifier les tokens JWT

#### Dans le navigateur

1. Ouvrez DevTools (F12) → Application/Storage → Local Storage
2. Cherchez la clé `auth_token`
3. Copiez la valeur du token

#### Décoder le token

Visitez https://jwt.io et collez le token

Vous devriez voir :
```json
{
  "sub": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "preferred_username": "testadmin",
  "realm_access": {
    "roles": ["SUPER_ADMIN", ...]
  },
  "iss": "http://localhost:8080/realms/sahabi",
  ...
}
```

---

## ❌ Dépannage

### Problème : "Keycloak n'a pas démarré dans les temps"

**Cause :** Keycloak prend du temps à démarrer (surtout au premier lancement)

**Solution :**
```bash
# Vérifier les logs
docker logs sahabi-keycloak

# Attendre le message "Keycloak started in Xms"
# Peut prendre jusqu'à 2-3 minutes
```

### Problème : "Connection refused" sur http://localhost:8080

**Cause :** Keycloak n'est pas démarré ou le port est occupé

**Solution :**
```bash
# Vérifier que le conteneur est en cours d'exécution
docker ps | grep keycloak

# Redémarrer Keycloak
docker-compose restart keycloak

# Vérifier les ports
netstat -an | grep 8080
```

### Problème : "Invalid issuer" dans le backend

**Cause :** L'URL de l'issuer ne correspond pas

**Solution :**
```bash
# Vérifier la variable d'environnement
echo $OIDC_ISSUER_URI  # Linux/macOS
echo $env:OIDC_ISSUER_URI  # Windows PowerShell

# Doit être : http://localhost:8080/realms/sahabi
# (Note : pas de / à la fin)

# Corriger si nécessaire
export OIDC_ISSUER_URI=http://localhost:8080/realms/sahabi  # Linux/macOS
$env:OIDC_ISSUER_URI="http://localhost:8080/realms/sahabi"  # Windows PowerShell
```

### Problème : Dashboard fonctionne en mode TEST

**Cause :** `VITE_ENABLE_KEYCLOAK` n'est pas défini ou à `false`

**Solution :**
```powershell
# Windows PowerShell
$env:VITE_ENABLE_KEYCLOAK="true"
cd sahabi-guide-dashboard
npm run dev
```

```bash
# Linux / macOS
export VITE_ENABLE_KEYCLOAK=true
cd sahabi-guide-dashboard
npm run dev
```

### Problème : "CORS error" lors de l'appel API

**Cause :** Le backend n'autorise pas les requêtes depuis le frontend

**Solution :**

Vérifiez dans `.env` :
```bash
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:8084
```

Ou dans `application-dev.yml` :
```yaml
app:
  cors:
    allowed-origins: http://localhost:3000,http://localhost:8080
```

### Problème : "401 Unauthorized" sur toutes les requêtes API

**Causes possibles :**
1. Token JWT expiré
2. Token non envoyé dans les headers
3. Backend n'arrive pas à valider le token Keycloak

**Solutions :**

1. **Vérifier le token dans le navigateur :**
   - F12 → Network → Sélectionner une requête API
   - Vérifier le header `Authorization: Bearer <token>`

2. **Vérifier la configuration Keycloak backend :**
   ```bash
   echo $OIDC_ISSUER_URI
   # Doit être : http://localhost:8080/realms/sahabi
   ```

3. **Se reconnecter :**
   - Se déconnecter du dashboard
   - Vider le localStorage (F12 → Application → Local Storage → Clear)
   - Se reconnecter

---

## 📚 Ressources supplémentaires

- [Documentation Keycloak](https://www.keycloak.org/documentation)
- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html)
- [Analyse complète du problème](../../ANALYSE_CONNEXION_SANS_KEYCLOAK.md)

---

## ✅ Checklist de démarrage

Avant de commencer à développer, vérifiez :

- [ ] PostgreSQL est démarré (`docker ps | grep postgres`)
- [ ] Keycloak est démarré et accessible (http://localhost:8080/health)
- [ ] Fichier `.env` créé avec les bonnes valeurs
- [ ] `VITE_ENABLE_KEYCLOAK=true` dans `.env`
- [ ] `APP_SECURITY_ENABLED=true` dans `.env`
- [ ] Backend démarre sans erreurs liées à Keycloak
- [ ] Dashboard se connecte à Keycloak (vérifier console navigateur)
- [ ] Utilisateur de test créé dans Keycloak
- [ ] Connexion réussie au dashboard
- [ ] Requêtes API fonctionnent (pas de 401 Unauthorized)

Si tous ces points sont validés, vous pouvez développer en toute sécurité ! 🚀



