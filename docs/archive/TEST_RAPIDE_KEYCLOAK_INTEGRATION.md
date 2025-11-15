# ✅ Test rapide : Vérifier l'intégration Keycloak

## 🎯 Configuration détectée

```yaml
Keycloak URL: http://localhost:8080
Realm: sahabi
Client Backend: sahabi-api-gateway (service account)
Client Dashboard: sahabi-dashboard (public)
```

---

## 📝 Checklist avant de tester

### ✅ Backend (application-dev.yml)
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/sahabi

app:
  security:
    enabled: true  # IMPORTANT : doit être true
```

### ✅ Dashboard (.env.local)
```bash
VITE_API_BASE_URL=http://localhost:8084
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
```

---

## 🧪 Test 1 : Keycloak accessible

```bash
# PowerShell
Invoke-WebRequest -Uri http://localhost:8080/realms/sahabi -Method GET
```

**Résultat attendu :**
```
StatusCode        : 200
```

---

## 🧪 Test 2 : Backend valide les tokens Keycloak

### Étape 2.1 : Obtenir un token Keycloak

**Méthode A : Via Postman/Bruno/Insomnia**

```http
POST http://localhost:8080/realms/sahabi/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
client_id=sahabi-dashboard
username=admin@sahabi.com
password=password123
```

**Méthode B : Via PowerShell**

```powershell
$body = @{
    grant_type = 'password'
    client_id = 'sahabi-dashboard'
    username = 'admin@sahabi.com'
    password = 'password123'
}

$response = Invoke-RestMethod -Uri 'http://localhost:8080/realms/sahabi/protocol/openid-connect/token' -Method Post -Body $body -ContentType 'application/x-www-form-urlencoded'

$token = $response.access_token
Write-Host "Token obtenu : $($token.Substring(0,50))..."
```

### Étape 2.2 : Tester un endpoint protégé

```powershell
# Utiliser le $token de l'étape précédente
$headers = @{
    Authorization = "Bearer $token"
}

Invoke-RestMethod -Uri 'http://localhost:8084/api/v1/dashboard/metrics/summary' -Headers $headers
```

**Résultat attendu :**
```json
{
  "totalPilgrims": 0,
  "activeConnections": 0,
  "geolocatedPilgrims": 0,
  "nonGeolocatedPilgrims": 0,
  "activeAlerts": 0,
  "resolvedAlerts": 0
}
```

**Si erreur 403 Forbidden :**
- Vérifier que l'utilisateur a le rôle `SUPER_ADMIN` ou `AGENCE_ADMIN`
- Aller dans Keycloak → Users → admin@sahabi.com → Role mapping

---

## 🧪 Test 3 : Dashboard React se connecte

### Étape 3.1 : Lancer le Dashboard

```bash
cd sahabi-guide-dashboard
npm run dev
```

### Étape 3.2 : Tester le flow OAuth2

```
1. Ouvrir http://localhost:3000/login
2. Ouvrir la console navigateur (F12)
3. Cliquer sur "Se connecter"
4. Vérifier dans la console :
   ✅ Redirection vers http://localhost:8080/realms/sahabi/protocol/openid-connect/auth
5. Login avec admin@sahabi.com / password123
6. Redirection retour vers http://localhost:3000
7. Dashboard s'affiche
```

### Étape 3.3 : Vérifier le token dans les requêtes

```
Console (F12) → Onglet Network
→ Filtrer par "dashboard" ou "api"
→ Cliquer sur une requête API
→ Headers → Request Headers
→ Vérifier : Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI...
```

---

## 🧪 Test 4 : Mobile (Flutter) continue de fonctionner

```bash
# Test login passeport (doit toujours marcher)
curl -X POST http://localhost:8084/api/auth/passport/login \
  -H "Content-Type: application/json" \
  -d '{"passportNo":"AB123456"}'
```

**Résultat attendu :**
```json
{
  "success": true,
  "message": "Code OTP envoyé par SMS",
  "timestamp": 1761346731000
}
```

---

## 🔍 Décodage du token (analyse)

### Outil : https://jwt.io

Coller le token Keycloak et vérifier :

```json
{
  "exp": 1761347031,
  "iss": "http://localhost:8080/realms/sahabi",
  "realm_access": {
    "roles": [
      "SUPER_ADMIN",      ← Rôle principal
      "AGENCE_ADMIN",     ← Rôle secondaire (optionnel)
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

**Points de validation :**
- ✅ `iss` = `http://localhost:8080/realms/sahabi` (correspond au backend)
- ✅ `realm_access.roles` contient `SUPER_ADMIN` ou `AGENCE_ADMIN`
- ✅ `preferred_username` et `email` sont corrects

---

## 🐛 Problèmes courants

### ❌ Backend retourne 401 Unauthorized

**Cause :** Le token n'est pas valide ou l'issuer ne correspond pas

**Solution :**
```bash
# Vérifier l'issuer dans le backend
grep -r "issuer-uri" sahabi-guide-api/src/main/resources/

# Doit montrer :
# issuer-uri: http://localhost:8080/realms/sahabi

# Redémarrer le backend après modification
```

### ❌ Backend retourne 403 Forbidden

**Cause :** L'utilisateur n'a pas le bon rôle

**Solution :**
```
Keycloak Admin Console :
→ Users → Chercher l'utilisateur
→ Role mapping tab
→ Assign role → SUPER_ADMIN (ou AGENCE_ADMIN)
→ Assign

Puis re-obtenir un nouveau token (l'ancien ne contient pas le rôle)
```

### ❌ Dashboard reste sur "Chargement..."

**Cause :** Keycloak non accessible ou timeout

**Solution :**
```bash
# 1. Vérifier Keycloak
curl http://localhost:8080/realms/sahabi

# 2. Vérifier la console navigateur (F12)
# Chercher une erreur réseau ou CORS

# 3. Vérifier le code AuthContext.tsx
# Le timeout de 5s devrait débloquer après 5s
```

### ❌ CORS error sur Dashboard

**Cause :** Keycloak rejette les requêtes depuis localhost:3000

**Solution :**
```
Keycloak Admin Console :
→ Clients → sahabi-dashboard → Settings
→ Web origins : vérifier que http://localhost:3000 est présent
→ Save
```

### ❌ "Invalid redirect_uri"

**Cause :** L'URL de retour n'est pas autorisée

**Solution :**
```
Keycloak Admin Console :
→ Clients → sahabi-dashboard → Settings
→ Valid redirect URIs : ajouter http://localhost:3000/*
→ Save
```

---

## ✅ Validation finale

Si tous les tests passent :

- ✅ Keycloak est opérationnel
- ✅ Backend valide les tokens Keycloak
- ✅ Dashboard se connecte via OAuth2
- ✅ Les rôles sont extraits correctement
- ✅ Mobile continue de fonctionner avec son auth locale

**→ L'intégration est complète et fonctionnelle ! 🎉**

---

## 📊 Logs de debug

### Backend (logs Spring Boot)

```bash
# Chercher dans les logs :
tail -f sahabi-guide-api/logs/spring.log | grep -i "keycloak\|jwt\|oauth2"
```

**Logs attendus :**
```
SecurityFilterChain : MobileSecurityConfig @Order(1)
SecurityFilterChain : OidcSecurityConfig @Order(2)
SecurityFilterChain : SecurityConfig @Order(3)
OAuth2 Resource Server : Issuer : http://localhost:8080/realms/sahabi
```

### Dashboard (console navigateur)

Ouvrir F12 → Console, chercher :
```
✅ Keycloak initialized
✅ Token stored in localStorage
⚠️ Keycloak timeout (si Keycloak non dispo)
```

---

**Date** : 2025-01-24  
**Version** : 1.0 (Port Keycloak 8080)









