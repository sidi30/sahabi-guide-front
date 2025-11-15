# 🚀 Installation complète : Keycloak + Backend + Dashboard

## 📦 Prérequis

- ☑️ Java 21
- ☑️ Node.js 18+
- ☑️ Docker (pour Keycloak)
- ☑️ PostgreSQL (si non inclus dans docker-compose)

---

## 🐳 Étape 1 : Lancer Keycloak

### Option A : Docker Compose (recommandé)

Créer `docker-compose-keycloak.yml` :

```yaml
version: '3.8'
services:
  keycloak:
    image: quay.io/keycloak/keycloak:26.0.7
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
      KC_HTTP_PORT: 8080
    ports:
      - "8080:8080"
    command:
      - start-dev
      - --http-port=8080
    networks:
      - sahabi-network

networks:
  sahabi-network:
    driver: bridge
```

Lancer :
```bash
docker-compose -f docker-compose-keycloak.yml up -d
```

Vérifier :
```bash
# Attendre ~30s le démarrage
curl http://localhost:8080/health/ready

# Accéder à l'admin console
open http://localhost:8080/admin
# Login: admin / admin
```

### Option B : Installation locale

```bash
# Télécharger Keycloak
wget https://github.com/keycloak/keycloak/releases/download/26.0.7/keycloak-26.0.7.zip
unzip keycloak-26.0.7.zip
cd keycloak-26.0.7

# Lancer en mode dev
export KC_HTTP_PORT=8080
./bin/kc.sh start-dev --http-port=8080

# Créer un admin user (si premier lancement)
./bin/kc.sh admin create --username admin --password admin
```

---

## ⚙️ Étape 2 : Configurer Keycloak

### 1. Créer le realm `sahabi`

```bash
# Via Admin Console UI
http://localhost:8080/admin
→ Dropdown "master" (coin haut gauche) → Create realm
→ Realm name: sahabi
→ Create
```

### 2. Créer les rôles

```bash
# Via Admin Console UI
→ Realm roles → Create role
  - Name: SUPER_ADMIN → Save
  - Name: AGENCE_ADMIN → Save
  - Name: AGENCE_USER → Save
```

### 3. Créer le client `sahabi-dashboard`

```bash
# Via Admin Console UI
→ Clients → Create client
  - Client type: OpenID Connect
  - Client ID: sahabi-dashboard
  - Next
  
  - Client authentication: OFF
  - Authorization: OFF
  - Standard flow: ENABLED
  - Direct access grants: DISABLED
  - Save
  
  - Valid redirect URIs:
    * http://localhost:3000/*
  - Web origins:
    * http://localhost:3000
  - Save
```

### 4. Créer des utilisateurs de test

```bash
# Super Admin
→ Users → Add user
  - Username: admin@sahabi.com
  - Email: admin@sahabi.com
  - Email verified: ON
  - Create
  
  → Credentials tab
    - Set password: password123
    - Temporary: OFF
    - Save
  
  → Role mapping tab
    - Assign role: SUPER_ADMIN

# Agence Admin
→ Users → Add user
  - Username: agence1@sahabi.com
  - Email: agence1@sahabi.com
  - Create
  
  → Credentials: password123
  → Role mapping: AGENCE_ADMIN
  
  → Attributes tab (optionnel)
    - Key: agency_id
    - Value: 550e8400-e29b-41d4-a716-446655440001
    - Add

# Utilisateur agence (lecture seule)
→ Users → Add user
  - Username: user1@sahabi.com
  - Email: user1@sahabi.com
  - Create
  
  → Credentials: password123
  → Role mapping: AGENCE_USER
```

---

## 🏗️ Étape 3 : Backend Spring Boot

### 1. Vérifier les dépendances Maven

Le `pom.xml` contient déjà :
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
```

### 2. Configurer application-dev.yml

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8081/realms/sahabi

app:
  security:
    enabled: true  # IMPORTANT : activer la sécurité
  cors:
    allowed-origins: http://localhost:3000
```

### 3. Compiler et lancer

```bash
cd sahabi-guide-api

# Compiler (génère les classes OpenAPI)
mvn clean install -DskipTests

# Lancer avec profil dev
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Vérifier le démarrage
curl http://localhost:8084/actuator/health
# {"status":"UP"}
```

### 4. Vérifier les SecurityFilterChain

```bash
# Logs au démarrage doivent montrer :
# - MobileSecurityConfig @Order(1)
# - OidcSecurityConfig @Order(2)
# - SecurityConfig @Order(3)

# Si erreur "Multiple SecurityFilterChain", vérifier que chaque @Bean a un nom unique
```

---

## 💻 Étape 4 : Dashboard React

### 1. Installer les dépendances

```bash
cd sahabi-guide-dashboard

npm install
# Installe keycloak-js v26.0.7
```

### 2. Créer .env.local

```bash
cat > .env.local << 'EOF'
VITE_API_BASE_URL=http://localhost:8084
VITE_KEYCLOAK_URL=http://localhost:8081
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
EOF
```

### 3. Lancer en mode dev

```bash
npm run dev

# Devrait ouvrir http://localhost:3000
```

### 4. Tester l'authentification

```
1. Aller sur http://localhost:3000/login
2. Cliquer sur "Se connecter"
3. Redirection vers Keycloak → http://localhost:8080/realms/sahabi/protocol/openid-connect/auth
4. Login avec admin@sahabi.com / password123
5. Redirection retour vers http://localhost:3000/dashboard
6. ✅ Dashboard s'affiche avec métriques
```

---

## ✅ Étape 5 : Tests de validation

### Test 1 : Dashboard avec rôle SUPER_ADMIN

```bash
# 1. Login Dashboard avec admin@sahabi.com
# 2. Console navigateur (F12) → Network
# 3. Vérifier que les requêtes API ont Authorization: Bearer <token>
# 4. Tester les endpoints protégés :

curl -X GET http://localhost:8084/api/v1/dashboard/metrics/summary \
  -H "Authorization: Bearer <COPIER_TOKEN_DEPUIS_NAVIGATEUR>"

# Devrait retourner 200 OK avec :
# {
#   "totalPilgrims": 123,
#   "activeConnections": 45,
#   ...
# }
```

### Test 2 : Mobile Flutter (aucun changement nécessaire)

```bash
# Login passeport (inchangé)
curl -X POST http://localhost:8084/api/auth/passport/login \
  -H "Content-Type: application/json" \
  -d '{"passportNo":"AB123456"}'

# OTP (inchangé)
curl -X POST http://localhost:8084/api/auth/passport/verify \
  -H "Content-Type: application/json" \
  -d '{"passportNo":"AB123456","otpCode":"123456"}'

# GET POIs avec JWT mobile (inchangé)
curl -X GET http://localhost:8084/api/v1/geo/pois \
  -H "Authorization: Bearer <JWT_MOBILE>"

# ✅ Devrait retourner 200 OK (pas bloqué par @PreAuthorize)
```

### Test 3 : Endpoint Dashboard uniquement

```bash
# Dashboard : GET agencies (protégé)
curl -X GET http://localhost:8084/api/v1/auth/agencies \
  -H "Authorization: Bearer <JWT_KEYCLOAK>"
# ✅ 200 OK si rôle = SUPER_ADMIN ou AGENCE_ADMIN

# Mobile : GET agencies (bloqué)
curl -X GET http://localhost:8084/api/v1/auth/agencies \
  -H "Authorization: Bearer <JWT_MOBILE>"
# ❌ 403 Forbidden (endpoint non couvert par MobileSecurityConfig)
```

---

## 🔒 Étape 6 : Migration en production

### Backend (application-prod.yml)

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${OIDC_ISSUER_URI:https://keycloak.sahabi.com/realms/sahabi}

app:
  security:
    enabled: true
  cors:
    allowed-origins: https://dashboard.sahabi.com
```

### Dashboard (.env.production)

```bash
VITE_API_BASE_URL=https://api.sahabi.com
VITE_KEYCLOAK_URL=https://keycloak.sahabi.com
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
```

### Keycloak Client (production)

Modifier le client `sahabi-dashboard` :
```
Valid redirect URIs:
  - https://dashboard.sahabi.com/*
  
Web origins:
  - https://dashboard.sahabi.com
```

---

## 📊 Résumé des composants

| Composant | Port | URL | Rôle |
|-----------|------|-----|------|
| Keycloak | 8080 | http://localhost:8080 | Authentification OAuth2 |
| Backend API | 8084 | http://localhost:8084 | Resource Server Spring Boot |
| Dashboard React | 3000 | http://localhost:3000 | Client OIDC |
| PostgreSQL | 5432 | localhost:5432 | Base de données |

---

## 🐛 Troubleshooting courant

### Backend ne démarre pas
```bash
# Vérifier que PostgreSQL tourne
psql -h localhost -U postgres -d sahabi_db

# Vérifier que Keycloak est accessible
curl http://localhost:8080/health/ready

# Logs backend
tail -f logs/spring.log
```

### Dashboard "CORS error"
```bash
# Vérifier CORS backend
curl -X OPTIONS http://localhost:8084/api/v1/dashboard/metrics/summary \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET"

# Devrait retourner Access-Control-Allow-Origin: http://localhost:3000
```

### "Invalid redirect_uri" Keycloak
→ Vérifier que `http://localhost:3000/*` est dans les Valid redirect URIs du client

### Mobile bloqué par @PreAuthorize
→ Vérifier que l'endpoint est bien dans `MobileSecurityConfig.securityMatcher()`
→ Consulter `GUIDE_SEPARATION_MOBILE_DASHBOARD_AUTH.md`

---

## 📚 Fichiers de référence

- `GUIDE_SEPARATION_MOBILE_DASHBOARD_AUTH.md` : Architecture sécurité Mobile/Dashboard
- `sahabi-guide-dashboard/CONFIGURATION_KEYCLOAK.md` : Config Dashboard React
- `sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/config/` : SecurityFilterChains

---

**Auteur** : AI Assistant  
**Date** : 2025-01-24  
**Version** : 1.0

