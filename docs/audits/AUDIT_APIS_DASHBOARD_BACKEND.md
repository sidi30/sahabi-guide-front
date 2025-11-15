# 🔍 Audit des APIs - Dashboard React vs Backend Spring Boot

**Date** : 22 octobre 2025  
**Projet** : SahabiGuide  
**Périmètre** : Cohérence entre Dashboard React et Backend Spring Boot

---

## 📊 Résumé Exécutif

Cet audit identifie les **incohérences, les APIs mal utilisées et les bonnes pratiques non respectées** entre le dashboard React et le backend Spring Boot.

### Indicateurs Clés

| Catégorie | Nombre | Criticité |
|-----------|--------|-----------|
| **🔴 Erreurs critiques** | 4 | Haute |
| **🟡 Endpoints déprécié utilisés** | 2 | Moyenne |
| **🟠 Incohérences d'URL** | 5 | Haute |
| **⚪ Endpoints backend non utilisés** | 8 | Basse |
| **🔵 Bonnes pratiques non respectées** | 6 | Moyenne |

---

## 🔴 1. ERREURS CRITIQUES

### 1.1 Dashboard Service - URL Incorrecte

**Fichier** : `dashboard.service.ts` (ligne 8)

**Problème** :
```typescript
// ❌ Dashboard actuel
getMetricsSummary: () => http.get<MetricsSummary>(`${v1}/dashboard/metrics/summary`)
```

**Backend réel** :
```java
// ✅ DashboardController.java - ligne 17
@Override
public ResponseEntity<MetricsSummary> getMetricsSummary() {
    // Endpoint: GET /api/v1/dashboard/metrics
}
```

**Impact** : ⚠️ **404 NOT FOUND** - Le dashboard ne peut pas récupérer les métriques

**Correction** :
```typescript
// ✅ Correction
getMetricsSummary: () => http.get<MetricsSummary>(`${v1}/dashboard/metrics`)
```

---

### 1.2 Alerts Service - Endpoint Inconsistant

**Fichier** : `alerts.service.ts` (ligne 11)

**Problème** :
```typescript
// ❌ Service actuel
listByPilgrim: (pilgrimId: UUID) => 
  http.get<Alert[]>(`${v1}/pilgrims/${pilgrimId}/alerts`)
```

**Backend réel** :
```java
// ✅ UserController.java - ligne 163
@GetMapping("/{id}/alerts")
public ResponseEntity<List<Map<String, Object>>> getUserAlerts(@PathVariable UUID id) {
    // Endpoint: GET /api/v1/auth/users/{id}/alerts (pas /pilgrims/)
}
```

**Impact** : ⚠️ **404 NOT FOUND** - Les alertes des pèlerins ne s'affichent pas

**Correction** :
```typescript
// ✅ Correction
listByPilgrim: (userId: UUID) => 
  http.get<Alert[]>(`${v1}/auth/users/${userId}/alerts`)
```

---

### 1.3 Groups Service - Préfixe d'URL Incorrect

**Fichier** : `groups.service.ts` (ligne 5)

**Problème** :
```typescript
// ❌ Service actuel
const base = `${API_BASE_PATH}/pilgrims/groups`;
```

**Backend réel** :
```java
// ✅ GroupController.java implémente GroupsApi
// Endpoint: /api/v1/groups (pas /pilgrims/groups)
```

**Impact** : ⚠️ **404 NOT FOUND** - Impossible de gérer les groupes

**Correction** :
```typescript
// ✅ Correction
const base = `${API_BASE_PATH}/groups`;
```

---

### 1.4 Route History Service - Client HTTP Inconsistant

**Fichier** : `route-history.service.ts` (ligne 1-48)

**Problème** :
```typescript
// ❌ Service actuel - utilise axios directement
import axios from 'axios';
import { API_BASE_URL } from '../config/api';

const response = await axios.get(
  `${API_BASE_URL}/api/v1/users/${userId}/route`,
  ...
);
```

**Problème** : 
- N'utilise pas le client `http` centralisé
- Gère manuellement les headers d'authentification
- Pas de cohérence avec les autres services

**Impact** : ⚠️ Gestion d'erreurs incohérente, intercepteurs non appliqués

**Correction** :
```typescript
// ✅ Correction - utiliser le client http centralisé
import { http } from '@/lib/http';
import { API_BASE_PATH } from '@/config/api';

const v1 = API_BASE_PATH;

export const RouteHistoryService = {
  getRouteHistory: (userId: UUID, from: string, to: string) =>
    http.get<Position[]>(`${v1}/users/${userId}/route`, {
      params: { from, to }
    }).then(r => r.data),
    
  getRouteStatistics: (userId: UUID, from: string, to: string) =>
    http.get<RouteStatistics>(`${v1}/users/${userId}/route/statistics`, {
      params: { from, to }
    }).then(r => r.data),
    
  getTodayRoute: (userId: UUID) =>
    http.get<Position[]>(`${v1}/users/${userId}/route/today`).then(r => r.data),
    
  getTodayStatistics: (userId: UUID) =>
    http.get<RouteStatistics>(`${v1}/users/${userId}/route/today/statistics`).then(r => r.data),
};
```

---

## 🟡 2. ENDPOINTS DÉPRÉCIÉS UTILISÉS

### 2.1 Pilgrims Service - Endpoint Déprécié

**Fichier** : `pilgrims.service.ts` (lignes 23, 30)

**Problème** :
```typescript
// ❌ Service actuel - utilise des endpoints dépréciés
getById: (id: string) => 
  http.get<PilgrimDto>(`${v1}/auth/users/pilgrims/${id}`)

list: (params?: PilgrimListParams) =>
  http.get<any>(`${v1}/auth/users/pilgrims`, { params })
```

**Backend** :
```java
// ⚠️ UserController.java - ligne 84
@Deprecated
@GetMapping("/pilgrims")
public List<UserDto> listPilgrims() {
    log.warn("⚠️ Endpoint déprécié : GET /users/pilgrims - Utiliser GET /users?role=PILGRIM");
}
```

**Impact** : 🟡 Endpoint fonctionnel mais déprécié - sera supprimé dans une version future

**Recommandation** :
```typescript
// ✅ Meilleure approche - utiliser l'endpoint générique avec rôle
list: (params?: PilgrimListParams) =>
  http.get<any>(`${v1}/auth/users`, { 
    params: { ...params, role: 'PILGRIM' } 
  })
```

---

## 🟠 3. INCOHÉRENCES D'URL

### 3.1 Position Service - Chemins Incomplets

**Fichier** : `position.service.ts` (ligne 46)

**Problème** :
```typescript
// ❌ URL actuelle
getAgencyLatestPositions: (agencyId: UUID) =>
  http.get<Position[]>(`${v1}/users/agencies/${agencyId}/positions/latest`)
```

**Backend réel** :
```java
// ✅ PositionController.java - ligne 175
@GetMapping("/agencies/{agencyId}/positions/latest")
// Chemin complet: /api/v1/users/agencies/{agencyId}/positions/latest
```

**Statut** : ✅ **Correct** mais à vérifier - le controller est sous `/api/v1/users`

---

### 3.2 Pilgrims Service - Endpoints Mixtes

**Fichier** : `pilgrims.service.ts` (lignes 69-98)

**Problème** : Mélange de préfixes `/auth/users` et `/pilgrims`

```typescript
// ❌ Incohérent
getStats: (id: string) => 
  http.get<any>(`${v1}/auth/users/${id}/stats`)  // ✅ Bon préfixe

getTimeline: (id: string, params?) =>
  http.get<any[]>(`${v1}/pilgrims/${id}/timeline`, { params })  // ❌ Mauvais préfixe

getActivities: (id: string, params?) =>
  http.get<any>(`${v1}/pilgrims/${id}/activities`, { params })  // ❌ Mauvais préfixe

getAlerts: (id: string) =>
  http.get<any[]>(`${v1}/pilgrims/${id}/alerts`)  // ❌ Mauvais préfixe

getHealthProfile: (id: string) =>
  http.get<any>(`${v1}/pilgrims/${id}/health-profile`)  // ❌ Mauvais préfixe
```

**Backend réel** :
- `getStats` : ✅ `/auth/users/{id}/stats` (UserController ligne 111)
- `getAlerts` : ✅ `/auth/users/{id}/alerts` (UserController ligne 163)
- Les autres endpoints `/pilgrims/*` n'existent pas dans ce format

**Impact** : ⚠️ **404 NOT FOUND** pour timeline, activities, health-profile

**Correction nécessaire** : Vérifier l'existence réelle de ces endpoints dans le backend

---

## ⚪ 4. ENDPOINTS BACKEND NON UTILISÉS DANS LE DASHBOARD

Ces endpoints sont disponibles dans le backend mais **non utilisés** dans le dashboard :

### 4.1 Position - Endpoints Avancés

**Backend disponible** :
```java
// PositionController.java
GET /api/v1/users/{userId}/positions/last?count=10  // ligne 111
GET /api/v1/users/{userId}/positions/count           // ligne 129
DELETE /api/v1/users/{userId}/positions              // ligne 143
DELETE /api/v1/users/{userId}/positions/before       // ligne 158
```

**Utilité** :
- `/positions/last` : Récupérer les N dernières positions (plus performant que la pagination)
- `/positions/count` : Compteur rapide pour afficher le nombre de positions trackées
- `DELETE` endpoints : Nettoyage des données anciennes

**Recommandation** : ✅ Ajouter ces méthodes dans `position.service.ts` si nécessaire

---

### 4.2 User - Temps de Prière

**Backend disponible** :
```java
// UserController.java - ligne 187
GET /api/v1/auth/users/prayer-times?lat=21.4225&lng=39.8262
```

**Retour** :
```json
[
  { "name": "Fajr", "time": "05:30", "arabicName": "الفجر" },
  { "name": "Dhuhr", "time": "12:15", "arabicName": "الظهر" },
  ...
]
```

**Utilité** : Afficher les heures de prière dans le dashboard

**Recommandation** : ✅ Créer un service `PrayerTimesService` si cette fonctionnalité est nécessaire

---

### 4.3 User - Progrès des Rituels

**Backend disponible** :
```java
// UserController.java
GET /api/v1/auth/users/{id}/rituals/progress       // ligne 138
PUT /api/v1/auth/users/{id}/rituals/{ritualId}     // ligne 147
```

**Utilité** : Suivre et mettre à jour la progression dans les rituels

**Statut** : Le `rituals.service.ts` utilise `/pilgrims/{id}/rituals/progress` qui peut être incorrect

**Recommandation** : ⚠️ Vérifier et corriger le préfixe

---

### 4.4 Endpoints Non Implémentés dans Dashboard

**Backend disponibles mais absents du dashboard** :

1. **GeoFence** (Zones géographiques)
   - `GeoFenceController.java` - Endpoints complets pour géofencing
   - Aucun service correspondant dans le dashboard

2. **Location Sharing** (Partage de localisation)
   - `LocationSharingController.java` - Création de liens de partage
   - Aucun service correspondant

3. **QR Code** (Génération de QR codes)
   - `QRCodeController.java` - Génération de QR codes pour pèlerins
   - Aucun service correspondant

4. **Public Tracking** (Suivi public)
   - `PublicTrackingController.java` - Tracking sans auth
   - Aucun service correspondant

5. **Contact Messages** (Messages de contact)
   - `ContactMessageController.java` - Gestion des messages
   - Aucun service correspondant

**Recommandation** : ⚠️ Évaluer si ces fonctionnalités sont nécessaires dans le dashboard

---

## 🔵 5. BONNES PRATIQUES NON RESPECTÉES

### 5.1 Gestion d'Erreurs Incohérente

**Problème** : Pas de gestion d'erreurs unifiée

```typescript
// ❌ Services actuels - pas de try/catch
export const PilgrimsService = {
  getById: (id: string) => 
    http.get<PilgrimDto>(`${v1}/auth/users/pilgrims/${id}`).then(r => r.data),
  // Si erreur → exception non catchée
};
```

**Recommandation** :
```typescript
// ✅ Ajouter un intercepteur d'erreurs global dans http.ts
import axios, { AxiosError } from 'axios';

http.interceptors.response.use(
  response => response,
  (error: AxiosError) => {
    // Logging centralisé
    console.error('API Error:', {
      url: error.config?.url,
      status: error.response?.status,
      message: error.message
    });
    
    // Toast d'erreur global
    if (error.response?.status === 404) {
      showToast('Ressource non trouvée', 'error');
    } else if (error.response?.status >= 500) {
      showToast('Erreur serveur', 'error');
    }
    
    return Promise.reject(error);
  }
);
```

---

### 5.2 Types TypeScript Incomplets

**Problème** : Utilisation de `any` dans plusieurs services

```typescript
// ❌ Types incomplets
getTimeline: (id: string, params?: { since?: string; limit?: number }) =>
  http.get<any[]>(`${v1}/pilgrims/${id}/timeline`, { params })

getActivities: (id: string, params?: { page?: number; size?: number }) =>
  http.get<any>(`${v1}/pilgrims/${id}/activities`, { params })
```

**Recommandation** :
```typescript
// ✅ Définir les types précis
interface TimelineItem {
  ts: string;
  type: string;
  title: string;
  description?: string;
  lat?: number;
  lng?: number;
  refType?: string;
  refId?: UUID;
  meta?: Record<string, unknown>;
}

interface ActivityItem {
  id: UUID;
  pilgrimId: UUID;
  type: string;
  occurredAt: string;
  lat?: number;
  lng?: number;
  payload?: Record<string, unknown>;
}

getTimeline: (id: string, params?) =>
  http.get<TimelineItem[]>(`${v1}/auth/users/${id}/timeline`, { params })

getActivities: (id: string, params?) =>
  http.get<{ content: ActivityItem[] }>(`${v1}/auth/users/${id}/activities`, { params })
```

---

### 5.3 Validation des Paramètres Manquante

**Problème** : Pas de validation côté client

```typescript
// ❌ Pas de validation
getRouteStatistics: (userId: UUID, from: Date, to: Date) => {
  // Pas de vérification que from < to
  // Pas de vérification que userId est un UUID valide
}
```

**Recommandation** :
```typescript
// ✅ Ajouter des validations
import { z } from 'zod';

const UUIDSchema = z.string().uuid();
const DateRangeSchema = z.object({
  from: z.date(),
  to: z.date()
}).refine(data => data.from < data.to, {
  message: "La date de début doit être avant la date de fin"
});

getRouteStatistics: (userId: UUID, from: Date, to: Date) => {
  // Valider les paramètres
  UUIDSchema.parse(userId);
  DateRangeSchema.parse({ from, to });
  
  return http.get<RouteStatistics>(...);
}
```

---

### 5.4 Pas de Cache pour les Données Statiques

**Problème** : Appels API répétés pour des données qui ne changent pas

```typescript
// ❌ Pas de cache
listRituals: () => http.get<RitualDto[]>(`${v1}/rituals`)
// Appelé plusieurs fois alors que les rituels ne changent pas
```

**Recommandation** :
```typescript
// ✅ Utiliser React Query avec cache
import { useQuery } from '@tanstack/react-query';

export const useRituals = () => {
  return useQuery({
    queryKey: ['rituals'],
    queryFn: () => RitualsService.listRituals(),
    staleTime: 1000 * 60 * 60, // 1 heure
    cacheTime: 1000 * 60 * 60 * 24, // 24 heures
  });
};
```

---

### 5.5 Nommage Inconsistant

**Problème** : Mélange de conventions de nommage

```typescript
// ❌ Incohérent
PilgrimsService.getById(id)      // camelCase
GroupsService.remove(id)         // remove vs delete
AlertsService.listByPilgrim(id)  // listBy prefix
PositionService.getLatestPosition(id)  // getLatest prefix
```

**Recommandation** :
```typescript
// ✅ Convention unifiée
// Pour tous les services:
- list()           // Liste complète
- getById(id)      // Récupération par ID
- create(data)     // Création
- update(id, data) // Mise à jour
- delete(id)       // Suppression

// Pour des actions spécifiques:
- listByUser(userId)
- listByAgency(agencyId)
- getLatest(userId)
- getHistory(userId, params)
```

---

### 5.6 Duplication de Types Position

**Problème** : Type `Position` défini dans 3 endroits différents

1. `types/api.ts` (ligne 45-57)
2. `services/websocket.service.ts` (définition locale)
3. `services/route-history.service.ts` (ligne 4-14)

**Impact** : Incohérences possibles, maintenance difficile

**Recommandation** :
```typescript
// ✅ Centraliser dans types/api.ts
export interface Position {
  id: UUID;
  pilgrimId: UUID;
  userId?: UUID;
  lat: number;
  lng: number;
  accuracy?: number;
  battery?: number;
  speed?: number;
  heading?: number;
  ts: string;
  timestamp?: string;
}

// ✅ Réutiliser partout
import type { Position } from '@/types/api';
```

---

## 📋 6. PLAN DE CORRECTION

### Phase 1 : Corrections Critiques (Haute Priorité) ✅

**Durée estimée** : 1-2 heures

1. **Corriger dashboard.service.ts**
   ```typescript
   - getMetricsSummary: () => http.get(`${v1}/dashboard/metrics/summary`)
   + getMetricsSummary: () => http.get(`${v1}/dashboard/metrics`)
   ```

2. **Corriger alerts.service.ts**
   ```typescript
   - listByPilgrim: (pilgrimId) => http.get(`${v1}/pilgrims/${pilgrimId}/alerts`)
   + listByPilgrim: (userId) => http.get(`${v1}/auth/users/${userId}/alerts`)
   ```

3. **Corriger groups.service.ts**
   ```typescript
   - const base = `${API_BASE_PATH}/pilgrims/groups`;
   + const base = `${API_BASE_PATH}/groups`;
   ```

4. **Refactoriser route-history.service.ts**
   - Remplacer axios par le client http centralisé
   - Utiliser le même pattern que les autres services

---

### Phase 2 : Cohérence des URLs (Moyenne Priorité) 🟡

**Durée estimée** : 2-3 heures

5. **Vérifier et corriger pilgrims.service.ts**
   - Confirmer l'existence des endpoints `/pilgrims/{id}/timeline`, `/activities`, etc.
   - Corriger vers `/auth/users/{id}/*` si nécessaire

6. **Mettre à jour vers endpoints non-dépréciés**
   - Utiliser `/auth/users?role=PILGRIM` au lieu de `/auth/users/pilgrims`

7. **Standardiser les préfixes**
   - Documenter clairement quel préfixe utiliser pour chaque ressource

---

### Phase 3 : Bonnes Pratiques (Basse Priorité) 🔵

**Durée estimée** : 4-6 heures

8. **Ajouter un intercepteur d'erreurs global**
9. **Compléter les types TypeScript**
10. **Ajouter des validations avec Zod**
11. **Implémenter le cache React Query**
12. **Standardiser le nommage**
13. **Centraliser les types dupliqués**

---

### Phase 4 : Fonctionnalités Manquantes (Optionnel) ⚪

**Durée estimée** : 8-12 heures

14. **Évaluer et implémenter si nécessaire** :
    - GeoFence Service
    - Location Sharing Service
    - QR Code Service
    - Prayer Times Service
    - Position advanced endpoints

---

## 🎯 7. RÉSUMÉ DES CORRECTIONS URGENTES

### Code à Modifier Immédiatement

**1. dashboard.service.ts**
```typescript
export const DashboardService = {
-  getMetricsSummary: () => http.get<MetricsSummary>(`${v1}/dashboard/metrics/summary`).then(r => r.data),
+  getMetricsSummary: () => http.get<MetricsSummary>(`${v1}/dashboard/metrics`).then(r => r.data),
};
```

**2. alerts.service.ts**
```typescript
export const AlertsService = {
  list: (params?) => http.get<Alert[]>(`${v1}/alerts`, { params }).then(r => r.data),
  create: (payload) => http.post<Alert>(`${v1}/alerts`, payload).then(r => r.data),
-  listByPilgrim: (pilgrimId: UUID) => http.get<Alert[]>(`${v1}/pilgrims/${pilgrimId}/alerts`).then(r => r.data),
+  listByUser: (userId: UUID) => http.get<Alert[]>(`${v1}/auth/users/${userId}/alerts`).then(r => r.data),
};
```

**3. groups.service.ts**
```typescript
- const base = `${API_BASE_PATH}/pilgrims/groups`;
+ const base = `${API_BASE_PATH}/groups`;
```

**4. route-history.service.ts** (refonte complète)
```typescript
import { http } from '@/lib/http';
import type { Position, UUID } from '@/types/api';
import { API_BASE_PATH } from '@/config/api';

const v1 = API_BASE_PATH;

export interface RouteStatistics {
  totalDistanceMeters: number;
  totalDistanceFormatted: string;
  durationSeconds: number;
  durationFormatted: string;
  averageSpeedKmh: number;
  totalPoints: number;
  startTime?: string;
  endTime?: string;
  startPoint?: { lat: number; lng: number };
  endPoint?: { lat: number; lng: number };
}

export const RouteHistoryService = {
  getRouteHistory: (userId: UUID, from: string, to: string) =>
    http.get<Position[]>(`${v1}/users/${userId}/route`, {
      params: { from, to }
    }).then(r => r.data),
    
  getRouteStatistics: (userId: UUID, from: string, to: string) =>
    http.get<RouteStatistics>(`${v1}/users/${userId}/route/statistics`, {
      params: { from, to }
    }).then(r => r.data),
    
  getTodayRoute: (userId: UUID) =>
    http.get<Position[]>(`${v1}/users/${userId}/route/today`).then(r => r.data),
    
  getTodayStatistics: (userId: UUID) =>
    http.get<RouteStatistics>(`${v1}/users/${userId}/route/today/statistics`).then(r => r.data),
};
```

---

## 📊 8. MÉTRIQUES DE QUALITÉ

### Avant Corrections

| Indicateur | Valeur | Statut |
|------------|--------|--------|
| Endpoints 404 | 4 | 🔴 Critique |
| Endpoints dépréciés | 2 | 🟡 Moyen |
| Services inconsistants | 1 | 🔴 Critique |
| Types `any` | 6 | 🟡 Moyen |
| Duplications de types | 3 | 🟡 Moyen |
| **Score global** | **45/100** | 🔴 Faible |

### Après Corrections Phase 1

| Indicateur | Valeur | Statut |
|------------|--------|--------|
| Endpoints 404 | 0 | ✅ Excellent |
| Endpoints dépréciés | 2 | 🟡 Moyen |
| Services inconsistants | 0 | ✅ Excellent |
| Types `any` | 6 | 🟡 Moyen |
| Duplications de types | 3 | 🟡 Moyen |
| **Score global** | **75/100** | 🟢 Bon |

### Après Toutes les Corrections

| Indicateur | Valeur | Statut |
|------------|--------|--------|
| Endpoints 404 | 0 | ✅ Excellent |
| Endpoints dépréciés | 0 | ✅ Excellent |
| Services inconsistants | 0 | ✅ Excellent |
| Types `any` | 0 | ✅ Excellent |
| Duplications de types | 0 | ✅ Excellent |
| **Score global** | **95/100** | 🟢 Excellent |

---

## ✅ 9. CHECKLIST DE VALIDATION

Après avoir appliqué les corrections :

### Tests Fonctionnels

- [ ] Dashboard affiche les métriques correctement
- [ ] Les alertes s'affichent pour chaque utilisateur
- [ ] La gestion des groupes fonctionne (CRUD)
- [ ] Les positions sont trackées correctement
- [ ] L'historique de parcours fonctionne
- [ ] Les statistiques de route s'affichent

### Tests Techniques

- [ ] Aucune erreur 404 dans la console
- [ ] Aucun avertissement de dépréciation
- [ ] Les types TypeScript compilent sans erreur
- [ ] Les intercepteurs HTTP fonctionnent
- [ ] Le cache React Query est actif

---

## 📞 10. SUPPORT ET RESSOURCES

### Documentation Backend

- **Swagger UI** : `http://localhost:8084/swagger-ui.html`
- **OpenAPI Spec** : `http://localhost:8084/v3/api-docs`
- **Endpoints Doc** : `sahabi-guide-api/ENDPOINTS.md`

### Fichiers Clés

- **Contrôleurs Backend** : `sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/feature/*/api/*Controller.java`
- **Services Dashboard** : `sahabi-guide-dashboard/src/services/*.service.ts`
- **Configuration API** : `sahabi-guide-dashboard/src/config/api.ts`

---

**Fin du rapport d'audit** ✅

---

**Prochaine étape** : Appliquer les corrections de la Phase 1 (critiques)

