# 📋 Résumé Exécutif - Plan d'implémentation Agences & Groupes

## 🎯 Objectif
Créer des interfaces complètes de gestion des **Agences** et des **Groupes** dans le Dashboard avec toutes les informations pertinentes pour permettre un suivi efficace des pèlerins.

---

## 📊 Ce qui manque actuellement

### AGENCES (très basique)
- ❌ Seulement `id` et `name` exposés dans l'API
- ❌ Pas d'interface de gestion dans le Dashboard
- ❌ Aucune information de contact (email, téléphone, adresse)
- ❌ Aucune information commerciale (forfait, contrat, statut)
- ❌ Aucune statistique

### GROUPES (incomplet)
- ❌ Pas de code couleur pour distinction visuelle
- ❌ Infos encadrant non affichées (téléphone, email)
- ❌ Pas de filtrage par agence/encadrant
- ❌ Pas de statut de groupe
- ❌ Pas de vue détaillée avec statistiques
- ❌ Données mockées (superviseur, statut, location)

---

## ✨ Ce qui sera ajouté

### AGENCES - Informations complètes

#### Identification
- Logo/photo de l'agence (upload)
- Description
- SIRET/Numéro d'identification

#### Contact
- **Email principal**
- **Téléphone principal**
- Site web
- Contact principal (nom + téléphone)
- **Adresse complète** (rue, ville, CP, pays)

#### Commercial
- **Type de forfait** (Standard/Premium/Enterprise)
- Date début/fin contrat
- **Statut** (Actif/Suspendu/Résilié)

#### Statistiques (calculées en temps réel)
- Nombre total de pèlerins
- Nombre de groupes
- Nombre de comptes admin/users
- Nombre d'alertes actives

#### Interface Dashboard
- Page liste avec filtres (pays, forfait, statut)
- Page détail avec onglets :
  - Général (infos de base)
  - Contact (adresse, téléphone, email)
  - Abonnement (forfait, dates, statut)
  - Statistiques (graphiques)
  - Groupes (liste des groupes)
  - Utilisateurs (liste admins/users)

---

### GROUPES - Gestion complète

#### Identification enrichie
- **Code couleur** (color picker pour distinction visuelle)
- Description
- Capacité maximale

#### Encadrant/Guide
- Nom complet
- Photo
- **Téléphone**
- **Email**
- Bouton "Contacter"

#### Programme
- Date début/fin
- Lieu de rassemblement
- Itinéraire/Programme

#### Statut
- **EN_PREPARATION** / **ACTIF** / **TERMINÉ** / **ANNULÉ**

#### Statistiques (temps réel)
- **Nombre pèlerins** (Total / OK / SOS / Inactifs)
- Position moyenne du groupe

#### Interface Dashboard
- **Page liste améliorée** :
  - Pastille colorée par groupe
  - Infos encadrant visibles (photo + nom + téléphone)
  - Statistiques pèlerins (🟢23 🔴2 ⚫0)
  - **Filtres avancés** :
    - Par agence (SUPER_ADMIN)
    - Par encadrant
    - Par statut
    - Par couleur
  - Vue carte avec couleurs

- **Page détail** avec onglets :
  - Général (nom, couleur, description, capacité)
  - Encadrant (infos complètes + contact)
  - Programme (dates, lieu, itinéraire)
  - **Pèlerins** (liste avec actions : ajouter/retirer)
  - Statistiques (graphiques répartition)
  - **Carte** (vue groupe avec couleur)

---

## 🛠️ Modifications techniques

### Backend (Java/Spring Boot)

#### 1. Base de données (Liquibase)
```sql
-- Ajout colonnes table agencies
ALTER TABLE agencies ADD COLUMN logo_url VARCHAR(500);
ALTER TABLE agencies ADD COLUMN email VARCHAR(255);
ALTER TABLE agencies ADD COLUMN phone VARCHAR(20);
ALTER TABLE agencies ADD COLUMN address_street VARCHAR(255);
ALTER TABLE agencies ADD COLUMN subscription_type VARCHAR(20);
ALTER TABLE agencies ADD COLUMN status VARCHAR(20);
-- ... etc (16 nouvelles colonnes)

-- Ajout colonnes table groups
ALTER TABLE groups ADD COLUMN color_code VARCHAR(7);
ALTER TABLE groups ADD COLUMN description TEXT;
ALTER TABLE groups ADD COLUMN max_capacity INTEGER;
ALTER TABLE groups ADD COLUMN status VARCHAR(20);
ALTER TABLE groups ADD COLUMN start_date DATE;
-- ... etc (8 nouvelles colonnes)
```

#### 2. Nouveaux endpoints API
```java
// Agences
GET    /api/v1/auth/agencies/{id}/details      // Infos complètes + stats
GET    /api/v1/auth/agencies/{id}/stats        // Statistiques uniquement
POST   /api/v1/auth/agencies/{id}/logo         // Upload logo

// Groupes
GET    /api/v1/groups/{id}/details             // Infos complètes + stats
GET    /api/v1/groups/{id}/pilgrims            // Liste pèlerins du groupe
POST   /api/v1/groups/{id}/pilgrims/{pilgrimId}  // Ajouter pèlerin
DELETE /api/v1/groups/{id}/pilgrims/{pilgrimId}  // Retirer pèlerin
```

#### 3. Nouveaux DTOs
- `AgencyDetailDto` (toutes les infos enrichies)
- `AgencyStatsDto` (statistiques)
- `GroupDetailDto` (toutes les infos enrichies)
- `GroupStatsDto` (statistiques)
- `GroupGuideDto` (infos encadrant)

---

### Frontend (React/TypeScript)

#### 1. Nouvelles pages
```
/agencies                    → Liste des agences
/agencies/:id                → Détail agence
/agencies/new                → Créer agence
/groups                      → Liste groupes (améliorée)
/groups/:id                  → Détail groupe
/groups/new                  → Créer groupe
```

#### 2. Nouveaux composants
```tsx
// Agences
<AgenciesPage />           // Liste avec filtres
<AgencyDetailPage />       // Détail avec onglets
<AgencyForm />             // Formulaire création/édition
<AgencyStats />            // Composant statistiques
<AgencyLogoUpload />       // Upload logo

// Groupes
<GroupsPage />             // Liste améliorée
<GroupDetailPage />        // Détail avec onglets
<GroupForm />              // Formulaire avec color picker
<GroupColorPicker />       // Sélecteur couleur
<GroupPilgrimsList />      // Liste pèlerins du groupe
<GroupStats />             // Statistiques groupe
<GroupMapView />           // Vue carte du groupe

// UI
<ColorPicker />            // Composant réutilisable
```

#### 3. Services enrichis
```typescript
// agencies.service.ts
getDetails(id: string): Promise<AgencyDetail>
getStats(id: string): Promise<AgencyStats>
uploadLogo(id: string, file: File): Promise<string>

// groups.service.ts
getDetails(id: string): Promise<GroupDetail>
getPilgrims(id: string, status?: string): Promise<Pilgrim[]>
addPilgrim(groupId: string, pilgrimId: string): Promise<void>
removePilgrim(groupId: string, pilgrimId: string): Promise<void>
```

---

## 🎨 Aperçu visuel

### Liste des Agences
```
┌────────────────────────────────────────────────────────────┐
│ 🏢 Gestion des Agences              [+ Créer une agence]  │
├────────────────────────────────────────────────────────────┤
│ Logo │ Nom        │ Pays │ Email      │ Forfait │ Statut │
│──────────────────────────────────────────────────────────│
│ [🏢] │ Al-Barakah│ 🇫🇷   │ contact@.. │ Premium │🟢 Actif│
│ [🏢] │ Omra Plus  │ 🇲🇦   │ info@...   │ Standard│🟢 Actif│
└────────────────────────────────────────────────────────────┘
```

### Liste des Groupes (améliorée)
```
┌────────────────────────────────────────────────────────────────────┐
│ 👥 Gestion des Groupes                     [+ Créer un groupe]    │
├────────────────────────────────────────────────────────────────────┤
│ 🔍 [Recherche] [Agence▼] [Encadrant▼] [Statut▼]                  │
├────────────────────────────────────────────────────────────────────┤
│●│Nom       │ Encadrant      │ Pèlerins     │ Statut  │ Lieu      │
│─────────────────────────────────────────────────────────────────│
│🔵│Groupe A1│ Mohammed Ali   │ 25 (23🟢2🔴) │🟢 Actif │ La Mecque │
│  │         │ +33 6 12 34 56 │              │         │           │
│🟢│Groupe B2│ Amina Khan     │ 30 (30🟢0🔴) │🟢 Actif │ Médine    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 📅 Planning d'implémentation

### **Phase 1 : Backend** (2-3 jours)
1. Migration Liquibase (colonnes)
2. Modification entités + enums
3. Création DTOs
4. Endpoints API
5. Tests

### **Phase 2 : Dashboard Agences** (2 jours)
1. Types TypeScript
2. Services enrichis
3. Pages liste/détail/form
4. Composants UI

### **Phase 3 : Dashboard Groupes** (2 jours)
1. Types TypeScript
2. Services enrichis
3. Pages améliorées
4. ColorPicker
5. Vue carte

### **Phase 4 : Intégration carte** (1 jour)
1. Groupes avec couleurs sur MapPage
2. Filtres par groupe

### **Phase 5 : Tests & Doc** (1 jour)
1. Tests end-to-end
2. Documentation

**TOTAL : 8-9 jours de développement**

---

## 🔒 Droits d'accès

| Rôle | Agences | Groupes |
|------|---------|---------|
| **SUPER_ADMIN** | ✅ Toutes (CRUD) | ✅ Tous (CRUD) |
| **AGENCE_ADMIN** | ⚠️ SA propre agence (édition) | ⚠️ SES groupes uniquement (CRUD) |
| **AGENCE_USER** | 👁️ SA propre agence (lecture) | 👁️ SES groupes uniquement (lecture) |

---

## ✅ Avantages

### Pour les Agences
- ✨ Fiche complète de chaque agence
- 📊 Statistiques en temps réel
- 📞 Informations de contact accessibles
- 💼 Gestion commerciale (forfaits, contrats)
- 🎯 Suivi de l'activité (pèlerins, groupes, alertes)

### Pour les Groupes
- 🎨 **Distinction visuelle** par couleur
- 👤 Informations complètes de l'encadrant
- 📊 Statistiques temps réel (OK/SOS/Inactifs)
- 🗺️ Vue carte dédiée par groupe
- 🔍 **Filtres puissants** (agence, encadrant, statut)
- 👥 Gestion des pèlerins (ajouter/retirer)

---

## 🚀 Prochaines étapes

1. **Validation du plan** par l'équipe
2. **Priorisation** des fonctionnalités si besoin
3. **Démarrage Phase 1** (Backend)
4. **Reviews régulières** à chaque phase
5. **Tests utilisateurs** en continu

---

**📄 Rapport complet :** `RAPPORT_ANALYSE_GESTION_AGENCES_GROUPES.md`

**Date :** 2025-01-24  
**Statut :** ✅ Prêt pour validation et implémentation









