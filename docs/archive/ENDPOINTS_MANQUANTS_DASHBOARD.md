# 🚧 Endpoints Backend manquants pour le Dashboard

## 🎯 Objectif

Ce document liste les endpoints qui **devraient exister** dans le backend mais qui sont **absents ou incomplets**, basé sur l'analyse des services Frontend Dashboard.

---

## 1. ❌ Analytics Dashboard

### Problème
Le `AnalyticsService.ts` appelle des endpoints qui n'existent pas :

```typescript
// ❌ Endpoint inexistant
GET /api/v1/dashboard/analytics/daily?days=7
GET /api/v1/dashboard/analytics/hours
GET /api/v1/dashboard/analytics/screens
```

### Solution recommandée

**Option A** : Utiliser les données réelles disponibles
- Remplacer par les statistiques depuis `/api/v1/dashboard/metrics/summary`
- Agréger les données des pèlerins, alertes, positions

**Option B** : Créer les endpoints manquants
Créer un contrôleur `DashboardAnalyticsController` :

```java
@RestController
@RequestMapping("/api/v1/dashboard/analytics")
public class DashboardAnalyticsController {
    
    @GetMapping("/daily")
    public List<UsagePoint> getDailyStats(@RequestParam(defaultValue = "7") int days) {
        // Retourner stats quotidiennes des 7 derniers jours
    }
    
    @GetMapping("/hours")
    public List<UsagePoint> getHourlyStats() {
        // Retourner stats des dernières 24h
    }
    
    @GetMapping("/screens")
    public List<UsagePoint> getScreenStats() {
        // Retourner stats d'utilisation par écran
    }
}
```

---

## 2. ❌ Export de données (CSV/Excel)

### Problème
Le `ExportsService.ts` n'est pas implémenté correctement :

```typescript
// ❌ Endpoint inexistant
GET /api/v1/pilgrims/export?format=csv&agencyId=...
GET /api/v1/pilgrims/export?format=excel
```

### Solution recommandée

**Option A** : Export côté frontend
- Récupérer les données via `/api/v1/auth/users?role=PILGRIM`
- Utiliser une bibliothèque comme `papaparse` (CSV) ou `xlsx` (Excel) côté React

**Option B** : Créer les endpoints d'export
Ajouter dans `UserController` ou créer `ExportController` :

```java
@GetMapping("/export")
public ResponseEntity<byte[]> exportPilgrims(
    @RequestParam(defaultValue = "csv") String format,
    @RequestParam(required = false) UUID agencyId) {
    
    List<UserDto> pilgrims = userService.findByRoleAndAgency(UserRole.PILGRIM, agencyId);
    
    if ("csv".equals(format)) {
        byte[] csv = exportService.toCsv(pilgrims);
        return ResponseEntity.ok()
            .header("Content-Disposition", "attachment; filename=pilgrims.csv")
            .contentType(MediaType.parseMediaType("text/csv"))
            .body(csv);
    }
    
    // Excel...
}
```

---

## 3. ⚠️ Profil & Préférences Dashboard

### Problème
Pas d'endpoint dédié pour stocker les préférences Dashboard (langue, thème, notifications).

### Solution actuelle ✅
Les préférences sont stockées dans `localStorage` côté frontend via `ProfileService`.

### Solution recommandée (optionnelle)

Si on veut synchroniser les préférences entre appareils :

```java
@RestController
@RequestMapping("/api/v1/profile")
public class ProfileController {
    
    @GetMapping("/preferences")
    public UserPreferences getPreferences() {
        String keycloakId = SecurityContextHolder.get...;
        return preferencesService.findByKeycloakId(keycloakId);
    }
    
    @PUT("/preferences")
    public UserPreferences updatePreferences(@RequestBody UserPreferences prefs) {
        String keycloakId = SecurityContextHolder.get...;
        return preferencesService.save(keycloakId, prefs);
    }
}
```

**Table BDD** : `user_profile` (déjà créée via Liquibase)

---

## 4. ❌ Notifications Dashboard

### Problème
Pas d'endpoints pour gérer les notifications côté Dashboard :

```typescript
// ❌ Endpoint inexistant
GET /api/v1/notifications
PUT /api/v1/notifications/{id}/read
```

### Solution recommandée

**Option A** : Utiliser les Alertes existantes
- Réutiliser `/api/v1/alerts` pour les notifications Dashboard
- Filtrer par type : `SYSTEM`, `INFO`, `WARNING`

**Option B** : Créer un système de notifications dédié

```java
@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {
    
    @GetMapping
    public List<NotificationDto> getNotifications(
        @RequestParam(defaultValue = "false") boolean unreadOnly) {
        // Notifications pour l'utilisateur connecté (Keycloak)
    }
    
    @PutMapping("/{id}/read")
    public NotificationDto markAsRead(@PathVariable UUID id) {
        // Marquer comme lue
    }
}
```

---

## 5. ❌ Rapports & Statistiques avancées

### Problème
Pas d'endpoints pour générer des rapports détaillés.

### Solution recommandée

Créer un `ReportsController` :

```java
@RestController
@RequestMapping("/api/v1/reports")
public class ReportsController {
    
    @GetMapping("/agencies/{agencyId}")
    public AgencyReportDto getAgencyReport(
        @PathVariable UUID agencyId,
        @RequestParam Instant from,
        @RequestParam Instant to) {
        // Rapport complet agence : pèlerins, alertes, parcours, etc.
    }
    
    @GetMapping("/pilgrims/{pilgrimId}")
    public PilgrimReportDto getPilgrimReport(
        @PathVariable UUID pilgrimId,
        @RequestParam Instant from,
        @RequestParam Instant to) {
        // Rapport détaillé pèlerin : activités, santé, parcours, etc.
    }
}
```

---

## 6. ⚠️ Métriques Dashboard incomplètes

### Problème
L'endpoint `/api/v1/dashboard/metrics/summary` existe mais pourrait être enrichi.

### Données actuelles ✅
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

### Données potentiellement manquantes
- `activeUsers` : Nombre d'utilisateurs actifs (Dashboard)
- `totalAgencies` : Nombre d'agences
- `totalGroups` : Nombre de groupes
- `recentActivities` : Dernières activités récentes
- `systemHealth` : État du système (DB, Redis, etc.)

### Solution recommandée

Enrichir le `DashboardService` existant pour ajouter ces métriques.

---

## 7. ❌ Gestion des groupes (Dashboard)

### Problème
L'endpoint `/api/v1/pilgrims/groups` existe mais :
- Pas de filtrage par agence
- Pas de recherche
- Pas d'ajout/retrait de pèlerins

### Solution recommandée

Enrichir le `GroupController` :

```java
@GetMapping
public PagedGroup listGroups(
    @RequestParam(required = false) UUID agencyId,  // ✅ Ajouter
    @RequestParam(required = false) String search,  // ✅ Ajouter
    @RequestParam(defaultValue = "0") Integer page,
    @RequestParam(defaultValue = "20") Integer size) {
    // ...
}

@PostMapping("/{groupId}/pilgrims/{pilgrimId}")  // ✅ Ajouter
public void addPilgrimToGroup(@PathVariable UUID groupId, @PathVariable UUID pilgrimId) {
    groupService.addPilgrim(groupId, pilgrimId);
}

@DeleteMapping("/{groupId}/pilgrims/{pilgrimId}")  // ✅ Ajouter
public void removePilgrimFromGroup(@PathVariable UUID groupId, @PathVariable UUID pilgrimId) {
    groupService.removePilgrim(groupId, pilgrimId);
}
```

---

## 8. ⚠️ Historique des modifications (Audit)

### Problème
Pas d'endpoints pour voir l'historique des modifications (audit trail).

### Solution recommandée

Si besoin d'audit détaillé :

```java
@GetMapping("/audit/pilgrims/{pilgrimId}")
public List<AuditLogDto> getPilgrimAuditLog(@PathVariable UUID pilgrimId) {
    // Historique des modifications du pèlerin
}

@GetMapping("/audit/users")
public List<AuditLogDto> getUsersAuditLog(
    @RequestParam(required = false) Instant from,
    @RequestParam(required = false) Instant to) {
    // Historique des actions utilisateurs Dashboard
}
```

---

## 📊 Résumé des priorités

| Endpoint manquant | Priorité | Solution recommandée |
|-------------------|----------|----------------------|
| Analytics Dashboard | 🔴 Haute | Option A : Réutiliser métriques existantes |
| Export CSV/Excel | 🟡 Moyenne | Option A : Export côté frontend |
| Notifications Dashboard | 🟡 Moyenne | Option A : Réutiliser alertes existantes |
| Profil/Préférences | 🟢 Basse | ✅ Déjà implémenté (localStorage) |
| Rapports avancés | 🟢 Basse | Créer si besoin futur |
| Audit trail | 🟢 Basse | Créer si besoin futur |

---

## ✅ Ce qui existe déjà et fonctionne

- ✅ Dashboard métriques (`/api/v1/dashboard/metrics/summary`)
- ✅ Liste utilisateurs avec filtres
- ✅ CRUD Agences
- ✅ CRUD Groupes
- ✅ Alertes (liste, création)
- ✅ POIs (liste, CRUD)
- ✅ Positions GPS (historique, dernière position)
- ✅ Parcours & statistiques
- ✅ Activités & timeline
- ✅ Santé & contacts d'urgence
- ✅ Rituels & Duas
- ✅ Connectivité eSIM

---

## 🎯 Actions recommandées

### Immédiat (sans modification backend)
1. **Analytics** : Utiliser les données existantes depuis `/dashboard/metrics/summary`
2. **Export** : Implémenter l'export CSV/Excel côté React
3. **Notifications** : Utiliser `/api/v1/alerts` pour les notifications Dashboard
4. **Profil** : Continuer d'utiliser `localStorage` + token Keycloak

### Court terme (modifications backend légères)
1. Enrichir `/dashboard/metrics/summary` avec plus de métriques
2. Ajouter filtrage par agence dans `GET /pilgrims/groups`
3. Ajouter endpoints `/groups/{id}/pilgrims` (add/remove)

### Long terme (si besoin)
1. Créer `DashboardAnalyticsController` pour stats détaillées
2. Créer `ReportsController` pour rapports PDF/Excel
3. Créer système de notifications dédié
4. Implémenter audit trail complet

---

**Date** : 2025-01-24  
**Version** : 1.0  
**Auteur** : AI Assistant









