# 📋 Liste complète des Endpoints Backend disponibles

## 🎯 Vue d'ensemble

Ce document liste **tous les endpoints REST** disponibles dans le backend Spring Boot pour le Dashboard.

---

## 1. 👤 Utilisateurs & Authentification

### `/api/v1/auth/users`

| Méthode | Endpoint | Description | Rôles requis | Contrôleur |
|---------|----------|-------------|--------------|------------|
| `GET` | `/api/v1/auth/users` | Liste tous les utilisateurs | `SUPER_ADMIN`, `AGENCE_ADMIN` | `UserController` |
| `GET` | `/api/v1/auth/users?role=PILGRIM` | Liste par rôle (filtré) | `SUPER_ADMIN`, `AGENCE_ADMIN` | `UserController` |
| `GET` | `/api/v1/auth/users/{id}` | Détails d'un utilisateur | `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER` | `UserController` |
| `POST` | `/api/v1/auth/users` | Créer un utilisateur | `SUPER_ADMIN`, `AGENCE_ADMIN` | `UserController` |
| `PUT` | `/api/v1/auth/users/{id}` | Mettre à jour un utilisateur | `SUPER_ADMIN`, `AGENCE_ADMIN` | `UserController` |
| `DELETE` | `/api/v1/auth/users/{id}` | Supprimer un utilisateur | `SUPER_ADMIN` | `UserController` |
| `GET` | `/api/v1/auth/users/{id}/stats` | Statistiques utilisateur | `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER` | `UserController` |
| `GET` | `/api/v1/auth/users/{id}/rituals/progress` | Progression rituels | `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER` | `UserController` |
| `PUT` | `/api/v1/auth/users/{id}/rituals/{ritualId}` | MAJ progression rituel | `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER` | `UserController` |
| `GET` | `/api/v1/auth/users/{id}/alerts` | Alertes utilisateur | `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER` | `UserController` |
| `GET` | `/api/v1/auth/users/prayer-times` | Horaires de prière | `SUPER_ADMIN`, `AGENCE_ADMIN`, `AGENCE_USER` | `UserController` |

### Endpoints dépréciés (gardés pour compatibilité)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/auth/users/pilgrims` | Liste pèlerins (deprecated) |
| `GET` | `/api/v1/auth/users/guides` | Liste guides (deprecated) |
| `GET` | `/api/v1/auth/users/admins` | Liste admins (deprecated) |

---

## 2. 🏢 Agences

### `/api/v1/auth/agencies`

| Méthode | Endpoint | Description | Rôles requis |
|---------|----------|-------------|--------------|
| `GET` | `/api/v1/auth/agencies` | Liste des agences (paginée) | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `GET` | `/api/v1/auth/agencies/{id}` | Détails d'une agence | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `POST` | `/api/v1/auth/agencies` | Créer une agence | `SUPER_ADMIN` |
| `PUT` | `/api/v1/auth/agencies/{id}` | Mettre à jour une agence | `SUPER_ADMIN` |
| `DELETE` | `/api/v1/auth/agencies/{id}` | Supprimer une agence | `SUPER_ADMIN` |

---

## 3. 📊 Dashboard & Métriques

### `/api/v1/dashboard`

| Méthode | Endpoint | Description | Rôles requis |
|---------|----------|-------------|--------------|
| `GET` | `/api/v1/dashboard/metrics/summary` | Résumé des métriques globales | `SUPER_ADMIN`, `AGENCE_ADMIN` |

---

## 4. 🚨 Alertes

### `/api/v1/alerts`

| Méthode | Endpoint | Description | Rôles requis |
|---------|----------|-------------|--------------|
| `GET` | `/api/v1/alerts` | Liste toutes les alertes (filtrables) | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `POST` | `/api/v1/alerts` | Créer une alerte | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `GET` | `/api/v1/pilgrims/{pilgrimId}/alerts` | Alertes d'un pèlerin (mobile + dashboard) | Aucun (partagé) |

**Paramètres de filtrage** pour `GET /api/v1/alerts` :
- `status` : `ACTIVE`, `ACK`, `RESOLVED`
- `pilgrimId` : UUID du pèlerin
- `page`, `size` : Pagination

---

## 5. 👥 Groupes

### `/api/v1/pilgrims/groups`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/pilgrims/groups` | Liste des groupes (paginée) |
| `GET` | `/api/v1/pilgrims/groups/{id}` | Détails d'un groupe |
| `POST` | `/api/v1/pilgrims/groups` | Créer un groupe |
| `PUT` | `/api/v1/pilgrims/groups/{id}` | Mettre à jour un groupe |
| `DELETE` | `/api/v1/pilgrims/groups/{id}` | Supprimer un groupe |

---

## 6. 🗺️ Géolocalisation & POIs

### `/api/v1/geo/pois`

| Méthode | Endpoint | Description | Rôles requis |
|---------|----------|-------------|--------------|
| `GET` | `/api/v1/geo/pois` | Liste des POIs (filtrables) | Aucun (partagé) |
| `GET` | `/api/v1/geo/pois/{id}` | Détails d'un POI | Aucun (partagé) |
| `POST` | `/api/v1/geo/pois` | Créer un POI | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `PUT` | `/api/v1/geo/pois/{id}` | Mettre à jour un POI | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `DELETE` | `/api/v1/geo/pois/{id}` | Supprimer un POI | `SUPER_ADMIN` |

**Paramètres de filtrage** :
- `agencyId` : UUID de l'agence
- `type` : Type de POI (e.g., `HOTEL`, `MOSQUE`, `HOSPITAL`)
- `lat`, `lng`, `radius` : Recherche géographique

### `/api/v1/geo/hotels`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/geo/hotels/{pilgrimId}` | Hôtel d'un pèlerin |

---

## 7. 📍 Positions GPS

### `/api/v1/users/{userId}/positions`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `POST` | `/api/v1/users/{userId}/positions` | Enregistrer une position |
| `GET` | `/api/v1/users/{userId}/position/latest` | Dernière position |
| `GET` | `/api/v1/users/{userId}/positions` | Historique positions (paginé) |
| `GET` | `/api/v1/users/{userId}/positions/last?count=10` | N dernières positions |
| `GET` | `/api/v1/users/{userId}/positions/count` | Nombre de positions |
| `DELETE` | `/api/v1/users/{userId}/positions` | Supprimer toutes les positions |
| `DELETE` | `/api/v1/users/{userId}/positions/before?before=...` | Supprimer anciennes positions |

**Paramètres de filtrage** pour `GET /api/v1/users/{userId}/positions` :
- `page`, `size` : Pagination
- `since` : Depuis une date
- `from`, `to` : Période

### `/api/v1/agencies/{agencyId}/positions`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/agencies/{agencyId}/positions/latest` | Dernières positions de tous les utilisateurs d'une agence |

---

## 8. 🛤️ Parcours & Statistiques

### `/api/v1/users/{userId}/route`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/users/{userId}/route?from=...&to=...` | Parcours entre deux dates |
| `GET` | `/api/v1/users/{userId}/route/statistics?from=...&to=...` | Statistiques de parcours |
| `GET` | `/api/v1/users/{userId}/route/today` | Parcours du jour |
| `GET` | `/api/v1/users/{userId}/route/today/statistics` | Statistiques du jour |

---

## 9. 📱 Activités & Timeline

### `/api/v1/pilgrims/{id}`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/pilgrims/{id}/activities` | Activités du pèlerin (filtrables) |
| `GET` | `/api/v1/pilgrims/{id}/timeline` | Timeline du pèlerin |
| `GET` | `/api/v1/pilgrims/{id}/map` | Carte GeoJSON des activités |

**Paramètres de filtrage** :
- `type` : Type d'activité
- `from`, `to` : Période

---

## 10. 🕌 Rituels & Duas

### `/api/v1/rituals`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/rituals` | Liste des rituels |

### `/api/v1/duas`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/duas` | Liste des invocations |

---

## 11. 🏥 Carnet de santé

### `/api/v1/pilgrims/{id}/health-profile`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/pilgrims/{id}/health-profile` | Carnet de santé |
| `PUT` | `/api/v1/pilgrims/{id}/health-profile` | Mettre à jour le carnet |

---

## 12. 📞 Contacts d'urgence

### `/api/v1/pilgrims/contacts/{id}`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/pilgrims/contacts/{id}` | Liste contacts d'urgence |
| `POST` | `/api/v1/pilgrims/contacts/{id}` | Ajouter un contact |
| `PUT` | `/api/v1/pilgrims/contacts/{contactId}` | Modifier un contact |
| `DELETE` | `/api/v1/pilgrims/contacts/{contactId}` | Supprimer un contact |

---

## 13. 📡 Connectivité eSIM

### `/api/v1/connectivity`

| Méthode | Endpoint | Description | Rôles requis |
|---------|----------|-------------|--------------|
| `GET` | `/api/v1/connectivity/plans` | Liste des plans eSIM | Aucun (partagé) |
| `GET` | `/api/v1/connectivity/subscriptions` | Liste des souscriptions | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `POST` | `/api/v1/connectivity/subscriptions` | Créer une souscription | `SUPER_ADMIN`, `AGENCE_ADMIN` |
| `POST` | `/api/v1/connectivity/subscriptions/{id}/topups` | Créer un rechargement | `SUPER_ADMIN`, `AGENCE_ADMIN` |

---

## 14. 🤖 Assistant conversationnel

### `/api/v1/assistant`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/assistant/steps` | Toutes les étapes de conversation |
| `GET` | `/api/v1/assistant/steps/{stepCode}` | Étape par code |
| `POST` | `/api/v1/assistant/sessions/{userId}/start` | Démarrer/Reprendre session |
| `GET` | `/api/v1/assistant/sessions/{userId}/current` | Session active |
| `POST` | `/api/v1/assistant/progress/{userId}/answer` | Enregistrer réponse |
| `POST` | `/api/v1/assistant/progress/{userId}/sync` | Synchro réponses offline |
| `GET` | `/api/v1/assistant/progress/{userId}` | Progression utilisateur |
| `GET` | `/api/v1/assistant/steps/{stepId}/next` | Étape suivante |

---

## 15. 📝 Paramètres utilisateur

### `/api/v1/settings/user-settings`

*(À vérifier - contrôleur `UserSettingsController`)*

---

## 16. 💬 Messages de contact

### `/api/v1/settings/contact-messages`

*(À vérifier - contrôleur `ContactMessageController`)*

---

## 17. 🔐 Auth Mobile (Passeport + OTP)

### `/api/auth/passport`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `POST` | `/api/auth/passport/login` | Login par passeport (envoie OTP) |
| `POST` | `/api/auth/passport/verify` | Vérifier OTP |
| `POST` | `/api/auth/passport/resend` | Renvoyer OTP |
| `POST` | `/api/auth/passport/logout` | Déconnexion mobile |

**Note** : Endpoints **Mobile uniquement** (pas pour Dashboard)

---

## 18. 🔐 Auth Dashboard (Keycloak - Désactivé)

### `/api/auth/backoffice`

| Méthode | Endpoint | Description | Status |
|---------|----------|-------------|--------|
| `POST` | `/api/auth/backoffice/login` | Login local | ❌ Désactivé (410 Gone) |
| `POST` | `/api/auth/backoffice/logout` | Logout local | ❌ Désactivé (410 Gone) |

**Note** : Remplacé par Keycloak OAuth2

---

## 19. 📦 Inscriptions Pèlerins

### `/api/pilgrims`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `POST` | `/api/pilgrims/register` | Inscription pèlerin (Mobile) |
| `PUT` | `/api/pilgrims/{pilgrimId}` | Modifier inscription |

---

## 📊 Résumé

### Endpoints Dashboard disponibles : ~60+
### Endpoints Mobile : ~30+
### Endpoints Partagés : ~15

---

## 🚧 Endpoints potentiellement manquants

### 1. Analytics Dashboard
- ❌ `GET /api/v1/dashboard/analytics/daily` - Données quotidiennes
- ❌ `GET /api/v1/dashboard/analytics/hours` - Données horaires
- ❌ `GET /api/v1/dashboard/analytics/screens` - Données écrans

### 2. Export de données
- ❌ `GET /api/v1/pilgrims/export?format=csv` - Export CSV
- ❌ `GET /api/v1/pilgrims/export?format=excel` - Export Excel

### 3. Profil utilisateur Dashboard
- ⚠️ Pas d'endpoint dédié (géré par Keycloak token)
- ❌ `GET /api/v1/profile/preferences` - Préférences Dashboard
- ❌ `PUT /api/v1/profile/preferences` - MAJ préférences

### 4. Notifications Dashboard
- ❌ `GET /api/v1/notifications` - Liste notifications Dashboard
- ❌ `PUT /api/v1/notifications/{id}/read` - Marquer comme lu

### 5. Rapports & Statistiques avancées
- ❌ `GET /api/v1/reports/agencies/{agencyId}` - Rapport agence
- ❌ `GET /api/v1/reports/pilgrims/{pilgrimId}` - Rapport pèlerin

---

**Date** : 2025-01-24  
**Version** : 1.0  
**Auteur** : AI Assistant









