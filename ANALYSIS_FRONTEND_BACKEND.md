# Analyse des Incohérences Frontend-Backend

## 🔍 Incohérences Identifiées

### 1. Endpoints API Multiples
**Problème:** Il existe deux contrôleurs POI différents dans le backend
- `/api/v1/poi` - PoiController (données hardcodées de test)
- `/api/v1/geo/pois` - GeoController (vrai endpoint avec base de données)

**Impact:** Le frontend utilise `/api/v1/poi` mais devrait utiliser `/api/v1/geo/pois` pour les données réelles.

**Solution:** Mettre à jour `poi_service.dart` pour utiliser `/api/v1/geo/pois`

---

### 2. Types de POI Incohérents
**Problème:** Les types de POI ne correspondent pas entre frontend et backend

#### Backend (GeoController + enum PoiType)
```java
HOTEL, HOSPITAL, PHARMACY, WATER, MOSQUE, CONSULATE, RALLY, SHOP
```

#### Backend (PoiController - données de test)
```java
"mosque", "hotel", "hospital", "restaurant", "hajj_site"
```

#### Frontend (poi_model.dart)
```dart
hotel, hospital, mosque, restaurant, holySite, hajjSite, transport, airport, other
```

**Impact:** Les filtres ne fonctionnent pas correctement, certains types POI ne sont pas reconnus

**Solution:** 
1. Aligner les types frontend sur l'enum backend
2. Mapper les types lors de la désérialisation

---

### 3. Structure des Données POI

#### Backend GeoController retourne:
```json
{
  "id": "uuid",
  "agencyId": "uuid",
  "type": "MOSQUE",
  "name": "string",
  "lat": 21.4225,
  "lng": 39.8262,
  "metadata": {},
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Backend PoiController retourne:
```json
{
  "id": "1",
  "name": "string",
  "description": "string",
  "type": "mosque",
  "address": "string",
  "phone": "string",
  "geometry": {
    "type": "Point",
    "coordinates": [39.8262, 21.4225]
  }
}
```

#### Frontend attend:
```dart
{
  "id": "string",
  "name": "string",
  "description": "string",
  "type": "mosque",
  "geometry": {
    "type": "Point",
    "coordinates": [lng, lat]
  },
  "address": "string",
  "phone": "string",
  "imageUrl": "string",
  "properties": {}
}
```

**Impact:** Les données du GeoController ne sont pas parsées correctement

---

### 4. Endpoints d'Actions Manquants

#### Frontend appelle:
- `/api/v1/guide/call` - Appel guide
- `/api/v1/urgency` - Urgence

#### Backend expose:
- `/api/v1/poi/guide/call` - Appel guide (dans PoiController)
- Pas d'endpoint `/api/v1/urgency` trouvé

**Impact:** L'appel guide fonctionne avec le mauvais endpoint, l'urgence ne fonctionne pas

---

## 🐛 Bugs Potentiels Identifiés

### 1. Parsing des Coordonnées
```dart
// Dans poi_model.dart
final coordinates = geometry['coordinates'] as List;
lng = coordinates[0].toDouble();
lat = coordinates[1].toDouble();
```
✅ Correct pour GeoJSON (lng, lat)

### 2. Gestion des Erreurs
- ❌ Pas de gestion des erreurs réseau spécifiques
- ❌ Pas de retry automatique
- ❌ Pas de cache offline

### 3. Authentification
- ⚠️ Le service POI lit le token mais ne le passe pas systématiquement
- ❌ Pas de refresh token automatique

### 4. Types Nullable
- ⚠️ `phone` et `address` sont nullable mais pas toujours vérifiés
- ⚠️ `description` peut être null

---

## 🎯 Améliorations Carte flutter_map

### Fonctionnalités Manquantes
1. ❌ Mode satellite
2. ⚠️ Zoom/dézoom présent mais peut être amélioré
3. ❌ Rotation de la carte
4. ❌ Compass/boussole
5. ❌ Échelle de distance
6. ❌ Clustering des marqueurs (performance)

### Fonctionnalités Présentes
1. ✅ Marqueurs POI
2. ✅ Filtrage par type
3. ✅ Géolocalisation
4. ✅ Zoom manuel
5. ✅ Détails POI en bottom sheet

---

## 📋 Plan de Correction

### Priorité 1 - Critique
1. Aligner les types de POI
2. Utiliser le bon endpoint API (`/api/v1/geo/pois`)
3. Corriger le parsing des données POI

### Priorité 2 - Important
4. Ajouter le mode satellite
5. Corriger l'endpoint d'urgence
6. Améliorer les contrôles de zoom

### Priorité 3 - Nice to have
7. Ajouter le clustering des marqueurs
8. Ajouter une échelle de distance
9. Améliorer la gestion des erreurs
10. Ajouter un cache offline


