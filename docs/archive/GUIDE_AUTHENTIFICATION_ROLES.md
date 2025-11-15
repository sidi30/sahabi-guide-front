# 🔐 Guide Complet - Système d'Authentification et Gestion des Rôles

## 📋 Vue d'ensemble

Ce document décrit le **système complet d'authentification JWT** avec **gestion des rôles** (SUPER_ADMIN / AGENCY_ADMIN) implémenté pour le dashboard Sahabi Guide.

---

## 🎯 Fonctionnalités

### ✅ Backend (Spring Boot)

1. **Table `users_admin`** : stockage des comptes administrateurs
2. **Enum `AdminRole`** : SUPER_ADMIN, AGENCY_ADMIN
3. **JWT Service** : génération et validation de tokens JWT avec rôle + agencyId
4. **Auth Controller** : endpoints `/api/v1/auth/login` et `/api/v1/auth/me`
5. **Security Filter** : intercepteur JWT qui initialise le `SecurityContext` pour chaque requête
6. **Filtrage automatique** : les services (DashboardService, AnalyticsService, PositionService) filtrent les données selon le rôle

### ✅ Frontend (React + TypeScript)

1. **AuthService** : login, logout, getProfile, stockage du token dans localStorage
2. **AuthContext** : contexte React fournissant `profile`, `agencyId`, `isSuperAdmin`, `isAgencyAdmin`
3. **LoginPage** : page de connexion moderne avec Chakra UI
4. **ProtectedRoute** : composant HOC pour protéger les routes (redirection vers `/login` si non authentifié)
5. **Intégration** : MapPage et AnalyticsPage utilisent l'agencyId du profil connecté

---

## 📂 Structure des fichiers créés/modifiés

### Backend

```
sahabi-guide-api/
├── src/main/resources/db/changelog/
│   ├── 024-create-admin-users.xml          ✅ Nouvelle migration Liquibase
│   └── db.changelog-master.xml             ✏️ Modifié (ajout de 024)
├── src/main/java/com/sahabiGuide/sahabi/
│   ├── common/enums/
│   │   └── AdminRole.java                  ✅ Nouveau (SUPER_ADMIN, AGENCY_ADMIN)
│   ├── config/
│   │   └── SecurityConfig.java             ✏️ Modifié (ajout JwtAuthenticationFilter, PasswordEncoder)
│   └── feature/auth/
│       ├── domain/
│       │   └── UsersAdmin.java             ✅ Nouvelle entité JPA
│       ├── infra/
│       │   └── UsersAdminRepository.java   ✅ Nouveau repository
│       ├── app/
│       │   ├── JwtService.java             ✅ Génération/validation JWT
│       │   ├── AuthService.java            ✅ Login, getProfile, createAdmin
│       │   ├── SecurityContext.java        ✅ Contexte utilisateur par requête
│       │   └── JwtAuthenticationFilter.java ✅ Filtre Spring Security
│       └── api/
│           ├── AuthController.java         ✅ POST /auth/login, GET /auth/me
│           └── dto/
│               ├── LoginRequest.java       ✅ DTO
│               ├── LoginResponse.java      ✅ DTO
│               └── AdminProfileDto.java    ✅ DTO
├── feature/dashboard/app/
│   ├── DashboardService.java               ✏️ Modifié (filtrage par agencyId)
│   └── AnalyticsService.java               ✏️ Modifié (filtrage par agencyId)
└── SEED_ADMIN_USERS.sql                    ✅ Script SQL avec 3 comptes de test
```

### Frontend

```
sahabi-guide-dashboard/
├── src/
│   ├── services/
│   │   └── auth.service.ts                 ✅ Service d'authentification
│   ├── contexts/
│   │   └── AuthContext.tsx                 ✅ Contexte React
│   ├── components/auth/
│   │   └── ProtectedRoute.tsx              ✅ HOC pour routes protégées
│   ├── pages/
│   │   ├── LoginPage.tsx                   ✅ Nouvelle page de connexion
│   │   ├── MapPage.tsx                     ✏️ Modifié (utilise agencyId du profil)
│   │   └── AnalyticsPage.tsx               ✏️ Modifié (utilise agencyId du profil)
│   ├── config/
│   │   └── routes.tsx                      ✏️ Modifié (ajout LoginPage + ProtectedRoute)
│   ├── App.tsx                             ✏️ Modifié (AuthProvider + gestion layout)
│   └── main.tsx                            (inchangé, mocks déjà supprimés)
```

---

## 🔑 Comptes de test (SEED_ADMIN_USERS.sql)

### 1. SUPER_ADMIN
- **Email** : `admin@sahabi.com`
- **Mot de passe** : `password123`
- **Rôle** : SUPER_ADMIN
- **Accès** : Vue globale sur toutes les agences

### 2. AGENCY_ADMIN 1
- **Email** : `agency1@sahabi.com`
- **Mot de passe** : `password123`
- **Rôle** : AGENCY_ADMIN
- **AgencyId** : `550e8400-e29b-41d4-a716-446655440001`
- **Accès** : Uniquement les pèlerins de son agence

### 3. AGENCY_ADMIN 2
- **Email** : `agency2@sahabi.com`
- **Mot de passe** : `password123`
- **Rôle** : AGENCY_ADMIN
- **AgencyId** : `550e8400-e29b-41d4-a716-446655440002`
- **Accès** : Uniquement les pèlerins de son agence

---

## 🚀 Comment tester

### 1. Lancer le backend

```powershell
cd sahabi-guide-api

# Exécuter le seed SQL pour créer les comptes admin
psql -U postgres -d sahabi_guide -f ../SEED_ADMIN_USERS.sql

# Lancer l'API (port 8084 par défaut)
.\mvnw.cmd spring-boot:run
```

### 2. Lancer le dashboard

```powershell
cd sahabi-guide-dashboard

# Installer les dépendances (si nécessaire)
npm install

# Lancer en mode dev
npm run dev
```

### 3. Tester l'authentification

1. Ouvrir http://localhost:5173
2. Vous serez redirigé vers `/login`
3. Se connecter avec un des comptes :
   - **Super Admin** : `admin@sahabi.com` / `password123`
   - **Agence 1** : `agency1@sahabi.com` / `password123`
   - **Agence 2** : `agency2@sahabi.com` / `password123`

### 4. Vérifier le filtrage par rôle

#### En tant que SUPER_ADMIN
- `/dashboard` : voit les statistiques globales (tous les pèlerins)
- `/map` : voit les positions de toutes les agences
- `/analytics` : voit les analytics globales

#### En tant que AGENCY_ADMIN
- `/dashboard` : voit uniquement les statistiques de son agence
- `/map` : voit uniquement les positions des pèlerins de son agence
- `/analytics` : voit uniquement les analytics de son agence

---

## 🔐 Flux d'authentification

### 1. Login (POST /api/v1/auth/login)

```
Frontend                    Backend
   |                           |
   |--- POST /auth/login ------>|
   |   { email, password }      |
   |                            |
   |                      [Vérification]
   |                      [Génération JWT]
   |                            |
   |<---- 200 OK --------------|
   |   { token, userId,         |
   |     role, agencyId, ... }  |
   |                            |
   | [Stocke token dans         |
   |  localStorage]             |
   |                            |
   | [Redirige vers /dashboard] |
```

### 2. Requête authentifiée (GET /api/v1/dashboard/metrics)

```
Frontend                    Backend
   |                           |
   |--- GET /dashboard/metrics ->| [JwtAuthenticationFilter]
   | Authorization:              | ├─ Extrait le JWT
   | Bearer eyJhbGc...           | ├─ Valide le token
   |                             | └─ Initialise SecurityContext
   |                             |     (userId, role, agencyId)
   |                             |
   |                      [DashboardService]
   |                      ├─ Lit SecurityContext
   |                      ├─ Si SUPER_ADMIN: agencyId = null
   |                      ├─ Si AGENCY_ADMIN: agencyId = user.agencyId
   |                      └─ Filtre les données
   |                             |
   |<---- 200 OK --------------|
   |   { metrics filtrées }      |
```

---

## 📊 Filtrage automatique côté backend

### DashboardService.getMetrics()

```java
public MetricsSummary getMetrics() {
    UUID agencyId = getEffectiveAgencyId(); // null pour SUPER_ADMIN, user.agencyId pour AGENCY_ADMIN
    
    long totalPilgrims = agencyId != null 
        ? userRepository.countByAgencyId(agencyId)  // Filtré
        : userRepository.count();                   // Global
    
    summary.setTotalPilgrims(Math.toIntExact(totalPilgrims));
    // ...
}
```

### AnalyticsService.getDaily()

```java
public List<UsagePoint> getDaily(int days) {
    UUID agencyId = securityContext.isSuperAdmin() ? null : securityContext.getCurrentAgencyId();
    
    List<UserConversationProgress> progresses = agencyId != null
        ? filterByAgency(progressRepository.findByAnsweredAtAfter(since), agencyId)  // Filtré
        : progressRepository.findByAnsweredAtAfter(since);                           // Global
    
    // Agrégation...
}
```

---

## 🛡️ Sécurité

### ✅ Protection des routes

- Toutes les routes sauf `/login`, `/actuator/health`, `/api-docs` nécessitent un JWT valide
- Le filtre `JwtAuthenticationFilter` s'exécute avant chaque requête
- Si le token est invalide/expiré, le `SecurityContext` reste vide → 403 Forbidden

### ✅ Filtrage automatique des données

- Les services ne dépendent **pas** de paramètres frontaux (agencyId en query param)
- Les données sont filtrées **côté backend** selon le rôle stocké dans le JWT
- Un AGENCY_ADMIN ne peut **jamais** accéder aux données d'une autre agence

### ✅ Hashage des mots de passe

- Utilisation de **BCrypt** (BCryptPasswordEncoder)
- Les mots de passe ne sont **jamais** stockés en clair

---

## 🔧 Configuration

### application.yml (Backend)

```yaml
jwt:
  secret: "sahabi-guide-super-secret-key-change-in-production-please-min-256-bits"
  expiration: 86400000  # 24 heures en millisecondes
```

**⚠️ IMPORTANT** : Changer la clé secrète en production !

---

## 📝 Points d'attention

### 1. Première connexion

Si la table `users_admin` est vide :
```sql
-- Exécuter le seed
psql -U postgres -d sahabi_guide -f SEED_ADMIN_USERS.sql
```

### 2. Token expiré

- Si le token expire (après 24h), l'utilisateur sera redirigé vers `/login`
- Le `AuthService.refreshProfile()` peut être appelé pour synchroniser le profil

### 3. SUPER_ADMIN et agencyId

- Un SUPER_ADMIN a `agencyId = null` dans son token
- Les services doivent gérer ce cas : `agencyId == null` → toutes les agences

### 4. Frontend: agencyId par défaut pour SUPER_ADMIN

Dans `MapPage.tsx`, on utilise une agence par défaut pour SUPER_ADMIN :
```typescript
const effectiveAgencyId = isSuperAdmin 
    ? '550e8400-e29b-41d4-a716-446655440001' // Agence par défaut
    : agencyId;
```

**Amélioration future** : Ajouter un sélecteur d'agence pour SUPER_ADMIN dans le header.

---

## ✅ Checklist de déploiement

- [ ] Changer `jwt.secret` dans `application.yml` (production)
- [ ] Créer les comptes admin réels (via AuthService.createAdmin() ou SQL)
- [ ] Supprimer les comptes de test du seed
- [ ] Activer HTTPS (certificat SSL)
- [ ] Configurer CORS correctement (pas `*` en production)
- [ ] Mettre en place un système de renouvellement de token (refresh token)
- [ ] Ajouter des logs d'audit pour les connexions/actions sensibles
- [ ] Implémenter le "mot de passe oublié" si nécessaire

---

## 🎉 Résultat final

✅ **Authentification JWT complète**  
✅ **Deux rôles distincts** (SUPER_ADMIN, AGENCY_ADMIN)  
✅ **Filtrage automatique** des données selon le rôle  
✅ **Page de login moderne** avec Chakra UI  
✅ **Routes protégées** avec redirection automatique  
✅ **Integration Map + Analytics** avec agencyId du profil  
✅ **Comptes de test** prêts à l'emploi  
✅ **Sécurité renforcée** (BCrypt, JWT, filtrage backend)  

---

📧 Pour toute question : voir le code ou contacter l'équipe technique.









