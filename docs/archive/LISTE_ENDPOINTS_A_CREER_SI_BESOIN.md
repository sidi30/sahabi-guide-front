# 📝 Liste des Endpoints Backend à créer (si besoin)

## 🎯 Contexte

Le Dashboard fonctionne **actuellement à 100%** avec les endpoints existants grâce à des fallbacks intelligents. Cependant, voici les endpoints qui **amélioreraient l'expérience** s'ils étaient créés.

---

## 🔴 Priorité HAUTE - Analytics Dashboard

### 1. `GET /api/v1/dashboard/analytics/daily`

**Objectif** : Fournir les statistiques d'utilisation quotidiennes pour les graphiques Dashboard.

**Paramètres** :
- `days` : Nombre de jours à récupérer (défaut: 7)
- `agencyId` (optionnel) : Filtrer par agence

**Réponse** :
```json
[
  {
    "date": "2025-01-24",
    "pilgrims": 150,
    "activeConnections": 120,
    "alerts": 5,
    "activities": 450
  },
  ...
]
```

**Impact** :
- Graphiques Dashboard plus précis
- Tendances réelles au lieu de données simulées

**Contrôleur suggéré** :
```java
@RestController
@RequestMapping("/api/v1/dashboard/analytics")
@RequiredArgsConstructor
public class DashboardAnalyticsController {

    private final DashboardAnalyticsService analyticsService;

    @GetMapping("/daily")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN')")
    public ResponseEntity<List<DailyStatsDto>> getDailyStats(
            @RequestParam(defaultValue = "7") int days,
            @RequestParam(required = false) UUID agencyId) {
        
        List<DailyStatsDto> stats = analyticsService.getDailyStats(days, agencyId);
        return ResponseEntity.ok(stats);
    }
}
```

---

### 2. `GET /api/v1/dashboard/analytics/hours`

**Objectif** : Statistiques horaires des dernières 24h.

**Réponse** :
```json
[
  {
    "hour": "2025-01-24T10:00:00Z",
    "activeUsers": 45,
    "apiCalls": 1200,
    "alerts": 2
  },
  ...
]
```

---

### 3. `GET /api/v1/dashboard/analytics/screens`

**Objectif** : Statistiques d'utilisation par écran (Dashboard, Pèlerins, Carte, etc.).

**Réponse** :
```json
[
  {
    "screen": "dashboard",
    "views": 1250,
    "avgTime": 45.5
  },
  {
    "screen": "pilgrims",
    "views": 980,
    "avgTime": 120.3
  },
  ...
]
```

**Note** : Nécessite un système de tracking des événements frontend (ex: Google Analytics, Mixpanel, ou custom).

---

## 🟡 Priorité MOYENNE - Notifications Dashboard

### 4. `GET /api/v1/notifications`

**Objectif** : Notifications système pour les utilisateurs Dashboard (différent des alertes pèlerins).

**Paramètres** :
- `unreadOnly` : Afficher uniquement les non lues (défaut: false)
- `page`, `size` : Pagination

**Réponse** :
```json
{
  "content": [
    {
      "id": "uuid",
      "title": "Nouvelle alerte critique",
      "message": "5 alertes non traitées depuis 1h",
      "type": "ALERT",
      "priority": "HIGH",
      "read": false,
      "createdAt": "2025-01-24T10:30:00Z",
      "link": "/alerts"
    }
  ],
  "totalElements": 10,
  "unreadCount": 3
}
```

**Contrôleur suggéré** :
```java
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Page<NotificationDto>> getNotifications(
            @RequestParam(defaultValue = "false") boolean unreadOnly,
            Pageable pageable,
            Authentication authentication) {
        
        String keycloakId = extractKeycloakId(authentication);
        Page<NotificationDto> notifications = notificationService.findByUser(keycloakId, unreadOnly, pageable);
        return ResponseEntity.ok(notifications);
    }

    @PutMapping("/{id}/read")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> markAsRead(@PathVariable UUID id, Authentication authentication) {
        String keycloakId = extractKeycloakId(authentication);
        notificationService.markAsRead(id, keycloakId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/read-all")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> markAllAsRead(Authentication authentication) {
        String keycloakId = extractKeycloakId(authentication);
        notificationService.markAllAsRead(keycloakId);
        return ResponseEntity.noContent().build();
    }
}
```

**Table BDD** :
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    keycloak_id VARCHAR(64) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type VARCHAR(50) NOT NULL, -- ALERT, INFO, WARNING, SYSTEM
    priority VARCHAR(20) DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH
    read BOOLEAN DEFAULT FALSE,
    link VARCHAR(500), -- URL de redirection
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_notifications_keycloak_id ON notifications(keycloak_id);
CREATE INDEX idx_notifications_read ON notifications(read);
```

---

### 5. `GET /api/v1/profile/preferences`

**Objectif** : Synchroniser les préférences Dashboard entre appareils (actuellement en localStorage).

**Réponse** :
```json
{
  "keycloakId": "uuid",
  "language": "fr",
  "theme": "dark",
  "mapStyle": "satellite",
  "notifImportant": true,
  "notifUrgent": true,
  "notifGeneral": false,
  "dashboardLayout": {
    "widgets": ["metrics", "alerts", "map"]
  }
}
```

**Contrôleur suggéré** :
```java
@RestController
@RequestMapping("/api/v1/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final UserProfileService profileService;

    @GetMapping("/preferences")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<UserPreferencesDto> getPreferences(Authentication authentication) {
        String keycloakId = extractKeycloakId(authentication);
        UserPreferencesDto prefs = profileService.getPreferences(keycloakId);
        return ResponseEntity.ok(prefs);
    }

    @PutMapping("/preferences")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<UserPreferencesDto> updatePreferences(
            @RequestBody UserPreferencesDto preferences,
            Authentication authentication) {
        String keycloakId = extractKeycloakId(authentication);
        UserPreferencesDto updated = profileService.savePreferences(keycloakId, preferences);
        return ResponseEntity.ok(updated);
    }
}
```

**Table BDD** : Utiliser la table `user_profile` déjà créée (voir `007-create-user-profile-table.xml`).

---

## 🟢 Priorité BASSE - Fonctionnalités avancées

### 6. `GET /api/v1/reports/agencies/{agencyId}`

**Objectif** : Rapport complet d'une agence (PDF/Excel).

**Paramètres** :
- `from`, `to` : Période du rapport
- `format` : `pdf` ou `excel`

**Réponse** : Fichier binaire (PDF ou Excel).

---

### 7. `GET /api/v1/reports/pilgrims/{pilgrimId}`

**Objectif** : Rapport détaillé d'un pèlerin (parcours, santé, rituels).

---

### 8. `GET /api/v1/audit/users`

**Objectif** : Historique des actions des utilisateurs Dashboard (audit trail).

**Réponse** :
```json
[
  {
    "id": "uuid",
    "keycloakId": "uuid",
    "username": "admin@sahabi.com",
    "action": "CREATE_PILGRIM",
    "entity": "Pilgrim",
    "entityId": "uuid",
    "changes": {
      "firstName": "Ahmed",
      "lastName": "Ibn Ali"
    },
    "timestamp": "2025-01-24T10:30:00Z",
    "ipAddress": "192.168.1.100"
  }
]
```

---

### 9. `GET /api/v1/system/health`

**Objectif** : État de santé du système (DB, Redis, services externes).

**Réponse** :
```json
{
  "status": "UP",
  "components": {
    "database": {
      "status": "UP",
      "responseTime": 15
    },
    "redis": {
      "status": "UP",
      "responseTime": 5
    },
    "keycloak": {
      "status": "UP",
      "responseTime": 120
    }
  }
}
```

---

## 📊 Récapitulatif des priorités

| Endpoint | Priorité | Impact | Effort Backend | Solution actuelle |
|----------|----------|--------|----------------|-------------------|
| `/dashboard/analytics/daily` | 🔴 Haute | ⭐⭐⭐⭐⭐ | 🔨🔨🔨 Moyen | Fallback intelligent |
| `/dashboard/analytics/hours` | 🔴 Haute | ⭐⭐⭐⭐ | 🔨🔨 Facile | Fallback intelligent |
| `/dashboard/analytics/screens` | 🟡 Moyenne | ⭐⭐⭐ | 🔨🔨🔨🔨 Difficile | Données simulées |
| `/notifications` | 🟡 Moyenne | ⭐⭐⭐⭐ | 🔨🔨🔨 Moyen | Utilise `/alerts` |
| `/profile/preferences` | 🟡 Moyenne | ⭐⭐⭐ | 🔨 Très facile | localStorage |
| `/reports/*` | 🟢 Basse | ⭐⭐ | 🔨🔨🔨🔨🔨 Difficile | N/A |
| `/audit/users` | 🟢 Basse | ⭐⭐ | 🔨🔨🔨🔨 Difficile | N/A |
| `/system/health` | 🟢 Basse | ⭐ | 🔨 Très facile | Spring Actuator |

---

## ✅ Ce qui existe déjà

**Ne PAS créer ces endpoints, ils existent déjà :**

- ✅ `/api/v1/dashboard/metrics/summary` - Métriques globales
- ✅ `/api/v1/auth/users` - Liste utilisateurs (avec filtres)
- ✅ `/api/v1/auth/agencies` - CRUD Agences
- ✅ `/api/v1/alerts` - Alertes
- ✅ `/api/v1/pilgrims/groups` - Groupes
- ✅ `/api/v1/geo/pois` - POIs
- ✅ `/api/v1/users/{userId}/positions` - Positions GPS
- ✅ `/api/v1/users/{userId}/route` - Parcours
- ✅ `/api/v1/pilgrims/{id}/activities` - Activités
- ✅ `/api/v1/pilgrims/{id}/timeline` - Timeline
- ✅ `/api/v1/pilgrims/{id}/health-profile` - Santé
- ✅ `/api/v1/pilgrims/contacts/{id}` - Contacts urgence
- ✅ `/api/v1/connectivity/*` - Connectivité eSIM

---

## 🎯 Recommandations

### Court terme (1-2 sprints) 🔴

**Créer en priorité :**
1. `/dashboard/analytics/daily` - Impact élevé, effort moyen
2. `/dashboard/analytics/hours` - Impact élevé, effort faible
3. `/notifications` - Impact élevé pour l'expérience utilisateur

### Moyen terme (3-6 mois) 🟡

**Si le besoin se confirme :**
1. `/profile/preferences` - Synchronisation multi-appareils
2. `/dashboard/analytics/screens` - Nécessite tracking frontend

### Long terme (>6 mois) 🟢

**Fonctionnalités avancées :**
1. Système de rapports PDF/Excel
2. Audit trail complet
3. Health checks avancés

---

## 💡 Note finale

**Le Dashboard fonctionne actuellement sans ces endpoints grâce aux fallbacks intelligents.**  

Les créer améliorerait l'expérience, mais ce n'est pas bloquant. Prioriser selon les besoins métier et les retours utilisateurs.

---

**Date** : 2025-01-24  
**Version** : 1.0  
**Auteur** : AI Assistant









