# 📊 Rapport d'Analyse - Gestion Agences & Groupes Dashboard

**Date :** 2025-01-24  
**Version :** 1.0  
**Objectif :** Créer des interfaces complètes pour la gestion des agences et des groupes avec toutes les informations pertinentes

---

## 🔍 1. ANALYSE DE L'EXISTANT

### 1.1 Backend API (Spring Boot)

#### Entity `Agency` (actuelle)
```java
@Entity
public class Agency {
    UUID id;
    String name;              // ✅
    String countryCode;       // ✅
    String settingsJson;      // JSONB
    Set<User> users;         // Relation
}
```

**OpenAPI Schema `Agency` (actuel) :**
```yaml
Agency:
  properties:
    id: UUID
    name: string  # ✅ Seul champ exposé
```

**📌 Constat :** Structure minimale, beaucoup d'informations manquantes

---

#### Entity `Group` (actuelle)
```java
@Entity
public class Group {
    UUID id;
    String name;              // ✅
    UUID agencyId;            // ✅
    UUID guideId;             // ✅ Encadrant
    Set<User> users;         // Pèlerins du groupe
}
```

**OpenAPI Schema `Group` (actuel) :**
```yaml
Group:
  properties:
    id: UUID
    name: string
    agencyId: UUID
```

**📌 Constat :** Pas de guideId exposé, pas de statut, pas de couleur

---

### 1.2 Dashboard React (actuel)

#### Page `GroupsPage.tsx`
- ✅ Liste des groupes
- ✅ Filtres (statut, superviseur)
- ✅ Tableau avec : nom, superviseur, nombre pèlerins, statut, location
- ❌ Pas de création/édition de groupe
- ❌ Données mockées pour superviseur, statut, location
- ❌ Pas de code couleur
- ❌ Pas de filtrage par agence

#### Services
- ✅ `AgenciesService` : CRUD basique
- ✅ `GroupsService` : CRUD basique
- ❌ Pas d'API pour statistiques agences
- ❌ Pas d'API pour statistiques groupes

---

### 1.3 Application Mobile Flutter

**Usage identifié :**
- Utilise `agencyId` pour filter les POIs
- Pas d'interface de gestion des agences
- Pas d'interface de gestion des groupes
- Les pèlerins appartiennent à une agence et un groupe

---

## 📋 2. BESOINS IDENTIFIÉS

### 2.1 Pour les AGENCES

#### Informations essentielles manquantes

| Catégorie | Champs nécessaires | Priorité |
|-----------|-------------------|----------|
| **Identification** | - Logo/photo de l'agence<br>- Description<br>- SIRET/Numéro d'identification | 🔴 Haute |
| **Contact** | - Téléphone principal<br>- Email principal<br>- Site web<br>- Contact principal (nom + téléphone) | 🔴 Haute |
| **Adresse** | - Rue<br>- Code postal<br>- Ville<br>- Pays (enrichir countryCode) | 🔴 Haute |
| **Commercial** | - Type de forfait (Standard, Premium, Enterprise)<br>- Date début contrat<br>- Date fin contrat<br>- Statut (Actif, Suspendu, Résilié) | 🟠 Moyenne |
| **Statistiques** (calculées) | - Nombre total de pèlerins<br>- Nombre de groupes<br>- Nombre de comptes admin<br>- Nombre de comptes users | 🟢 Basse |

#### Fonctionnalités attendues

**Page Liste des Agences :**
- ✅ Tableau avec : Logo, Nom, Pays, Email, Téléphone, Forfait, Statut, Actions
- ✅ Filtres : Pays, Forfait, Statut
- ✅ Recherche par nom
- ✅ Pagination
- ✅ Bouton "Créer une agence" (SUPER_ADMIN uniquement)

**Page Détail/Édition Agence :**
- ✅ Onglet "Informations générales"
  - Logo (upload d'image)
  - Nom, Description
  - SIRET, Pays
- ✅ Onglet "Contact"
  - Téléphone, Email, Site web
  - Adresse complète
  - Contact principal
- ✅ Onglet "Abonnement"
  - Type forfait
  - Dates contrat
  - Statut
- ✅ Onglet "Statistiques"
  - Nombre de pèlerins (graphique temporel)
  - Nombre de groupes
  - Nombre d'admins
  - Alertes actives
- ✅ Onglet "Groupes" (liste des groupes de l'agence)
- ✅ Onglet "Utilisateurs" (liste des admins/users)

**Droits d'accès :**
- `ROLE_SUPER_ADMIN` : Tout voir et éditer
- `ROLE_AGENCE_ADMIN` : Voir et éditer SA propre agence uniquement
- `ROLE_AGENCE_USER` : Voir SA propre agence uniquement (lecture seule)

---

### 2.2 Pour les GROUPES

#### Informations essentielles manquantes

| Catégorie | Champs nécessaires | Priorité |
|-----------|-------------------|----------|
| **Identification** | - Code couleur (HEX) pour distinction visuelle<br>- Description du groupe<br>- Capacité maximale | 🔴 Haute |
| **Encadrant/Guide** | - Nom complet<br>- Photo<br>- Téléphone<br>- Email | 🔴 Haute |
| **Programme** | - Date début<br>- Date fin<br>- Lieu de rassemblement<br>- Itinéraire/Programme | 🟠 Moyenne |
| **Statut** | - Statut (EN_PREPARATION, ACTIF, TERMINE, ANNULE) | 🔴 Haute |
| **Statistiques** (calculées) | - Nombre de pèlerins total<br>- Pèlerins OK<br>- Pèlerins SOS<br>- Pèlerins inactifs<br>- Position moyenne du groupe | 🟢 Basse |

#### Fonctionnalités attendues

**Page Liste des Groupes (améliorée) :**
- ✅ Tableau avec :
  - Pastille colorée (code couleur)
  - Nom du groupe
  - Agence (si SUPER_ADMIN)
  - Encadrant (photo + nom + téléphone)
  - Nombre de pèlerins (OK / SOS / Inactifs)
  - Statut (badge)
  - Lieu actuel (dernière position moyenne)
  - Actions
- ✅ Filtres avancés :
  - Par agence (SUPER_ADMIN uniquement)
  - Par encadrant (dropdown liste des guides)
  - Par statut (EN_PREPARATION, ACTIF, TERMINÉ, ANNULÉ)
  - Par couleur (sélecteur de couleurs)
- ✅ Recherche par nom de groupe
- ✅ Pagination
- ✅ Bouton "Créer un groupe"
- ✅ Vue carte : afficher les groupes sur la carte avec code couleur

**Page Détail/Édition Groupe :**
- ✅ Onglet "Informations générales"
  - Nom du groupe
  - Code couleur (color picker)
  - Description
  - Capacité maximale
  - Agence (non modifiable si AGENCE_ADMIN)
- ✅ Onglet "Encadrant"
  - Sélection du guide (dropdown des users avec role GUIDE)
  - Affichage : photo, nom, email, téléphone
  - Bouton "Contacter" (mail/WhatsApp)
- ✅ Onglet "Programme"
  - Date début / fin
  - Lieu de rassemblement
  - Itinéraire (textarea ou éditeur riche)
- ✅ Onglet "Pèlerins" (liste des pèlerins du groupe)
  - Tableau avec : photo, nom, statut, position, actions
  - Filtres : statut (OK/SOS/Inactifs)
  - Bouton "Ajouter des pèlerins"
  - Bouton "Retirer du groupe"
- ✅ Onglet "Statistiques"
  - Graphique répartition (OK/SOS/Inactifs)
  - Timeline des positions du groupe
  - Alertes du groupe
- ✅ Onglet "Carte"
  - Carte centrée sur la position moyenne du groupe
  - Tous les pèlerins du groupe avec la couleur du groupe
  - Filtres : OK/SOS/Inactifs

**Droits d'accès :**
- `ROLE_SUPER_ADMIN` : Tout voir et éditer, tous les groupes
- `ROLE_AGENCE_ADMIN` : Voir et éditer les groupes de SON agence uniquement
- `ROLE_AGENCE_USER` : Voir les groupes de SON agence uniquement (lecture seule)

---

## 🎨 3. PROPOSITIONS DE DESIGN

### 3.1 Page Liste Agences

```
┌─────────────────────────────────────────────────────────────────────┐
│ 🏢 Gestion des Agences                          [+ Créer une agence]│
├─────────────────────────────────────────────────────────────────────┤
│ 🔍 Recherche...  [Pays: Tous ▼] [Forfait: Tous ▼] [Statut: Tous ▼] │
├─────────────────────────────────────────────────────────────────────┤
│ Logo  │ Nom        │ Pays  │ Email         │ Téléphone   │ Forfait │ Statut │ Actions     │
│────────────────────────────────────────────────────────────────────│
│ [🏢] │ Al-Barakah│ 🇫🇷 FR│ contact@...   │ +33 1 23..  │Premium  │🟢 Actif│ [👁][✏️][🗑️]│
│ [🏢] │ Omra Plus  │ 🇲🇦 MA│ info@...      │ +212 5 22.. │Standard │🟢 Actif│ [👁][✏️][🗑️]│
│ [🏢] │ Mambrouk   │ 🇹🇳 TN│ admin@...     │ +216 71..   │Enter.   │🟢 Actif│ [👁][✏️][🗑️]│
└─────────────────────────────────────────────────────────────────────┘
                                                       Page 1 sur 3
```

---

### 3.2 Page Détail Agence

```
┌─────────────────────────────────────────────────────────────────────┐
│ ← Retour   🏢 Al-Barakah                                [✏️ Éditer] │
├─────────────────────────────────────────────────────────────────────┤
│ [Général] [Contact] [Abonnement] [Statistiques] [Groupes] [Users]   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [Logo]       Al-Barakah Travel Agency                              │
│               🇫🇷 France                                             │
│               SIRET: 123 456 789 00012                              │
│                                                                      │
│  Description :                                                       │
│  Agence spécialisée dans l'organisation de pèlerinages depuis 1995 │
│                                                                      │
│  📊 Statistiques :                                                  │
│  ├─ 📍 150 pèlerins actifs                                          │
│  ├─ 👥 12 groupes                                                   │
│  ├─ 🔑 5 comptes admin                                              │
│  └─ 🚨 2 alertes actives                                            │
│                                                                      │
│  📈 Évolution des pèlerins (30 derniers jours)                      │
│  [Graphique ligne temporelle]                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 3.3 Page Liste Groupes (améliorée)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ 👥 Gestion des Groupes                                          [+ Créer un groupe]  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ 🔍 Recherche...  [Agence: Toutes ▼] [Encadrant: Tous ▼] [Statut: Tous ▼] [Vue: 📋]│
├─────────────────────────────────────────────────────────────────────────────────────┤
│●│Nom         │ Agence      │ Encadrant         │ Pèlerins        │ Statut  │ Lieu      │ Actions     │
│─────────────────────────────────────────────────────────────────────────────────────│
│🔵│Groupe A1  │ Al-Barakah │ [👤] Mohammed Ali │ 25 (23🟢 2🔴)   │🟢 Actif │ La Mecque │ [👁][✏️][🗑️]│
│      │           │            │ +33 6 12 34 56   │                 │         │           │             │
│🟢│Groupe B2  │ Omra Plus   │ [👤] Amina Khan   │ 30 (30🟢 0🔴)   │🟢 Actif │ Médine    │ [👁][✏️][🗑️]│
│      │           │            │ +212 6 78 90 12  │                 │         │           │             │
│🟡│Groupe C3  │ Mambrouk    │ [👤] Ibrahim H.   │ 18 (15🟢 3🔴)   │🟠 Prép. │ Riyad     │ [👁][✏️][🗑️]│
│      │           │            │ +216 9 23 45 67  │                 │         │           │             │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

**Légende :**
- ● = Pastille de couleur du groupe
- 🟢 = Pèlerins OK
- 🔴 = Pèlerins SOS
- ⚫ = Pèlerins inactifs

---

### 3.4 Page Détail Groupe

```
┌──────────────────────────────────────────────────────────────────────┐
│ ← Retour   🔵 Groupe A1                                  [✏️ Éditer] │
├──────────────────────────────────────────────────────────────────────┤
│ [Général] [Encadrant] [Programme] [Pèlerins] [Stats] [Carte]        │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  🔵 Groupe A1                                                        │
│  🏢 Agence : Al-Barakah                                              │
│  📅 15/01/2025 - 25/01/2025                                          │
│  📍 Lieu de rassemblement : Hôtel Al-Firdaws, La Mecque            │
│  👤 Capacité : 25 / 30 pèlerins                                     │
│  🟢 Statut : ACTIF                                                  │
│                                                                       │
│  Description :                                                        │
│  Groupe francophone pour le Hajj 2025. Programme complet avec      │
│  accompagnement spirituel et logistique.                             │
│                                                                       │
│  📊 Statistiques en temps réel :                                    │
│  ┌────────────┬────────────┬────────────┐                          │
│  │ 🟢 OK: 23  │ 🔴 SOS: 2  │ ⚫ Inac: 0 │                          │
│  └────────────┴────────────┴────────────┘                          │
│                                                                       │
│  🗺️ Position moyenne : La Mecque (21.4225, 39.8262)                 │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 4. MODIFICATIONS TECHNIQUES NÉCESSAIRES

### 4.1 Backend (Spring Boot)

#### Modifications de `Agency`
```java
@Entity
@Table(name = "agencies")
public class Agency extends AbstractAuditableEntity {
    @Id
    private UUID id;
    
    // ✅ Existants
    @Column(nullable = false)
    private String name;
    
    @Column(name = "country_code", nullable = false)
    private String countryCode;
    
    @Column(name = "settings_json", columnDefinition = "jsonb")
    private String settingsJson;
    
    // 🆕 À AJOUTER
    @Column(name = "logo_url")
    private String logoUrl;
    
    @Column(name = "description", columnDefinition = "text")
    private String description;
    
    @Column(name = "identification_number")
    private String identificationNumber; // SIRET, etc.
    
    @Column(name = "email")
    private String email;
    
    @Column(name = "phone")
    private String phone;
    
    @Column(name = "website")
    private String website;
    
    @Column(name = "contact_person_name")
    private String contactPersonName;
    
    @Column(name = "contact_person_phone")
    private String contactPersonPhone;
    
    // Adresse
    @Column(name = "address_street")
    private String addressStreet;
    
    @Column(name = "address_city")
    private String addressCity;
    
    @Column(name = "address_postal_code")
    private String addressPostalCode;
    
    @Column(name = "address_country")
    private String addressCountry;
    
    // Commercial
    @Enumerated(EnumType.STRING)
    @Column(name = "subscription_type")
    private SubscriptionType subscriptionType; // STANDARD, PREMIUM, ENTERPRISE
    
    @Column(name = "contract_start_date")
    private LocalDate contractStartDate;
    
    @Column(name = "contract_end_date")
    private LocalDate contractEndDate;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private AgencyStatus status; // ACTIVE, SUSPENDED, TERMINATED
    
    // Relations
    @OneToMany(mappedBy = "agency")
    private Set<User> users;
    
    @OneToMany(mappedBy = "agency")
    private Set<Group> groups;
}

// Enums à créer
public enum SubscriptionType {
    STANDARD, PREMIUM, ENTERPRISE
}

public enum AgencyStatus {
    ACTIVE, SUSPENDED, TERMINATED
}
```

#### Modifications de `Group`
```java
@Entity
@Table(name = "groups")
public class Group extends AbstractAuditableEntity {
    @Id
    private UUID id;
    
    // ✅ Existants
    @ManyToOne
    @JoinColumn(name = "agency_id", nullable = false)
    private Agency agency;
    
    @Column(nullable = false)
    private String name;
    
    @ManyToOne
    @JoinColumn(name = "guide_id", nullable = false)
    private User guide; // Encadrant
    
    @OneToMany(mappedBy = "group")
    private Set<User> users; // Pèlerins
    
    // 🆕 À AJOUTER
    @Column(name = "color_code", length = 7)
    private String colorCode; // Format HEX : #FF5733
    
    @Column(name = "description", columnDefinition = "text")
    private String description;
    
    @Column(name = "max_capacity")
    private Integer maxCapacity;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private GroupStatus status; // EN_PREPARATION, ACTIF, TERMINE, ANNULE
    
    @Column(name = "start_date")
    private LocalDate startDate;
    
    @Column(name = "end_date")
    private LocalDate endDate;
    
    @Column(name = "rally_point")
    private String rallyPoint; // Lieu de rassemblement
    
    @Column(name = "itinerary", columnDefinition = "text")
    private String itinerary;
}

// Enum à créer
public enum GroupStatus {
    EN_PREPARATION, ACTIF, TERMINE, ANNULE
}
```

#### Nouveaux DTOs

**`AgencyDetailDto.java` :**
```java
public record AgencyDetailDto(
    UUID id,
    String name,
    String countryCode,
    String logoUrl,
    String description,
    String identificationNumber,
    String email,
    String phone,
    String website,
    String contactPersonName,
    String contactPersonPhone,
    AddressDto address,
    SubscriptionDto subscription,
    AgencyStatsDto stats
) {}

public record AddressDto(
    String street,
    String city,
    String postalCode,
    String country
) {}

public record SubscriptionDto(
    String type,
    LocalDate startDate,
    LocalDate endDate,
    String status
) {}

public record AgencyStatsDto(
    long totalPilgrims,
    long totalGroups,
    long totalAdmins,
    long totalUsers,
    long activeAlerts
) {}
```

**`GroupDetailDto.java` :**
```java
public record GroupDetailDto(
    UUID id,
    String name,
    UUID agencyId,
    String agencyName,
    String colorCode,
    String description,
    Integer maxCapacity,
    Integer currentSize,
    GroupGuideDto guide,
    String status,
    LocalDate startDate,
    LocalDate endDate,
    String rallyPoint,
    String itinerary,
    GroupStatsDto stats
) {}

public record GroupGuideDto(
    UUID id,
    String fullName,
    String email,
    String phone,
    String photoUrl
) {}

public record GroupStatsDto(
    int totalPilgrims,
    int pilgrimsOk,
    int pilgrimsSos,
    int pilgrimsInactive,
    Double avgLatitude,
    Double avgLongitude
) {}
```

#### Nouveaux endpoints API

**`AgencyController.java` :**
```java
@GetMapping("/{id}/details")
@PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN')")
public ResponseEntity<AgencyDetailDto> getAgencyDetails(@PathVariable UUID id) {
    // Retourne toutes les informations enrichies + stats
}

@GetMapping("/{id}/stats")
@PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN')")
public ResponseEntity<AgencyStatsDto> getAgencyStats(@PathVariable UUID id) {
    // Stats calculées en temps réel
}

@PostMapping("/{id}/logo")
@PreAuthorize("hasRole('SUPER_ADMIN')")
public ResponseEntity<String> uploadLogo(@PathVariable UUID id, @RequestParam MultipartFile file) {
    // Upload logo et retourne l'URL
}
```

**`GroupController.java` :**
```java
@GetMapping("/{id}/details")
@PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN','AGENCE_USER')")
public ResponseEntity<GroupDetailDto> getGroupDetails(@PathVariable UUID id) {
    // Retourne toutes les informations enrichies + stats
}

@GetMapping("/{id}/pilgrims")
@PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN','AGENCE_USER')")
public ResponseEntity<List<PilgrimDto>> getGroupPilgrims(@PathVariable UUID id, 
                                                          @RequestParam(required = false) String status) {
    // Liste des pèlerins du groupe avec filtre optionnel par statut
}

@PostMapping("/{id}/pilgrims/{pilgrimId}")
@PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN')")
public ResponseEntity<Void> addPilgrimToGroup(@PathVariable UUID id, @PathVariable UUID pilgrimId) {
    // Ajouter un pèlerin au groupe
}

@DeleteMapping("/{id}/pilgrims/{pilgrimId}")
@PreAuthorize("hasAnyRole('SUPER_ADMIN','AGENCE_ADMIN')")
public ResponseEntity<Void> removePilgrimFromGroup(@PathVariable UUID id, @PathVariable UUID pilgrimId) {
    // Retirer un pèlerin du groupe
}
```

---

### 4.2 Dashboard React

#### Nouveaux composants à créer

```
src/
├── pages/
│   ├── AgenciesPage.tsx              (🆕 Liste)
│   ├── AgencyDetailPage.tsx          (🆕 Détail/Édition)
│   ├── AgencyFormPage.tsx            (🆕 Création)
│   ├── GroupsPage.tsx                (✏️ Améliorer existant)
│   ├── GroupDetailPage.tsx           (🆕 Détail/Édition)
│   └── GroupFormPage.tsx             (🆕 Création)
├── components/
│   ├── agencies/
│   │   ├── AgencyCard.tsx            (🆕)
│   │   ├── AgencyForm.tsx            (🆕)
│   │   ├── AgencyStats.tsx           (🆕)
│   │   └── AgencyLogoUpload.tsx      (🆕)
│   ├── groups/
│   │   ├── GroupCard.tsx             (🆕)
│   │   ├── GroupForm.tsx             (🆕)
│   │   ├── GroupColorPicker.tsx      (🆕)
│   │   ├── GroupPilgrimsList.tsx     (🆕)
│   │   ├── GroupStats.tsx            (🆕)
│   │   └── GroupMapView.tsx          (🆕)
│   └── ui/
│       └── ColorPicker.tsx           (🆕)
├── services/
│   ├── agencies.service.ts           (✏️ Enrichir)
│   └── groups.service.ts             (✏️ Enrichir)
└── types/
    ├── agency.types.ts               (🆕)
    └── group.types.ts                (🆕)
```

#### Types TypeScript

**`agency.types.ts` :**
```typescript
export type SubscriptionType = 'STANDARD' | 'PREMIUM' | 'ENTERPRISE';
export type AgencyStatus = 'ACTIVE' | 'SUSPENDED' | 'TERMINATED';

export interface Address {
  street: string;
  city: string;
  postalCode: string;
  country: string;
}

export interface Subscription {
  type: SubscriptionType;
  startDate: string;
  endDate: string;
  status: AgencyStatus;
}

export interface AgencyStats {
  totalPilgrims: number;
  totalGroups: number;
  totalAdmins: number;
  totalUsers: number;
  activeAlerts: number;
}

export interface AgencyDetail {
  id: string;
  name: string;
  countryCode: string;
  logoUrl?: string;
  description?: string;
  identificationNumber?: string;
  email: string;
  phone: string;
  website?: string;
  contactPersonName?: string;
  contactPersonPhone?: string;
  address: Address;
  subscription: Subscription;
  stats: AgencyStats;
  createdAt: string;
  updatedAt: string;
}
```

**`group.types.ts` :**
```typescript
export type GroupStatus = 'EN_PREPARATION' | 'ACTIF' | 'TERMINE' | 'ANNULE';

export interface GroupGuide {
  id: string;
  fullName: string;
  email: string;
  phone: string;
  photoUrl?: string;
}

export interface GroupStats {
  totalPilgrims: number;
  pilgrimsOk: number;
  pilgrimsSos: number;
  pilgrimsInactive: number;
  avgLatitude?: number;
  avgLongitude?: number;
}

export interface GroupDetail {
  id: string;
  name: string;
  agencyId: string;
  agencyName: string;
  colorCode: string;  // HEX color
  description?: string;
  maxCapacity: number;
  currentSize: number;
  guide: GroupGuide;
  status: GroupStatus;
  startDate: string;
  endDate: string;
  rallyPoint?: string;
  itinerary?: string;
  stats: GroupStats;
  createdAt: string;
  updatedAt: string;
}
```

---

### 4.3 Base de données

#### Migration Liquibase `008-enhance-agencies-groups.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.24.xsd">

    <!-- Enrichissement table agencies -->
    <changeSet id="008-1-enhance-agencies" author="ramzi">
        <addColumn tableName="agencies">
            <column name="logo_url" type="VARCHAR(500)"/>
            <column name="description" type="TEXT"/>
            <column name="identification_number" type="VARCHAR(50)"/>
            <column name="email" type="VARCHAR(255)"/>
            <column name="phone" type="VARCHAR(20)"/>
            <column name="website" type="VARCHAR(255)"/>
            <column name="contact_person_name" type="VARCHAR(255)"/>
            <column name="contact_person_phone" type="VARCHAR(20)"/>
            <column name="address_street" type="VARCHAR(255)"/>
            <column name="address_city" type="VARCHAR(100)"/>
            <column name="address_postal_code" type="VARCHAR(20)"/>
            <column name="address_country" type="VARCHAR(100)"/>
            <column name="subscription_type" type="VARCHAR(20)" defaultValue="STANDARD"/>
            <column name="contract_start_date" type="DATE"/>
            <column name="contract_end_date" type="DATE"/>
            <column name="status" type="VARCHAR(20)" defaultValue="ACTIVE"/>
        </addColumn>
    </changeSet>

    <!-- Enrichissement table groups -->
    <changeSet id="008-2-enhance-groups" author="ramzi">
        <addColumn tableName="groups">
            <column name="color_code" type="VARCHAR(7)" defaultValue="#3B82F6"/>
            <column name="description" type="TEXT"/>
            <column name="max_capacity" type="INTEGER"/>
            <column name="status" type="VARCHAR(20)" defaultValue="EN_PREPARATION"/>
            <column name="start_date" type="DATE"/>
            <column name="end_date" type="DATE"/>
            <column name="rally_point" type="VARCHAR(255)"/>
            <column name="itinerary" type="TEXT"/>
        </addColumn>
    </changeSet>

    <!-- Index pour performances -->
    <changeSet id="008-3-add-indexes" author="ramzi">
        <createIndex tableName="agencies" indexName="idx_agencies_status">
            <column name="status"/>
        </createIndex>
        <createIndex tableName="agencies" indexName="idx_agencies_subscription">
            <column name="subscription_type"/>
        </createIndex>
        <createIndex tableName="groups" indexName="idx_groups_status">
            <column name="status"/>
        </createIndex>
        <createIndex tableName="groups" indexName="idx_groups_dates">
            <column name="start_date"/>
            <column name="end_date"/>
        </createIndex>
    </changeSet>

</databaseChangeLog>
```

---

## 📦 5. PLAN D'IMPLÉMENTATION

### Phase 1 : Backend (2-3 jours)
1. ✅ Créer migration Liquibase `008-enhance-agencies-groups.xml`
2. ✅ Modifier entités `Agency` et `Group`
3. ✅ Créer enums `SubscriptionType`, `AgencyStatus`, `GroupStatus`
4. ✅ Créer DTOs enrichis : `AgencyDetailDto`, `GroupDetailDto`, etc.
5. ✅ Enrichir `AgencyService` avec méthodes statistiques
6. ✅ Enrichir `GroupService` avec méthodes statistiques
7. ✅ Ajouter endpoints dans `AgencyController`
8. ✅ Ajouter endpoints dans `GroupController`
9. ✅ Mettre à jour `openapi.yaml`
10. ✅ Tests unitaires et d'intégration

### Phase 2 : Dashboard - Agences (2 jours)
1. ✅ Créer types TypeScript `agency.types.ts`
2. ✅ Enrichir `agencies.service.ts`
3. ✅ Créer `AgenciesPage.tsx` (liste)
4. ✅ Créer `AgencyDetailPage.tsx` (détail avec onglets)
5. ✅ Créer `AgencyFormPage.tsx` (création/édition)
6. ✅ Créer composants :
   - `AgencyCard.tsx`
   - `AgencyForm.tsx`
   - `AgencyStats.tsx`
   - `AgencyLogoUpload.tsx`
7. ✅ Ajouter routes dans le router
8. ✅ Ajouter menu dans la navigation

### Phase 3 : Dashboard - Groupes (2 jours)
1. ✅ Créer types TypeScript `group.types.ts`
2. ✅ Enrichir `groups.service.ts`
3. ✅ Améliorer `GroupsPage.tsx` (liste avec filtres)
4. ✅ Créer `GroupDetailPage.tsx` (détail avec onglets)
5. ✅ Créer `GroupFormPage.tsx` (création/édition)
6. ✅ Créer composants :
   - `GroupCard.tsx`
   - `GroupForm.tsx`
   - `GroupColorPicker.tsx`
   - `GroupPilgrimsList.tsx`
   - `GroupStats.tsx`
   - `GroupMapView.tsx`
7. ✅ Créer `ColorPicker.tsx` (composant UI réutilisable)
8. ✅ Tests et validations

### Phase 4 : Intégration carte (1 jour)
1. ✅ Modifier `MapPage` pour afficher les groupes avec code couleur
2. ✅ Ajouter filtre par groupe dans la carte
3. ✅ Vue carte dans `GroupDetailPage` (onglet Carte)

### Phase 5 : Tests & Documentation (1 jour)
1. ✅ Tests end-to-end
2. ✅ Documentation utilisateur
3. ✅ Guide d'administration

---

## 🎯 6. PRIORITÉS

### 🔴 Priorité HAUTE (faire en premier)
1. Migration BDD + Entités backend
2. DTOs et endpoints CRUD basiques
3. Page Liste Agences (basique)
4. Page Liste Groupes améliorée (avec couleurs)
5. Formulaires création/édition Agence et Groupe

### 🟠 Priorité MOYENNE (ensuite)
1. Statistiques agences et groupes
2. Pages détail avec onglets
3. Filtres avancés
4. Gestion des pèlerins dans les groupes

### 🟢 Priorité BASSE (si temps)
1. Upload de logos
2. Graphiques et visualisations avancées
3. Export Excel/PDF
4. Notifications et alertes

---

## ✅ 7. CHECKLIST FINALE

### Backend
- [ ] Migration Liquibase créée et testée
- [ ] Entités `Agency` et `Group` enrichies
- [ ] DTOs créés et validés
- [ ] Services avec méthodes statistiques
- [ ] Controllers avec nouveaux endpoints
- [ ] OpenAPI mis à jour
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Documentation API générée

### Dashboard
- [ ] Types TypeScript créés
- [ ] Services enrichis
- [ ] Page Liste Agences fonctionnelle
- [ ] Page Détail Agence fonctionnelle
- [ ] Formulaire Agence fonctionnel
- [ ] Page Liste Groupes améliorée
- [ ] Page Détail Groupe fonctionnelle
- [ ] Formulaire Groupe fonctionnel
- [ ] ColorPicker fonctionnel
- [ ] Filtres fonctionnels
- [ ] Carte intégrée avec couleurs
- [ ] Tests E2E passent
- [ ] Responsive vérifié

### Documentation
- [ ] README mis à jour
- [ ] Guide utilisateur créé
- [ ] Guide admin créé
- [ ] Screenshots ajoutés

---

## 📝 8. NOTES IMPORTANTES

### Droits d'accès à respecter
- **SUPER_ADMIN** : Accès total, toutes agences et groupes
- **AGENCE_ADMIN** : Accès à SA propre agence et SES groupes uniquement
- **AGENCE_USER** : Lecture seule de SA propre agence et SES groupes

### Codes couleur par défaut suggérés
```
#3B82F6 - Bleu (défaut)
#10B981 - Vert
#F59E0B - Orange
#EF4444 - Rouge
#8B5CF6 - Violet
#EC4899 - Rose
#06B6D4 - Cyan
#84CC16 - Lime
```

### Contraintes
- Couleur groupe : format HEX valide (#RRGGBB)
- Logo agence : max 2MB, formats JPG/PNG
- Capacité groupe : min 1, max 100
- Dates contrat : endDate > startDate
- Email et téléphone : validation format

---

**🎉 FIN DU RAPPORT D'ANALYSE**

**Prêt pour l'implémentation ?** 
Ce rapport peut servir de base pour une implémentation progressive et structurée.










