# 🔐 Guide : Séparation Mobile / Dashboard pour l'authentification

## 🎯 Problème résolu

L'application Flutter utilise un système d'authentification **différent** du Dashboard :
- **Mobile (Flutter)** : Authentification par passeport + OTP → JWT généré localement (`JwtTokenService`)
- **Dashboard (React)** : Authentification via Keycloak OAuth2/OIDC → JWT Keycloak avec rôles

❌ **Problème initial** : Les annotations `@PreAuthorize` sur les contrôleurs partagés bloquaient Flutter car les JWT mobiles ne contenaient pas les rôles Keycloak.

✅ **Solution** : Trois `SecurityFilterChain` distinctes avec ordre de priorité.

---

## 📋 Architecture des SecurityFilterChain

### 1️⃣ `MobileSecurityConfig` (@Order(1) - Priorité haute)

**Fichier** : `config/MobileSecurityConfig.java`

**Endpoints gérés** :
```
/api/auth/passport/**              # Login/OTP mobile
/api/pilgrims/register             # Inscription pèlerins
/api/v1/pilgrims/*/health-profile  # Profil santé
/api/v1/pilgrims/*/position/latest # Position temps réel
/api/v1/pilgrims/*/alerts          # Alertes pèlerins
/api/v1/rituals                    # Rituels
/api/v1/duas                       # Duas
/api/v1/geo/pois                   # Lecture POIs (GET)
/api/v1/connectivity/plans         # Consultation plans eSIM
```

**Type d'authentification** : JWT local (généré par `JwtTokenService`)

**Validation** :
- Login/Register : `permitAll()`
- Autres endpoints : `authenticated()` (JWT local validé par filtre existant)

---

### 2️⃣ `OidcSecurityConfig` (@Order(2) - Priorité moyenne)

**Fichier** : `config/OidcSecurityConfig.java`

**Endpoints gérés** :
```
/api/v1/dashboard/**                    # Métriques dashboard
/api/v1/auth/agencies/**                # Gestion agences
/api/v1/auth/users/**                   # Gestion utilisateurs
/api/v1/connectivity/subscriptions/**   # Gestion abonnements eSIM
/api/v1/alerts                          # Gestion alertes (Dashboard)
/api/v1/pilgrims/groups/**              # Gestion groupes
/api/v1/pilgrims/export                 # Export CSV
```

**Type d'authentification** : Keycloak OAuth2/OIDC

**Validation** :
- JWT Keycloak avec extraction des rôles (`realm_access.roles` → `ROLE_*`)
- `@PreAuthorize` actifs sur les contrôleurs

**Rôles Keycloak** :
- `SUPER_ADMIN` : Accès complet
- `AGENCE_ADMIN` : Gestion agence
- `AGENCE_USER` : Consultation uniquement

---

### 3️⃣ `SecurityConfig` (@Order(3) - Fallback)

**Fichier** : `config/SecurityConfig.java`

**Endpoints gérés** :
```
/actuator/health      # Health check
/v3/api-docs/**       # OpenAPI docs
/swagger-ui/**        # Swagger UI
/public/**            # Ressources publiques
/ws/**                # WebSocket
```

**Validation** : `permitAll()` pour endpoints publics, `denyAll()` pour le reste

---

## 🔒 Règles de sécurité par contrôleur

### ✅ Contrôleurs avec `@PreAuthorize` (Dashboard uniquement)

| Contrôleur | Endpoint | Rôles autorisés |
|------------|----------|-----------------|
| `DashboardController` | `GET /api/v1/dashboard/metrics/summary` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `AgencyController` | `POST /api/v1/auth/agencies` | `SUPER_ADMIN` uniquement |
| `AgencyController` | `GET /api/v1/auth/agencies` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `UserController` | `DELETE /api/v1/auth/users/{id}` | `SUPER_ADMIN` uniquement |
| `UserController` | `POST /api/v1/auth/users` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `GeoController` | `POST /api/v1/geo/pois` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `GeoController` | `PUT /api/v1/geo/pois/{id}` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `GeoController` | `DELETE /api/v1/geo/pois/{id}` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `AlertsController` | `POST /api/v1/alerts` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `AlertsController` | `GET /api/v1/alerts` | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `ConnectivityController` | `POST /api/v1/connectivity/subscriptions` | `SUPER_ADMIN`, `AGENCE_ADMIN` |

### ⚠️ Endpoints SANS `@PreAuthorize` (Partagés Mobile + Dashboard)

| Contrôleur | Endpoint | Raison |
|------------|----------|--------|
| `GeoController` | `GET /api/v1/geo/pois` | Mobile consulte les POIs |
| `GeoController` | `GET /api/v1/geo/pois/{id}` | Mobile consulte détail POI |
| `AlertsController` | `GET /api/v1/pilgrims/{id}/alerts` | Mobile consulte ses alertes |
| `ConnectivityController` | `GET /api/v1/connectivity/plans` | Mobile consulte les plans eSIM |

---

## 🧪 Tests de non-régression

### Test 1 : Mobile (Flutter) - Authentification passeport
```bash
# 1. Login mobile (OTP)
POST /api/auth/passport/login
Body: { "passportNo": "AB123456" }
→ ✅ Devrait retourner success (SMS envoyé)

# 2. Verify OTP
POST /api/auth/passport/verify
Body: { "passportNo": "AB123456", "otpCode": "123456" }
→ ✅ Devrait retourner JWT mobile

# 3. GET POIs (avec JWT mobile)
GET /api/v1/geo/pois?lat=21.4225&lng=39.8262&radius=5
Authorization: Bearer <JWT_MOBILE>
→ ✅ Devrait retourner la liste des POIs
```

### Test 2 : Dashboard - Authentification Keycloak
```bash
# 1. Login Dashboard (redirection Keycloak)
→ Redirection vers http://localhost:8081/realms/sahabi/protocol/openid-connect/auth

# 2. Après login Keycloak, récupération du token
→ JWT Keycloak avec claims: { realm_access: { roles: ["AGENCE_ADMIN"] } }

# 3. GET Dashboard metrics (avec JWT Keycloak)
GET /api/v1/dashboard/metrics/summary
Authorization: Bearer <JWT_KEYCLOAK>
→ ✅ Devrait retourner les métriques si rôle = SUPER_ADMIN ou AGENCE_ADMIN
→ ❌ 403 Forbidden si rôle = AGENCE_USER
```

### Test 3 : Endpoints partagés
```bash
# GET POI (Mobile avec JWT local)
GET /api/v1/geo/pois
Authorization: Bearer <JWT_MOBILE>
→ ✅ 200 OK

# GET POI (Dashboard avec JWT Keycloak)
GET /api/v1/geo/pois
Authorization: Bearer <JWT_KEYCLOAK>
→ ✅ 200 OK

# POST POI (Mobile avec JWT local)
POST /api/v1/geo/pois
Authorization: Bearer <JWT_MOBILE>
→ ❌ 403 Forbidden (endpoint réservé Dashboard)

# POST POI (Dashboard avec JWT Keycloak + rôle AGENCE_ADMIN)
POST /api/v1/geo/pois
Authorization: Bearer <JWT_KEYCLOAK>
→ ✅ 201 Created
```

---

## 🔧 Configuration Keycloak (à créer)

### Realm : `sahabi`

### Rôles realm :
- `SUPER_ADMIN` : Administrateur système complet
- `AGENCE_ADMIN` : Administrateur d'agence (CRUD pèlerins, POIs, alertes)
- `AGENCE_USER` : Utilisateur agence (lecture seule)

### Client : `sahabi-dashboard`
- Type : `public` (ou `confidential` avec PKCE)
- Root URL : `http://localhost:3000`
- Valid redirect URIs : `http://localhost:3000/*`
- Web origins : `http://localhost:3000`
- Standard Flow : `Enabled`
- Direct Access Grants : `Disabled`

### Protocol Mappers (optionnel) :
- Nom : `agency_id`
- Type : `User Attribute`
- User Attribute : `agency_id`
- Token Claim Name : `agency_id`
- Claim JSON Type : `String`
- Add to ID token : `ON`
- Add to access token : `ON`

---

## 📊 Diagramme de flux

```
┌─────────────┐                  ┌──────────────────┐
│   Mobile    │                  │    Dashboard     │
│  (Flutter)  │                  │     (React)      │
└──────┬──────┘                  └────────┬─────────┘
       │                                  │
       │ POST /api/auth/passport/login    │ Redirect to Keycloak
       ├──────────────────────────────────┤───────────────────────────────┐
       │                                  │                               │
       │ JWT Local (passportNo, userId)   │ JWT Keycloak (sub, roles)     │
       │                                  │                               │
       ▼                                  ▼                               ▼
┌──────────────────┐            ┌──────────────────┐            ┌─────────────┐
│ MobileSecurityConfig │            │ OidcSecurityConfig │            │  Keycloak   │
│    @Order(1)     │            │    @Order(2)     │            │   Server    │
└─────────┬────────┘            └─────────┬────────┘            └─────────────┘
          │                               │
          │ Endpoints Mobile              │ Endpoints Dashboard
          │ (passeport, rituals, POIs)    │ (dashboard, agencies, users)
          │                               │
          └───────────────┬───────────────┘
                          │
                  ┌───────▼────────┐
                  │  Spring Boot   │
                  │   Backend API  │
                  └────────────────┘
```

---

## ✅ Checklist de vérification

- [x] `MobileSecurityConfig` créé avec `@Order(1)`
- [x] `OidcSecurityConfig` modifié avec `@Order(2)` et matchers Dashboard
- [x] `SecurityConfig` modifié avec `@Order(3)` (fallback)
- [x] `@PreAuthorize` retirés des endpoints partagés (GeoController.listPois, AlertsController.listPilgrimAlerts)
- [x] `@PreAuthorize` conservés sur endpoints Dashboard uniquement
- [x] CORS configuré pour Mobile (allow all origins) et Dashboard (origins restreintes)
- [ ] Tests Mobile : Login passeport + GET POIs
- [ ] Tests Dashboard : Login Keycloak + GET métriques
- [ ] Keycloak configuré avec rôles et client `sahabi-dashboard`

---

## 📝 Notes importantes

1. **Ordre des SecurityFilterChain** : L'ordre `@Order(1, 2, 3)` est **CRUCIAL**. Ne pas modifier sans comprendre l'impact.

2. **JWT Mobile vs Keycloak** : Les deux JWT sont valides mais utilisent des validators différents :
   - Mobile : Validé par `JwtTokenService` (signature HMAC locale)
   - Dashboard : Validé par Spring Security OAuth2 (JWK Keycloak)

3. **Endpoints partagés** : Ne JAMAIS ajouter `@PreAuthorize` sur un endpoint utilisé par Mobile ET Dashboard. Utiliser la séparation par SecurityFilterChain.

4. **Ajout d'un nouveau endpoint** :
   - Dashboard uniquement → Ajouter à `OidcSecurityConfig.securityMatcher()` + `@PreAuthorize`
   - Mobile uniquement → Ajouter à `MobileSecurityConfig.securityMatcher()`
   - Partagé → Ajouter aux deux matchers, **SANS** `@PreAuthorize`

---

## 🚨 Dépannage

### Erreur : "Access Denied" sur endpoint mobile
→ Vérifier que l'endpoint est bien dans `MobileSecurityConfig.securityMatcher()`

### Erreur : "403 Forbidden" sur Dashboard avec JWT Keycloak valide
→ Vérifier que le rôle requis dans `@PreAuthorize` correspond au rôle dans le JWT (`realm_access.roles`)

### Erreur : Mobile fonctionne mais Dashboard bloqué
→ Vérifier que `app.security.enabled=true` dans `application-dev.yml`
→ Vérifier que Keycloak est accessible sur `http://localhost:8081`

### Erreur : "Multiple SecurityFilterChain beans"
→ Vérifier que chaque `@Bean SecurityFilterChain` a un nom unique (`mobileSecurityFilterChain`, `oidcSecurityFilterChain`, `securityFilterChain`)

---

**Auteur** : AI Assistant  
**Date** : 2025-01-24  
**Version** : 1.0









