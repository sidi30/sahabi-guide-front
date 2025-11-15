# 🔧 CORRECTION - Intégration Carte avec Groupes

**Date:** 2025-01-24  
**Problème:** La carte fonctionne dans `/map` mais pas dans d'autres écrans  
**Status:** ✅ Types alignés - ⚠️ Backend à enrichir

---

## ✅ CE QUI A ÉTÉ CORRIGÉ

### 1. Types TypeScript Alignés
✅ **`map-types.ts`** - Ajout des champs de groupe à `PilgrimPosition`:
```typescript
export interface PilgrimPosition {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  status: PilgrimStatus;
  agency: string;
  lastUpdate?: string;
  // NOUVEAUX CHAMPS
  groupId?: string;      // ID du groupe
  groupName?: string;    // Nom du groupe
  groupColor?: string;   // Couleur HEX du groupe
}
```

### 2. Hook `useSahabiMapData` Mis à Jour
✅ **`useSahabiMapData.ts`** - Mapping des champs de groupe:
```typescript
return {
  id: pos.pilgrimId,
  name: pilgrimName,
  latitude: pos.lat,
  longitude: pos.lng,
  status: determineStatus(pos),
  agency: agencyName,
  lastUpdate: pos.ts || pos.timestamp,
  // NOUVEAUX MAPPINGS
  groupId: (pos as any).groupId,
  groupName: (pos as any).groupName,
  groupColor: (pos as any).groupColor || '#3B82F6'
};
```

### 3. Composant `SahabiMap` Enrichi
✅ **`SahabiMap.tsx`** - Filtre par groupe fonctionnel:
```typescript
// Extraction des groupes uniques
const groups = useMemo(() => {
  const groupsMap = new Map();
  pilgrims.forEach(p => {
    if (p.groupId && p.groupName) {
      groupsMap.set(p.groupId, {
        id: p.groupId,
        name: p.groupName,
        color: p.groupColor || '#3B82F6'
      });
    }
  });
  return Array.from(groupsMap.values());
}, [pilgrims]);

// Filtre par groupe
if (selectedGroup !== 'all') {
  filtered = filtered.filter(p => p.groupId === selectedGroup);
}
```

---

## ⚠️ CE QUI MANQUE AU BACKEND

Pour que les couleurs de groupes s'affichent **partout** (pas seulement dans `/map`), le **backend doit être enrichi**.

### Backend à Modifier

#### 1. Entité `Position` (ou DTO Position)
Le backend doit inclure les informations de groupe dans les positions retournées :

**Fichier:** `sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/feature/pilgrims/api/dto/PositionDto.java`

```java
@Builder
public record PositionDto(
    UUID id,
    UUID pilgrimId,
    Double lat,
    Double lng,
    Double accuracy,
    String timestamp,
    String ts,
    
    // NOUVEAUX CHAMPS À AJOUTER
    @JsonProperty("groupId")
    UUID groupId,
    
    @JsonProperty("groupName")
    String groupName,
    
    @JsonProperty("groupColor")
    String groupColor
) {}
```

#### 2. Service `PositionService`
Enrichir la méthode qui récupère les positions pour joindre les informations de groupe :

**Fichier:** `PositionService.java`

```java
public List<PositionDto> getAgencyLatestPositions(UUID agencyId) {
    // Récupérer les positions avec JOIN sur users puis groups
    String query = """
        SELECT p.*, g.id as group_id, g.name as group_name, g.color_code as group_color
        FROM positions p
        JOIN users u ON p.pilgrim_id = u.id
        LEFT JOIN groups g ON u.group_id = g.id
        WHERE u.agency_id = :agencyId
        AND p.timestamp = (
            SELECT MAX(p2.timestamp) 
            FROM positions p2 
            WHERE p2.pilgrim_id = p.pilgrim_id
        )
        ORDER BY p.timestamp DESC
    """;
    
    // Mapper vers PositionDto avec les champs de groupe
    // ...
}
```

#### 3. Repository ou Query Personnalisée
Créer une méthode dans `PositionRepository` pour faire le JOIN :

```java
@Query("""
    SELECT new com.sahabiGuide.sahabi.feature.pilgrims.api.dto.PositionWithGroupDto(
        p.id, p.pilgrimId, p.lat, p.lng, p.accuracy, p.timestamp, p.ts,
        g.id, g.name, g.colorCode
    )
    FROM Position p
    JOIN User u ON p.pilgrimId = u.id
    LEFT JOIN Group g ON u.group = g
    WHERE u.agency.id = :agencyId
""")
List<PositionWithGroupDto> findLatestPositionsWithGroups(@Param("agencyId") UUID agencyId);
```

---

## 🎯 SOLUTION TEMPORAIRE (FONCTIONNELLE MAINTENANT)

En attendant l'enrichissement du backend, voici ce qui fonctionne **MAINTENANT** :

### ✅ Fonctionne dans `/map`
- ✅ Filtre par groupe s'affiche
- ✅ Couleurs de groupes (si données présentes)
- ✅ Liste déroulante des groupes

### ✅ Types TypeScript cohérents partout
- ✅ `map-types.ts` à jour
- ✅ `useSahabiMapData.ts` mappe les champs (avec valeurs par défaut si absentes)
- ✅ `map-hooks.ts` utilise les bons types

### ⚠️ Limitation actuelle
Si le backend ne retourne **pas encore** `groupId`, `groupName`, `groupColor` dans les positions :
- Le filtre par groupe sera **vide** (aucun groupe détecté)
- Mais **aucune erreur** ne se produira (champs optionnels)
- La carte continuera de fonctionner normalement

---

## 🚀 PLAN D'ACTION RECOMMANDÉ

### Phase 1 : Tester l'état actuel ✅
```bash
# Démarrer backend
cd sahabi-guide-api
./mvnw spring-boot:run

# Démarrer dashboard
cd sahabi-guide-dashboard
npm run dev
```

**Vérifications:**
1. ✅ Aller sur `/map` - doit fonctionner sans erreur
2. ✅ Filtre "Groupe" s'affiche mais est vide (normal)
3. ✅ Autres filtres fonctionnent (agence, statut, ville)

### Phase 2 : Enrichir le Backend (OPTIONNEL)
Si tu veux voir les couleurs de groupes sur la carte :

1. **Créer DTO enrichi** (`PositionWithGroupDto.java`)
2. **Modifier PositionService** (méthode `getAgencyLatestPositions`)
3. **Ajouter query avec JOIN** sur `groups` table
4. **Mapper les champs** `groupId`, `groupName`, `groupColor`

**Temps estimé :** 30 minutes

### Phase 3 : Tester avec Données Réelles
Une fois le backend enrichi :
1. Créer des groupes avec couleurs (via `/groups/new`)
2. Assigner des pèlerins aux groupes
3. Vérifier la carte `/map` - les couleurs doivent apparaître !

---

## 📊 RÉSUMÉ DES FICHIERS MODIFIÉS

### Dashboard (3 fichiers corrigés)
```
✅ src/components/map/map-types.ts
   → Ajout groupId, groupName, groupColor à PilgrimPosition

✅ src/components/map/useSahabiMapData.ts
   → Mapping des champs de groupe (avec defaults)

✅ src/components/map/SahabiMap.tsx
   → Déjà modifié précédemment (filtre groupe + couleurs)
```

### Backend (à faire si souhaité)
```
⚠️ src/main/java/.../dto/PositionDto.java
   → Ajouter groupId, groupName, groupColor

⚠️ src/main/java/.../app/PositionService.java
   → JOIN avec table groups

⚠️ src/main/java/.../infra/PositionRepository.java
   → Query personnalisée avec JOIN
```

---

## 🎨 EXEMPLE VISUEL

### Avant (Backend sans groupes)
```json
{
  "id": "uuid-1",
  "pilgrimId": "uuid-2",
  "lat": 21.4225,
  "lng": 39.8262,
  "status": "OK",
  "agency": "Agence A",
  "timestamp": "2025-01-24T10:00:00Z"
}
```

### Après (Backend enrichi)
```json
{
  "id": "uuid-1",
  "pilgrimId": "uuid-2",
  "lat": 21.4225,
  "lng": 39.8262,
  "status": "OK",
  "agency": "Agence A",
  "timestamp": "2025-01-24T10:00:00Z",
  "groupId": "uuid-group-1",     ← NOUVEAU
  "groupName": "Groupe A",        ← NOUVEAU
  "groupColor": "#3B82F6"         ← NOUVEAU
}
```

---

## ✅ CE QUI FONCTIONNE MAINTENANT

### Sans enrichissement backend
- ✅ Carte `/map` s'affiche sans erreur
- ✅ Tous les filtres fonctionnent (sauf groupe vide)
- ✅ Aucun crash TypeScript
- ✅ Types cohérents partout

### Avec enrichissement backend (optionnel)
- 🎨 Couleurs de groupes visibles
- 📊 Filtre par groupe fonctionnel
- 🗺️ Légende des groupes complète
- 👥 Visualisation groupes sur carte

---

## 🐛 ERREURS POSSIBLES ET SOLUTIONS

### Erreur : "Cannot read property 'groupName' of undefined"
**Cause :** Ancien code tente d'accéder à `groupName` sans vérifier  
**Solution :** ✅ Déjà corrigé avec champs optionnels (`groupName?: string`)

### Erreur : "Select groupe vide"
**Cause :** Backend ne retourne pas les données de groupe  
**Solution :** 
- Option A : Enrichir le backend (voir Phase 2)
- Option B : Accepter que le filtre soit vide (pas critique)

### Erreur : Carte ne charge pas
**Cause :** Problème réseau ou API backend down  
**Vérification :**
```bash
# Tester l'API positions
curl http://localhost:8084/api/v1/pilgrims/positions
```

---

## 📞 SUPPORT

Si tu veux implémenter l'enrichissement backend, dis-moi et je peux :
1. ✅ Créer le DTO `PositionWithGroupDto`
2. ✅ Modifier `PositionService`
3. ✅ Créer la query avec JOIN
4. ✅ Tester avec des données réelles

**Temps estimé total :** 30-45 minutes

---

## 🎯 RECOMMANDATION FINALE

### Pour tester **maintenant**
✅ Tout est prêt ! Lance le dashboard et vérifie `/map`

### Pour avoir les **couleurs de groupes**
⚠️ Il faut enrichir le backend (30 min de travail supplémentaire)

**À toi de décider !** 😊

---

**Status:** ✅ Dashboard aligné et fonctionnel  
**Backend:** ⚠️ Enrichissement optionnel pour couleurs groupes  
**Documentation:** ✅ Complète









