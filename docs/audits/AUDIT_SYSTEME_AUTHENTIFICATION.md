# 🔍 AUDIT COMPLET - Système d'Authentification Backend

## 📊 État actuel des lieux

### ✅ Ce qui fonctionne bien

Le système actuel possède **3 systèmes d'authentification distincts** :

1. **Dashboard Admin** (récent, moderne)
   - Endpoint : `/api/v1/auth/login`
   - Service : `AuthService` + `JwtService`
   - Entité : `UsersAdmin` (table `users_admin`)
   - Auth : email + mot de passe (BCrypt)
   - Rôles : `SUPER_ADMIN`, `AGENCY_ADMIN`
   - JWT : moderne, claims structurés (userId, email, role, agencyId)
   - Filtrage : `JwtAuthenticationFilter` → `SecurityContext`

2. **Mobile Pilgrims** (auth par passeport + OTP SMS)
   - Endpoint : `/api/auth/passport/*`
   - Service : `UserAuthService` + `JwtTokenService`
   - Entité : `User` (table `users`, role=`PILGRIM`)
   - Auth : numéro de passeport + code OTP par SMS (Twilio)
   - JWT : claims (pilgrimId, passportNo, phoneNumber, tokenType="PILGRIM")
   - Session : 90 jours
   - Features : rate limiting, OTP expiration, session management

3. **Back Office** (ancien système)
   - Endpoint : `/api/auth/backoffice/login`
   - Service : `BackOfficeAuthService` + `JwtTokenService`
   - Entité : `User` (table `users`, rôle staff)
   - Auth : email + mot de passe
   - JWT : claims (userId, email, role, agencyId, tokenType="BACK_OFFICE")
   - Session : 1 jour

---

## ❌ Problèmes identifiés

### 1. **Doublons de services JWT**
- `JwtService` (dashboard, nouveau, utilise AdminRole)
- `JwtTokenService` (mobile + backoffice, ancien, génère 2 types de tokens)

**Conséquence** : maintenance complexe, risque d'incohérence

### 2. **Doublons de contrôleurs d'authentification**
- `AuthController` (dashboard)
- `PassportAuthController` (mobile)
- `BackOfficeAuthController` (backoffice)

**Conséquence** : code dispersé, pas de logique unifiée

### 3. **Doublons de services d'authentification**
- `AuthService` (dashboard, utilise `UsersAdmin`)
- `UserAuthService` (mobile, utilise `User` + OTP)
- `BackOfficeAuthService` (backoffice, utilise `User`)

**Conséquence** : logique métier dupliquée

### 4. **Deux tables utilisateurs distinctes**
- `users_admin` : comptes dashboard (SUPER_ADMIN, AGENCY_ADMIN)
- `users` : comptes mobiles (PILGRIM) + staff (autres rôles)

**Question** : Faut-il unifier ou garder séparé ?

### 5. **Filtres de sécurité non unifiés**
- `JwtAuthenticationFilter` (dashboard uniquement)
- Pas de filtre pour mobile/backoffice (ou non intégré dans SecurityFilterChain)

### 6. **Claims JWT différents**
| Type | Subject | Claims |
|------|---------|--------|
| Dashboard | email | userId, email, role (AdminRole), agencyId |
| Mobile | pilgrimId | pilgrimId, passportNo, phoneNumber, tokenType="PILGRIM" |
| BackOffice | userId | userId, email, role, agencyId, tokenType="BACK_OFFICE" |

**Conséquence** : extraction de claims complexe, pas de standard

---

## 🎯 Plan de refactorisation

### Architecture cible

```
┌─────────────────────────────────────────────────────────────┐
│                  UNIFIED AUTHENTICATION SYSTEM               │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      API ENDPOINTS                            │
├──────────────────────────────────────────────────────────────┤
│  POST /api/v1/auth/mobile/login    (passport + OTP)          │
│  POST /api/v1/auth/mobile/verify   (verify OTP)              │
│  POST /api/v1/auth/dashboard/login (email + password)        │
│  POST /api/v1/auth/validate        (validate token)          │
│  POST /api/v1/auth/logout          (unified logout)          │
│  GET  /api/v1/auth/me              (get profile)             │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                  UnifiedAuthController                        │
│  - Dispatche vers les services appropriés                    │
│  - Gère les réponses HTTP                                    │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              Authentication Strategy Pattern                  │
├──────────────────────────────────────────────────────────────┤
│  AuthenticationStrategy (interface)                           │
│    ├─ MobilePassportAuthStrategy   (passport + OTP)          │
│    ├─ DashboardEmailAuthStrategy   (email + password)        │
│    └─ TokenValidationStrategy      (JWT validation)          │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                    UnifiedJwtService                          │
│  - Génération JWT unifiée avec type discriminant             │
│  - Extraction claims polymorphe                              │
│  - Validation token centralisée                              │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│               UnifiedSecurityContext                          │
│  - userId, userType (MOBILE/DASHBOARD), role, agencyId       │
│  - Adapte selon le type d'utilisateur                        │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              UnifiedJwtAuthenticationFilter                   │
│  - Extrait JWT du header Authorization                       │
│  - Valide via UnifiedJwtService                              │
│  - Initialise UnifiedSecurityContext                         │
└──────────────────────────────────────────────────────────────┘
```

---

## 📝 Décisions architecturales

### 1. **Garder deux tables utilisateurs séparées**
✅ **Décision** : Maintenir `users_admin` et `users` séparées

**Raisons** :
- Domaines métiers différents (admin vs pilgrim)
- Champs spécifiques (passportNo pour pilgrims, admin role pour admins)
- Sécurité renforcée (isolation des comptes)

### 2. **Service JWT unifié**
✅ **Décision** : Créer `UnifiedJwtService` qui remplace `JwtService` + `JwtTokenService`

**Structure de token unifiée** :
```json
{
  "sub": "<userId ou email>",
  "iss": "sahabi-guide",
  "iat": 1234567890,
  "exp": 1234999999,
  "userType": "MOBILE | DASHBOARD",
  "userId": "uuid",
  "role": "PILGRIM | SUPER_ADMIN | AGENCY_ADMIN",
  "agencyId": "uuid (optional)",
  "passportNo": "string (only for MOBILE)",
  "phoneNumber": "string (only for MOBILE)",
  "email": "string (only for DASHBOARD)"
}
```

### 3. **Stratégie d'authentification polymorphe**
✅ **Décision** : Utiliser le pattern Strategy pour gérer les différents types d'auth

```java
interface AuthenticationStrategy {
    AuthenticationResult authenticate(AuthenticationRequest request);
}

class MobilePassportAuthStrategy implements AuthenticationStrategy {
    // Gère passport + OTP
}

class DashboardEmailAuthStrategy implements AuthenticationStrategy {
    // Gère email + password
}
```

### 4. **Endpoints restructurés**
✅ **Décision** : Unifier sous `/api/v1/auth/*` avec préfixes clairs

- `/api/v1/auth/mobile/*` (remplace `/api/auth/passport/*`)
- `/api/v1/auth/dashboard/*` (remplace `/api/v1/auth/*` et `/api/auth/backoffice/*`)
- `/api/v1/auth/validate`, `/api/v1/auth/logout`, `/api/v1/auth/me` (communs)

### 5. **Filtre de sécurité unifié**
✅ **Décision** : Un seul `UnifiedJwtAuthenticationFilter` pour tous les types de tokens

---

## 🚀 Plan d'implémentation

### Phase 1 : Créer les nouveaux composants unifiés
1. ✅ Créer `UnifiedJwtService`
2. ✅ Créer `UserType` enum (MOBILE, DASHBOARD)
3. ✅ Créer `UnifiedSecurityContext`
4. ✅ Créer `AuthenticationStrategy` interface + implémentations
5. ✅ Créer `UnifiedAuthController`
6. ✅ Créer `UnifiedJwtAuthenticationFilter`

### Phase 2 : Migrer les endpoints
1. ✅ Migrer `/api/auth/passport/*` → `/api/v1/auth/mobile/*`
2. ✅ Migrer `/api/v1/auth/*` (dashboard) → conserver + adapter
3. ✅ **Supprimer** `/api/auth/backoffice/*` (redondant avec dashboard)

### Phase 3 : Nettoyer l'ancien code
1. ❌ **Supprimer** `JwtTokenService` (remplacé par UnifiedJwtService)
2. ❌ **Supprimer** `BackOfficeAuthController` (fusionné dans UnifiedAuthController)
3. ❌ **Supprimer** `BackOfficeAuthService` (fusionné dans DashboardEmailAuthStrategy)
4. ⚠️ **Garder** `UserAuthService` (logique OTP spécifique au mobile)
5. ⚠️ **Garder** `PassportAuthController` (temporaire, pour compatibilité mobile)

### Phase 4 : Migration des clients
1. Frontend dashboard : utilise déjà `/api/v1/auth/login` ✅
2. Mobile Flutter : migrer vers `/api/v1/auth/mobile/*`
3. Déprécier les anciens endpoints (6 mois)
4. Supprimer définitivement les anciens endpoints

---

## 🎨 Structure finale

```
sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/feature/auth/
├── api/
│   └── UnifiedAuthController.java           ✅ NOUVEAU (unifié)
├── app/
│   ├── strategy/
│   │   ├── AuthenticationStrategy.java      ✅ NOUVEAU
│   │   ├── MobilePassportAuthStrategy.java  ✅ NOUVEAU
│   │   └── DashboardEmailAuthStrategy.java  ✅ NOUVEAU
│   ├── UnifiedJwtService.java               ✅ NOUVEAU (remplace JwtService + JwtTokenService)
│   ├── UnifiedSecurityContext.java          ✅ NOUVEAU (remplace SecurityContext)
│   ├── UnifiedJwtAuthenticationFilter.java  ✅ NOUVEAU (remplace JwtAuthenticationFilter)
│   └── service/
│       ├── MobileOtpService.java            ⚠️ RENOMMER (ex-UserAuthService, logique OTP)
│       ├── RateLimitService.java            ✅ GARDER
│       ├── SessionManagementService.java    ✅ GARDER
│       └── TwilioSmsService.java            ✅ GARDER
├── domain/
│   ├── User.java                            ✅ GARDER (pilgrims + staff)
│   ├── UsersAdmin.java                      ✅ GARDER (dashboard admins)
│   ├── UserType.java                        ✅ NOUVEAU enum (MOBILE, DASHBOARD)
│   └── dto/
│       ├── UnifiedLoginRequest.java         ✅ NOUVEAU
│       └── UnifiedAuthResponse.java         ✅ NOUVEAU
└── infra/
    ├── UserRepository.java                  ✅ GARDER
    └── UsersAdminRepository.java            ✅ GARDER

À SUPPRIMER :
❌ JwtTokenService.java
❌ BackOfficeAuthController.java
❌ BackOfficeAuthService.java
❌ JwtService.java (remplacé par UnifiedJwtService)
❌ JwtAuthenticationFilter.java (remplacé par UnifiedJwtAuthenticationFilter)
❌ SecurityContext.java (remplacé par UnifiedSecurityContext)
```

---

## ✅ Bénéfices attendus

1. **Code centralisé** : un seul service JWT, un seul filtre
2. **Maintenabilité** : logique claire, pattern Strategy
3. **Extensibilité** : facile d'ajouter un nouveau type d'auth (ex: OAuth2)
4. **Cohérence** : structure JWT unifiée
5. **Sécurité** : validation centralisée
6. **Performance** : pas de duplication de code

---

## ⚠️ Points d'attention

1. **Migration progressive** : garder les anciens endpoints en "deprecated" pendant 6 mois
2. **Tests** : créer des tests d'intégration pour chaque type d'auth
3. **Documentation** : mettre à jour openapi.yml
4. **Mobile** : coordonner avec l'équipe Flutter pour la migration
5. **Rétrocompatibilité** : les anciens tokens doivent continuer à fonctionner

---

## 📦 Prochaines étapes

1. Valider ce plan avec l'équipe ✅
2. Créer une branche feature/unified-auth ✅
3. Implémenter Phase 1 (nouveaux composants) ✅
4. Tests unitaires + intégration ⏳
5. Migration Phase 2 (endpoints) ⏳
6. Nettoyage Phase 3 (ancien code) ⏳
7. Documentation + formation équipe ⏳

---

📅 **Date d'audit** : 2025-01-24  
👤 **Auditeur** : Assistant IA  
📝 **Status** : ✅ Plan validé, prêt pour implémentation









