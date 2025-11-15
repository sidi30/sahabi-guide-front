# 🔧 Configuration du client Keycloak `sahabi-dashboard`

## ✅ Client déjà créé : `sahabi-dashboard`

Vérifie que ton client a la configuration suivante dans Keycloak Admin Console :

---

## 📋 Configuration requise

### 1. **Settings (Général)**

```yaml
Client ID: sahabi-dashboard
Name: Sahabi Dashboard (React)
Description: Application Dashboard React pour la gestion des pèlerins

# Client authentication
Client authentication: OFF
  ❌ Ce client est PUBLIC (pas de secret)

# Authentication flow
Standard flow: ENABLED ✅
  ✓ Active le flux Authorization Code (pour navigation web)

Direct access grants: DISABLED ❌
  ✗ On n'utilise PAS le flux password (sécurité)

Implicit flow: DISABLED ❌
  ✗ Déprécié, on utilise Authorization Code + PKCE

Service accounts roles: DISABLED ❌
  ✗ Pas besoin (ce n'est pas un service backend)

OAuth 2.0 Device Authorization Grant: DISABLED ❌
OIDC CIBA Grant: DISABLED ❌

# Login settings
Root URL: http://localhost:3000
Home URL: http://localhost:3000
Valid redirect URIs:
  - http://localhost:3000/*
  - http://localhost:3000
Valid post logout redirect URIs:
  - http://localhost:3000/*
Web origins:
  - http://localhost:3000
  - +

Admin URL: (laisser vide)
```

---

### 2. **Capability config**

```yaml
Client authentication: OFF
Authorization: OFF
Authentication flow:
  ✅ Standard flow
  ❌ Direct access grants
  ❌ Implicit flow
  ❌ Service accounts roles
  ❌ OAuth 2.0 Device Authorization Grant
```

---

### 3. **Advanced settings** (optionnel)

```yaml
Access Token Lifespan: (vide = utilise les defaults du realm)
Proof Key for Code Exchange Code Challenge Method: S256 (recommandé)
```

---

## 👥 Configuration des utilisateurs de test

### Créer un utilisateur SUPER_ADMIN

```
1. Users → Add user
   - Username: admin@sahabi.com
   - Email: admin@sahabi.com
   - Email verified: ON
   - Enabled: ON
   → Create

2. Credentials tab
   - Set password: password123
   - Temporary: OFF
   → Save

3. Role mapping tab
   - Assign role → Filter by realm roles
   - Cocher: SUPER_ADMIN
   → Assign
```

### Créer un utilisateur AGENCE_ADMIN

```
1. Users → Add user
   - Username: agence1@sahabi.com
   - Email: agence1@sahabi.com
   - Email verified: ON
   → Create

2. Credentials → password123 (Temporary: OFF)

3. Role mapping → AGENCE_ADMIN

4. Attributes tab (optionnel - pour filtrage par agence)
   - Key: agency_id
   - Value: 550e8400-e29b-41d4-a716-446655440001
   → Add
```

### Créer un utilisateur AGENCE_USER (lecture seule)

```
1. Users → Add user
   - Username: user1@sahabi.com
   - Email: user1@sahabi.com
   → Create

2. Credentials → password123 (Temporary: OFF)

3. Role mapping → AGENCE_USER
```

---

## 🔐 Vérification de la configuration

### Test 1 : Obtenir un token via Postman

```http
POST http://localhost:8080/realms/sahabi/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
client_id=sahabi-dashboard
username=admin@sahabi.com
password=password123
```

**Réponse attendue :**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
  "token_type": "Bearer"
}
```

### Test 2 : Décoder le token (jwt.io)

Le token doit contenir :
```json
{
  "realm_access": {
    "roles": [
      "SUPER_ADMIN",
      "offline_access",
      "uma_authorization",
      "default-roles-sahabi"
    ]
  },
  "preferred_username": "admin@sahabi.com",
  "email": "admin@sahabi.com",
  "email_verified": true
}
```

### Test 3 : Tester l'API backend

```bash
# 1. Récupérer le token (voir Test 1)
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI..."

# 2. Appeler un endpoint protégé
curl -X GET http://localhost:8084/api/v1/dashboard/metrics/summary \
  -H "Authorization: Bearer $TOKEN"

# Si rôle = SUPER_ADMIN ou AGENCE_ADMIN :
# → 200 OK avec les métriques

# Si rôle = AGENCE_USER :
# → 403 Forbidden (endpoint réservé admin)
```

---

## 🌐 Variables d'environnement Dashboard React

Créer `.env.local` dans `sahabi-guide-dashboard/` :

```bash
VITE_API_BASE_URL=http://localhost:8084
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
```

---

## 🚀 Démarrage complet

### Terminal 1 : Backend Spring Boot
```bash
cd sahabi-guide-api
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Terminal 2 : Dashboard React
```bash
cd sahabi-guide-dashboard
npm install  # Si pas déjà fait
npm run dev
```

### Terminal 3 : Keycloak (si Docker)
```bash
docker ps | grep keycloak
# Vérifier que Keycloak tourne sur port 8080
```

---

## ✅ Test de bout en bout

```
1. Ouvrir http://localhost:3000/login
2. Cliquer "Se connecter"
3. Redirection vers Keycloak login page
4. Login avec admin@sahabi.com / password123
5. Redirection retour vers http://localhost:3000/dashboard
6. Dashboard s'affiche avec métriques
7. Console navigateur (F12) → Onglet Network
8. Vérifier que les requêtes API ont :
   Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI...
```

---

## 🐛 Dépannage

### Erreur "invalid_redirect_uri"
→ Vérifier dans Keycloak client settings :
  - Valid redirect URIs contient `http://localhost:3000/*`

### Erreur "CORS error"
→ Vérifier dans Keycloak client settings :
  - Web origins contient `http://localhost:3000`

### Token ne contient pas les rôles
→ Vérifier que l'utilisateur a bien les rôles assignés :
  - Users → admin@sahabi.com → Role mapping
  - Doit voir SUPER_ADMIN dans "Assigned roles"

### Backend retourne 403 Forbidden
→ Vérifier que :
  - `app.security.enabled=true` dans application-dev.yml
  - `issuer-uri` pointe vers `http://localhost:8080/realms/sahabi`
  - Redémarrer le backend après modification

### Dashboard reste sur "Chargement..."
→ Vérifier que :
  - Keycloak est accessible : `curl http://localhost:8080/realms/sahabi`
  - Console navigateur montre une erreur Keycloak
  - Le timeout de 5s est activé dans AuthContext.tsx

---

## 📚 Ressources

- JWT Decoder : https://jwt.io
- Keycloak Admin : http://localhost:8080/admin
- Backend API Docs : http://localhost:8084/swagger-ui.html
- Dashboard Dev : http://localhost:3000

---

**Auteur** : AI Assistant  
**Date** : 2025-01-24  
**Version** : 1.1 (Port Keycloak corrigé : 8080)









