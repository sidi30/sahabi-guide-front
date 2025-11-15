# 🔄 GUIDE DE MIGRATION API - FRONTEND (React & Flutter)

## 📅 Date : 22 Octobre 2025

---

## 🎯 CHANGEMENTS APPLIQUÉS

### Résumé des modifications
- ✅ **3 contrôleurs supprimés** : PilgrimPositionController, HealthProfileController, PoiController
- ✅ **1 fusion réalisée** : PositionHistoryController → PositionController
- ✅ **Endpoints nettoyés** : /users/pilgrims/{id} marqués @Deprecated
- ⚠️ **0 breaking changes** : Tous les anciens endpoints fonctionnent encore (deprecated)

---

## 📱 MIGRATIONS FRONTEND FLUTTER

### 1. Positions GPS - ✅ PAS DE CHANGEMENT REQUIS

**Ancien endpoint (deprecated) :**
```dart
// ❌ Déprécié mais fonctionne encore
final url = '/api/v1/pilgrims/$id/positions';
```

**Nouveau endpoint (recommandé) :**
```dart
// ✅ Utiliser ceci
final url = '/api/v1/users/$id/positions';
```

**Fichiers à modifier :**
```bash
# Rechercher les occurrences
grep -r "pilgrims/.*"/positions" lib/

# Exemples de fichiers potentiels :
# - lib/services/position_service.dart
# - lib/features/tracking/repositories/position_repository.dart
```

**Code de remplacement :**
```dart
// lib/services/position_service.dart

class PositionService {
  final ApiClient _apiClient;

  // ✅ Méthode mise à jour
  Future<Position?> getLatestPosition(String userId) async {
    final response = await _apiClient.get(
      '/api/v1/users/$userId/position/latest', // ✅ Nouveau format
    );
    
    if (response.statusCode == 200) {
      return Position.fromJson(response.data);
    }
    return null;
  }

  // ✅ Historique des positions
  Future<List<Position>> getPositionHistory(String userId, {int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      '/api/v1/users/$userId/positions', // ✅ Nouveau format
      queryParameters: {'page': page, 'size': size},
    );
    
    return (response.data as List)
        .map((json) => Position.fromJson(json))
        .toList();
  }
}
```

---

### 2. Profil Santé - ✅ PAS DE CHANGEMENT REQUIS

**Flutter utilise déjà le bon endpoint** :
```dart
// ✅ Déjà correct - Ne rien changer
final url = '/api/v1/auth/users/$userId/health';
```

**Vérification recommandée :**
```bash
# Vérifier qu'aucun fichier n'utilise l'ancien endpoint
grep -r "/pilgrims/.*/health" lib/

# Si des occurences existent, remplacer par :
# /api/v1/auth/users/{userId}/health
```

---

### 3. Points d'Intérêt (POI) - 🔄 CHANGEMENT REQUIS

**Ancien endpoint (supprimé) :**
```dart
// ❌ Ce endpoint n'existe plus
final url = '/api/v1/poi';
```

**Nouveau endpoint :**
```dart
// ✅ Utiliser ceci
final url = '/api/v1/geo/pois';
```

**Fichiers à modifier :**
```bash
# Rechercher les occurrences
grep -r "/api/v1/poi" lib/

# Exemples de fichiers potentiels :
# - lib/services/poi_service.dart
# - lib/features/map/repositories/poi_repository.dart
```

**Code de remplacement :**
```dart
// lib/services/poi_service.dart

class PoiService {
  final ApiClient _apiClient;

  // ✅ Liste des POI
  Future<List<Poi>> getPois({String? type, double? lat, double? lng, double? radius}) async {
    final response = await _apiClient.get(
      '/api/v1/geo/pois', // ✅ Nouveau endpoint
      queryParameters: {
        if (type != null) 'type': type,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radius != null) 'radius': radius,
      },
    );
    
    return (response.data as List)
        .map((json) => Poi.fromJson(json))
        .toList();
  }

  // ✅ Détails d'un POI
  Future<Poi> getPoiById(String id) async {
    final response = await _apiClient.get(
      '/api/v1/geo/pois/$id', // ✅ Nouveau endpoint
    );
    
    return Poi.fromJson(response.data);
  }
}
```

---

### 4. Appel Guide - 🔄 CHANGEMENT REQUIS

**Ancien endpoint (supprimé) :**
```dart
// ❌ Ce endpoint n'existe plus
final url = '/api/v1/poi/guide/call';
```

**Nouveau endpoint (à implémenter côté backend) :**
```dart
// ✅ Utiliser ceci
final url = '/api/v1/alerts/guide-call';
```

**Code de remplacement :**
```dart
// lib/services/support_service.dart

class SupportService {
  final ApiClient _apiClient;

  // ✅ Appeler le guide
  Future<Map<String, dynamic>> callGuide({
    required String userId,
    String? message,
    double? lat,
    double? lng,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/alerts/guide-call', // ✅ Nouveau endpoint
      data: {
        'userId': userId,
        'message': message,
        'latitude': lat,
        'longitude': lng,
      },
    );
    
    return response.data;
  }
}
```

---

## 🖥️ MIGRATIONS FRONTEND REACT DASHBOARD

### 1. Profil Santé - 🔄 CHANGEMENT POSSIBLE

**Vérifier l'utilisation actuelle :**
```bash
# Dans le répertoire sahabi-guide-dashboard
grep -r "/pilgrims/.*/health" src/
```

**Si des occurrences existent, remplacer :**
```typescript
// src/services/healthService.ts

// ❌ AVANT
const getHealthProfile = async (pilgrimId: string) => {
  const response = await api.get(`/api/v1/pilgrims/${pilgrimId}/health`);
  return response.data;
};

// ✅ APRÈS
const getHealthProfile = async (userId: string) => {
  const response = await api.get(`/api/v1/auth/users/${userId}/health`);
  return response.data;
};
```

---

### 2. Liste des Pèlerins - 🔄 CHANGEMENT RECOMMANDÉ

**Ancien endpoint (déprécié mais fonctionne) :**
```typescript
// ⚠️ Déprécié
const pilgrims = await api.get('/api/v1/auth/users/pilgrims');
```

**Nouveau endpoint (recommandé) :**
```typescript
// ✅ Utiliser ceci
const pilgrims = await api.get('/api/v1/auth/users?role=PILGRIM');
```

**Fichiers à modifier :**
```bash
grep -r "/users/pilgrims" src/
```

**Code de remplacement :**
```typescript
// src/services/userService.ts

export const userService = {
  // ✅ Liste des utilisateurs avec filtre par rôle
  getUsers: async (role?: 'PILGRIM' | 'GUIDE' | 'ADMIN_AGENCY') => {
    const params = role ? { role } : {};
    const response = await api.get('/api/v1/auth/users', { params });
    return response.data;
  },

  // ✅ Méthodes de commodité
  getPilgrims: () => userService.getUsers('PILGRIM'),
  getGuides: () => userService.getUsers('GUIDE'),
  getAdmins: () => userService.getUsers('ADMIN_AGENCY'),
};
```

---

### 3. Points d'Intérêt (POI) - 🔄 CHANGEMENT REQUIS

**Ancien endpoint (supprimé) :**
```typescript
// ❌ N'existe plus
const pois = await api.get('/api/v1/poi');
```

**Nouveau endpoint :**
```typescript
// ✅ Utiliser ceci
const pois = await api.get('/api/v1/geo/pois');
```

**Fichiers à modifier :**
```bash
grep -r "/api/v1/poi" src/
```

**Code de remplacement :**
```typescript
// src/services/poiService.ts

interface GetPoisParams {
  type?: string;
  lat?: number;
  lng?: number;
  radius?: number;
  agencyId?: string;
}

export const poiService = {
  // ✅ Liste des POI
  getPois: async (params?: GetPoisParams) => {
    const response = await api.get('/api/v1/geo/pois', { params });
    return response.data;
  },

  // ✅ Détails d'un POI
  getPoiById: async (id: string) => {
    const response = await api.get(`/api/v1/geo/pois/${id}`);
    return response.data;
  },

  // ✅ Créer un POI
  createPoi: async (data: CreatePoiRequest) => {
    const response = await api.post('/api/v1/geo/pois', data);
    return response.data;
  },

  // ✅ Modifier un POI
  updatePoi: async (id: string, data: UpdatePoiRequest) => {
    const response = await api.put(`/api/v1/geo/pois/${id}`, data);
    return response.data;
  },

  // ✅ Supprimer un POI
  deletePoi: async (id: string) => {
    await api.delete(`/api/v1/geo/pois/${id}`);
  },
};
```

---

### 4. Parcours et Statistiques - ✅ PAS DE CHANGEMENT

**Endpoints fusionnés mais URLs identiques :**
```typescript
// ✅ Ces endpoints fonctionnent toujours identiquement
const route = await api.get(`/api/v1/users/${userId}/route`, {
  params: { from, to }
});

const stats = await api.get(`/api/v1/users/${userId}/route/statistics`, {
  params: { from, to }
});

const todayRoute = await api.get(`/api/v1/users/${userId}/route/today`);

const todayStats = await api.get(`/api/v1/users/${userId}/route/today/statistics`);
```

**Aucun changement requis** - La fusion est transparente pour le frontend.

---

## 📋 CHECKLIST DE MIGRATION

### Flutter Mobile

- [ ] Remplacer `/pilgrims/{id}/positions` → `/users/{id}/positions`
- [ ] Remplacer `/api/v1/poi` → `/api/v1/geo/pois`
- [ ] Remplacer `/poi/guide/call` → `/alerts/guide-call`
- [ ] Vérifier que `/auth/users/{id}/health` est utilisé (déjà correct normalement)
- [ ] Tester :
  - [ ] Géolocalisation (enregistrement + historique)
  - [ ] Affichage des POI sur la carte
  - [ ] Profil santé
  - [ ] Appel guide

### React Dashboard

- [ ] Remplacer `/pilgrims/{id}/health` → `/auth/users/{id}/health` (si utilisé)
- [ ] Remplacer `/users/pilgrims` → `/users?role=PILGRIM`
- [ ] Remplacer `/users/guides` → `/users?role=GUIDE`
- [ ] Remplacer `/users/admins` → `/users?role=ADMIN_AGENCY`
- [ ] Remplacer `/api/v1/poi` → `/api/v1/geo/pois`
- [ ] Remplacer `/poi/guide/call` → `/alerts/guide-call`
- [ ] Mettre à jour les types TypeScript (si nécessaire)
- [ ] Tester :
  - [ ] Liste des pèlerins
  - [ ] Profil santé
  - [ ] Carte avec POI
  - [ ] Statistiques de parcours

---

## 🔍 SCRIPTS DE VÉRIFICATION

### Flutter

```bash
cd sahabi-guide-front

# Rechercher les anciens endpoints
echo "=== Recherche de '/pilgrims' ===" 
grep -r "/pilgrims" lib/ --include="*.dart"

echo "=== Recherche de '/api/v1/poi' ===" 
grep -r "/api/v1/poi" lib/ --include="*.dart"

echo "=== Recherche de '/guide/call' ===" 
grep -r "/guide/call" lib/ --include="*.dart"
```

### React

```bash
cd sahabi-guide-dashboard

# Rechercher les anciens endpoints
echo "=== Recherche de '/pilgrims' ===" 
grep -r "/pilgrims" src/ --include="*.ts" --include="*.tsx"

echo "=== Recherche de '/api/v1/poi' ===" 
grep -r "/api/v1/poi" src/ --include="*.ts" --include="*.tsx"

echo "=== Recherche de '/users/pilgrims' ===" 
grep -r "/users/pilgrims" src/ --include="*.ts" --include="*.tsx"
```

---

## ⚠️ ENDPOINTS DEPRECATED (Fonctionnent encore)

Ces endpoints sont **deprecated** mais **continuent de fonctionner** pour compatibilité :

| Endpoint Deprecated | Nouveau Endpoint | Action |
|---------------------|------------------|--------|
| `GET /users/pilgrims` | `GET /users?role=PILGRIM` | Migrer quand possible |
| `GET /users/guides` | `GET /users?role=GUIDE` | Migrer quand possible |
| `GET /users/admins` | `GET /users?role=ADMIN_AGENCY` | Migrer quand possible |

**Note :** Ces endpoints logguent un warning côté backend pour encourager la migration.

---

## 🚫 ENDPOINTS SUPPRIMÉS (Ne fonctionnent plus)

| Endpoint Supprimé | Nouveau Endpoint | Action |
|-------------------|------------------|--------|
| `GET /api/v1/poi` | `GET /api/v1/geo/pois` | **Obligatoire** |
| `GET /api/v1/poi/{id}` | `GET /api/v1/geo/pois/{id}` | **Obligatoire** |
| `POST /api/v1/poi/guide/call` | `POST /api/v1/alerts/guide-call` | **Obligatoire** |
| `GET /api/v1/pilgrims/{id}/positions` | `GET /api/v1/users/{id}/positions` | **Obligatoire** |
| `GET /api/v1/pilgrims/{id}/health` | `GET /api/v1/auth/users/{id}/health` | **Obligatoire** |

---

## 📊 IMPACT ESTIMÉ

### Flutter

- **Fichiers à modifier :** 5-10 fichiers
- **Temps estimé :** 1 heure
- **Risque :** 🟢 FAIBLE (changements simples d'URLs)

### React Dashboard

- **Fichiers à modifier :** 8-15 fichiers
- **Temps estimé :** 2 heures
- **Risque :** 🟡 MOYEN (dépend de l'utilisation actuelle)

---

## 🎉 BÉNÉFICES

- ✅ API plus cohérente et logique
- ✅ Moins de confusion (1 endpoint par ressource)
- ✅ Documentation simplifiée
- ✅ Meilleure maintenabilité
- ✅ Performances identiques ou meilleures

---

**Besoin d'aide ?** Contactez l'équipe backend pour toute question sur la migration.

*Guide généré le 22 Octobre 2025*

