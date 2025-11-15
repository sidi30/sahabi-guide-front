# 🔍 AUDIT COMPLET DES TABLES ET ENTITÉS BACKEND - SAHABI GUIDE API

## 📊 Vue d'ensemble

**Date d'audit :** 22 Octobre 2025  
**Analysé par :** IA Assistant (Cursor)  
**Portée :** Analyse complète des entités JPA et migrations Liquibase

---

## 1. INVENTAIRE COMPLET

### 1.1 Entités JPA détectées (25 entités)

| # | Entité | Table Attendue | Statut Liquibase | Priorité |
|---|--------|----------------|------------------|----------|
| 1 | Agency | agencies | ✅ Existe | - |
| 2 | User | users | ✅ Existe | - |
| 3 | Group | groups | ✅ Existe | - |
| 4 | OtpCode | otp_codes | ✅ Existe | - |
| 5 | AuthSession | auth_sessions | ✅ Existe | - |
| 6 | HealthProfile | health_profiles | ✅ Existe | - |
| 7 | EmergencyContact | emergency_contacts | ✅ Existe | - |
| 8 | Ritual | rituals | ✅ Existe | - |
| 9 | Dua | duas | ✅ Existe | - |
| 10 | **UserRitualProgress** | **user_ritual_progress** | ❌ **MANQUANTE** | 🔴 CRITIQUE |
| 11 | Alert | alerts | ✅ Existe | - |
| 12 | Position | positions | ✅ Existe (problème) | ⚠️ À corriger |
| 13 | UserActivity | user_activities | ✅ Existe | ⚠️ Redondant |
| 14 | **PilgrimActivity** | **pilgrim_activities** | ❌ **MANQUANTE** | 🔴 CRITIQUE |
| 15 | UserSettings | user_settings | ✅ Existe | - |
| 16 | ContactMessage | contact_messages | ✅ Existe | - |
| 17 | POI | pois | ✅ Existe | - |
| 18 | Message | messages | ✅ Existe (incohérent) | ⚠️ À corriger |
| 19 | **FileObject** | **file_objects** | ❌ **MANQUANTE** | 🔴 CRITIQUE |
| 20 | ConnectivityPlan | connectivity_plans | ✅ Existe | - |
| 21 | ConnectivitySubscription | connectivity_subscriptions | ✅ Existe | - |
| 22 | ConnectivityTopup | connectivity_topups | ✅ Existe | - |
| 23 | **StatSnapshot** | **stat_snapshots** | ❌ **MANQUANTE** | 🔴 CRITIQUE |
| 24 | LocationSharingLink | location_sharing_links | ✅ Existe | - |
| 25 | GeoFence | geofences | ✅ Existe | - |

### 1.2 Tables Liquibase créées (21 tables)

```
✅ agencies
✅ groups  
✅ users
✅ otp_codes
✅ auth_sessions
✅ health_profiles
✅ emergency_contacts
✅ rituals
✅ duas
✅ alerts
✅ positions
✅ user_activities
✅ user_settings
✅ contact_messages
✅ pois
✅ messages
✅ connectivity_plans
✅ connectivity_subscriptions
✅ connectivity_topups
✅ location_sharing_links
✅ geofences
```

---

## 2. 🚨 PROBLÈMES CRITIQUES IDENTIFIÉS

### 2.1 Tables Manquantes (4 entités sans migration Liquibase)

#### ❌ **Problème #1 : `user_ritual_progress`**

**Entité :** `UserRitualProgress.java`  
**Impact :** 🔴 CRITIQUE - Le suivi des rituels ne fonctionne pas

**Description :**
L'entité `UserRitualProgress` permet de suivre la progression des pèlerins dans leurs rituels (Tawaf, Sa'i, etc.). Cette table est essentielle pour la fonctionnalité principale de l'application mais n'a jamais été créée dans Liquibase.

**Colonnes attendues :**
- `id` (UUID, PK)
- `user_id` (UUID, FK → users)
- `ritual_id` (UUID, FK → rituals)
- `status` (VARCHAR: NOT_STARTED, IN_PROGRESS, COMPLETED)
- `started_at` (TIMESTAMPTZ)
- `completed_at` (TIMESTAMPTZ)
- `created_at`, `updated_at` (TIMESTAMPTZ)

**Indexes requis :**
- `idx_urp_user` sur `user_id`
- `idx_urp_ritual` sur `ritual_id`
- `idx_urp_status` sur `status`
- Contrainte unique `uk_urp_user_ritual` sur (`user_id`, `ritual_id`)

---

#### ❌ **Problème #2 : `pilgrim_activities`**

**Entité :** `PilgrimActivity.java`  
**Impact :** 🔴 CRITIQUE - Duplication avec `user_activities`

**Description :**
L'entité `PilgrimActivity` a été créée mais la table n'existe pas dans Liquibase. De plus, elle fait **doublon avec `UserActivity`** qui a exactement la même structure et le même objectif.

**Analyse de redondance :**

| Colonne | UserActivity | PilgrimActivity | Identique ? |
|---------|--------------|-----------------|-------------|
| `id` | ✅ UUID | ✅ UUID | ✅ |
| `user_id` | ✅ UUID | ✅ UUID | ✅ |
| `type` | ✅ VARCHAR(32) | ✅ VARCHAR | ✅ |
| `occurred_at` | ✅ TIMESTAMPTZ | ✅ TIMESTAMPTZ | ✅ |
| `lat` / `lng` | ✅ DOUBLE | ✅ DOUBLE | ✅ |
| `ref_type` / `ref_id` | ✅ | ❌ | ❌ |
| `payload_json` | ✅ JSONB | ✅ JSONB | ✅ |
| `description` | ❌ | ✅ VARCHAR | ❌ |

**Verdict :** Ces deux entités sont **90% identiques** et servent le même objectif : enregistrer les activités des utilisateurs/pèlerins.

---

#### ❌ **Problème #3 : `file_objects`**

**Entité :** `FileObject.java`  
**Impact :** 🟡 MOYEN - Gestion de fichiers non fonctionnelle

**Description :**
L'entité `FileObject` gère les fichiers uploadés (photos, documents, etc.) mais la table n'a jamais été créée.

**Colonnes attendues :**
- `id` (UUID, PK)
- `owner_agency_id` (UUID, FK → agencies)
- `path` (VARCHAR, NOT NULL)
- `content_type` (VARCHAR, NOT NULL)
- `size` (BIGINT, NOT NULL)
- `created_at`, `updated_at` (TIMESTAMPTZ)

**Indexes requis :**
- `idx_file_owner` sur `owner_agency_id`
- `idx_file_path` sur `path`

---

#### ❌ **Problème #4 : `stat_snapshots`**

**Entité :** `StatSnapshot.java`  
**Impact :** 🟡 MOYEN - Dashboard sans données historiques

**Description :**
L'entité `StatSnapshot` stocke des snapshots quotidiens de statistiques pour le dashboard, mais la table n'existe pas.

**Colonnes attendues :**
- `id` (UUID, PK)
- `agency_id` (UUID, FK → agencies)
- `date` (DATE, NOT NULL)
- `metrics_json` (JSONB)
- `created_at`, `updated_at` (TIMESTAMPTZ)

**Contrainte unique :** `uk_snapshot_agency_date` sur (`agency_id`, `date`)

---

### 2.2 Incohérences entre Entités JPA et Liquibase

#### ⚠️ **Incohérence #1 : Table `positions` - Confusion sur la colonne timestamp**

**Problème détecté :**
- Migration `010-add-battery-to-positions.xml` : renomme `timestamp` → `ts`
- Migration `013-add-timestamp-to-positions.xml` : ajoute une nouvelle colonne `timestamp` 🤔

**Résultat :**
La table `positions` a maintenant **DEUX colonnes de temps** :
- `ts` (TIMESTAMPTZ) - utilisée par l'entité JPA (`@Column(name = "ts")`)
- `timestamp` (TIMESTAMPTZ) - créée par erreur dans la migration 013

**Impact :** Confusion, redondance de données, risque de bugs

---

#### ⚠️ **Incohérence #2 : Table `messages` - Structure différente**

**Entité JPA `Message.java` :**
```java
@ManyToOne private User fromUser;        // from_user_id
@ManyToOne private Group toGroup;        // to_group_id
@ManyToOne private User toUser;          // to_user_id
@Enumerated private MessageType type;
private String text;
private String mediaUrl;
@Column(name = "ts") private Instant timestamp;
```

**Table Liquibase `messages` (001-create-core-schema.xml) :**
```xml
<column name="sender_id" />        <!-- ≠ from_user_id -->
<column name="recipient_id" />     <!-- ≠ to_user_id -->
<column name="agency_id" />        <!-- Non mappé dans l'entité -->
<column name="group_id" />         <!-- ≠ to_group_id -->
<column name="content" />          <!-- ≠ text -->
<column name="read_at" />          <!-- Non mappé dans l'entité -->
```

**Impact :** Les noms de colonnes ne correspondent pas → **l'application ne peut pas envoyer/recevoir de messages correctement**.

---

### 2.3 Redondances et Tables à Simplifier

#### 🔄 **Redondance #1 : `user_activities` vs `pilgrim_activities`**

**Analyse :**
Ces deux tables ont la même structure et servent le même objectif. Avoir deux tables séparées complexifie inutilement :
- Les requêtes (besoin de faire des UNION)
- La maintenance du code
- Les migrations de données

**Recommandation :** **Fusionner en une seule table `user_activities`**

**Justification :**
- `user_activities` existe déjà dans Liquibase
- Elle a tous les champs nécessaires
- La colonne `type` permet de différencier les types d'activités
- Les colonnes `ref_type` et `ref_id` permettent de lier à n'importe quelle entité

---

#### 🔄 **Redondance #2 : Colonnes dupliquées dans `users`**

**Colonnes en double :**
```sql
first_name + last_name  ≈  full_name
```

**Analyse :**
La table `users` stocke à la fois `first_name`/`last_name` ET `full_name`, ce qui crée une redondance. Cependant, cette redondance a un intérêt pour :
- Les noms qui ne se décomposent pas facilement (certains noms arabes)
- Les performances (éviter la concaténation à chaque requête)

**Recommandation :** **Conserver les deux**, mais ajouter un trigger ou une logique métier pour synchroniser automatiquement `full_name` = `first_name || ' ' || last_name`.

---

## 3. 📋 RECOMMANDATIONS ET PLAN D'ACTION

### 3.1 Actions Prioritaires (À faire immédiatement)

#### ✅ **Action #1 : Créer les 4 tables manquantes**

**Priorité :** 🔴 CRITIQUE  
**Effort :** 2h  

**Fichiers à créer :**
1. `014-create-user-ritual-progress.xml`
2. `015-create-file-objects.xml`
3. `016-create-stat-snapshots.xml`

**Note :** Ne PAS créer `pilgrim_activities` (voir Action #2)

---

#### ✅ **Action #2 : Supprimer l'entité `PilgrimActivity` et utiliser `UserActivity`**

**Priorité :** 🔴 CRITIQUE  
**Effort :** 1h

**Étapes :**
1. Supprimer le fichier `PilgrimActivity.java`
2. Supprimer `PilgrimActivityRepository.java`
3. Modifier les services qui utilisent `PilgrimActivity` pour utiliser `UserActivity`
4. Nettoyer les imports

**Avantages :**
- Simplifie l'architecture
- Évite la confusion
- Réduit le code dupliqué

---

#### ✅ **Action #3 : Corriger la table `messages`**

**Priorité :** 🔴 CRITIQUE  
**Effort :** 1h

**Options :**

**Option A : Adapter Liquibase à l'entité JPA (RECOMMANDÉ)**
```xml
<!-- Migration 017-fix-messages-schema.xml -->
<renameColumn tableName="messages" oldColumnName="sender_id" newColumnName="from_user_id"/>
<renameColumn tableName="messages" oldColumnName="recipient_id" newColumnName="to_user_id"/>
<renameColumn tableName="messages" oldColumnName="group_id" newColumnName="to_group_id"/>
<renameColumn tableName="messages" oldColumnName="content" newColumnName="text"/>
<addColumn tableName="messages">
    <column name="type" type="VARCHAR(20)">
        <constraints nullable="false"/>
    </column>
    <column name="media_url" type="VARCHAR(512)"/>
    <column name="ts" type="TIMESTAMP WITH TIME ZONE">
        <constraints nullable="false"/>
    </column>
</addColumn>
<dropColumn tableName="messages" columnName="agency_id"/>
```

**Option B : Adapter l'entité JPA à Liquibase**
Modifier `Message.java` pour utiliser les noms de colonnes existants avec `@Column(name="...")`.

**Recommandation :** **Option A** - Les noms dans l'entité JPA sont plus clairs.

---

#### ✅ **Action #4 : Nettoyer la confusion sur `positions.timestamp`**

**Priorité :** 🟡 MOYEN  
**Effort :** 30min

**Solution :**
```xml
<!-- Migration 018-cleanup-positions-timestamp.xml -->
<!-- Supprimer la colonne 'timestamp' créée par erreur -->
<dropColumn tableName="positions" columnName="timestamp"/>
<!-- Garder uniquement 'ts' utilisée par l'entité JPA -->
```

---

### 3.2 Actions Secondaires (Optimisations)

#### ✅ **Action #5 : Ajouter des indexes manquants**

**Priorité :** 🟢 BASSE  
**Effort :** 30min

**Indexes à ajouter :**
```sql
-- Pour améliorer les performances des requêtes fréquentes
CREATE INDEX idx_positions_user_ts ON positions(user_id, ts DESC);
CREATE INDEX idx_alerts_user_status ON alerts(user_id, status) WHERE user_id IS NOT NULL;
CREATE INDEX idx_messages_group_ts ON messages(to_group_id, ts DESC);
```

---

#### ✅ **Action #6 : Normaliser les types TIMESTAMP**

**Priorité :** 🟢 BASSE  
**Effort :** 1h

**Problème détecté :**
Certaines tables utilisent `TIMESTAMP` au lieu de `TIMESTAMP WITH TIME ZONE`.

**Tables concernées :**
- `connectivity_plans` (created_at, updated_at)
- `connectivity_subscriptions` (created_at, updated_at)
- `connectivity_topups` (timestamp)

**Solution :**
```sql
ALTER TABLE connectivity_plans 
  ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE,
  ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE;
```

---

## 4. 📐 PROPOSITION DE REFONTE SIMPLIFIÉE

### 4.1 Architecture Optimisée

**Nombre actuel de tables :** 21 (+ 4 manquantes) = 25 tables  
**Nombre proposé :** 24 tables (après fusion/nettoyage)

### 4.2 Entités à Supprimer

| Entité à Supprimer | Raison | Remplacée par |
|--------------------|--------|---------------|
| `PilgrimActivity` | Redondance complète | `UserActivity` |

### 4.3 Tables à Ajouter

| Table | Raison | Priorité |
|-------|--------|----------|
| `user_ritual_progress` | Fonctionnalité manquante critique | 🔴 |
| `file_objects` | Gestion de fichiers | 🟡 |
| `stat_snapshots` | Dashboard historique | 🟡 |

### 4.4 Tables à Corriger

| Table | Problème | Solution |
|-------|----------|----------|
| `messages` | Noms de colonnes incohérents | Migration de renommage |
| `positions` | Colonne `timestamp` en double | Suppression de la colonne en trop |

---

## 5. 🎯 RÉSUMÉ EXÉCUTIF

### Situation Actuelle
- ✅ **21 tables** créées dans Liquibase
- ✅ **25 entités** JPA définies
- ❌ **4 tables manquantes** critiques
- ❌ **2 incohérences** majeures (messages, positions)
- ⚠️ **1 redondance** importante (activities)

### Recommandations Clés
1. 🔴 **Créer les 3 tables manquantes** : `user_ritual_progress`, `file_objects`, `stat_snapshots`
2. 🔴 **Supprimer l'entité** `PilgrimActivity` (redondante)
3. 🔴 **Corriger la table** `messages` (noms de colonnes)
4. 🟡 **Nettoyer la table** `positions` (supprimer colonne en double)
5. 🟢 **Optimiser les indexes** pour les performances

### Impact Estimé
- **Effort total :** ~6 heures
- **Bénéfices :**
  - ✅ Base de données cohérente avec les entités JPA
  - ✅ Fonctionnalités manquantes opérationnelles
  - ✅ Code plus maintenable
  - ✅ Performances optimisées

---

## 6. 📝 CONCLUSION

Votre base de données est **bien structurée dans l'ensemble**, mais présente quelques **incohérences critiques** qui empêchent certaines fonctionnalités de fonctionner correctement. Les problèmes identifiés sont **tous réparables** avec des migrations Liquibase ciblées.

La **priorité absolue** est de :
1. Créer les tables manquantes (`user_ritual_progress` en premier)
2. Corriger les incohérences (`messages`, `positions`)
3. Supprimer les redondances (`PilgrimActivity`)

Une fois ces corrections appliquées, votre architecture sera **cohérente, optimisée et prête pour la production**.

---

**Prochaine étape :** Génération des migrations Liquibase pour corriger tous ces problèmes ? 🚀

