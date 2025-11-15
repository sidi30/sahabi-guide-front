# 🔧 PLAN DE REFONTE DES ENTITÉS - SAHABI GUIDE API

## 📅 Date : 22 Octobre 2025

---

## ✅ ÉTAPE 1 : MIGRATIONS LIQUIBASE (COMPLÉTÉ)

### Fichiers créés :

1. ✅ `014-create-user-ritual-progress.xml` - Table pour le suivi des rituels
2. ✅ `015-create-file-objects.xml` - Table pour la gestion de fichiers
3. ✅ `016-create-stat-snapshots.xml` - Table pour les statistiques du dashboard
4. ✅ `017-fix-messages-schema.xml` - Correction de la table messages
5. ✅ `018-cleanup-positions-timestamp.xml` - Nettoyage de la colonne timestamp
6. ✅ `019-normalize-timestamps.xml` - Normalisation des types TIMESTAMP
7. ✅ `020-add-performance-indexes.xml` - Ajout d'indexes de performance

### Fichier master mis à jour :
✅ `db.changelog-master.xml` - Inclusion de toutes les nouvelles migrations

---

## 🔄 ÉTAPE 2 : SUPPRESSION DE L'ENTITÉ REDONDANTE `PilgrimActivity`

### 2.1 Analyse de l'utilisation

**Fichiers à vérifier :**
```
sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/feature/activities/
  - domain/PilgrimActivity.java (entité à supprimer)
  - infra/PilgrimActivityRepository.java (repository à supprimer)
  - app/* (services utilisant PilgrimActivity)
```

### 2.2 Plan de migration

#### Option A : Migration automatique des données (RECOMMANDÉ)

Si des données `PilgrimActivity` existent déjà en mémoire/cache :

```java
// Dans ActivitiesService.java
@Transactional
public void migratePilgrimActivitiesToUserActivities() {
    // Note: Cette méthode n'est nécessaire que si des données 
    // PilgrimActivity ont été créées avant la suppression
    
    List<PilgrimActivity> pilgrimActivities = pilgrimActivityRepository.findAll();
    
    pilgrimActivities.forEach(pa -> {
        UserActivity ua = UserActivity.builder()
            .userId(pa.getUserId())
            .type(pa.getType())
            .occurredAt(pa.getOccurredAt())
            .lat(pa.getLat())
            .lng(pa.getLng())
            .payloadJson(pa.getPayloadJson())
            .build();
        userActivityRepository.save(ua);
    });
    
    log.info("Migrated {} pilgrim activities to user activities", pilgrimActivities.size());
}
```

#### Option B : Suppression directe (SI PAS DE DONNÉES)

Si `PilgrimActivity` n'a jamais été utilisée en production :

1. Supprimer simplement tous les fichiers liés
2. Mettre à jour les services pour utiliser `UserActivity`

### 2.3 Actions à effectuer

#### A. Supprimer les fichiers Java

```bash
# Fichiers à supprimer :
- sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/feature/activities/domain/PilgrimActivity.java
- sahabi-guide-api/src/main/java/com/sahabiGuide/sahabi/feature/activities/infra/PilgrimActivityRepository.java
```

#### B. Mettre à jour ActivitiesService

**Avant :**
```java
@Service
public class ActivitiesService {
    private final UserActivityRepository userActivityRepository;
    private final PilgrimActivityRepository pilgrimActivityRepository; // ❌ À supprimer
    
    public void logPilgrimActivity(...) {
        PilgrimActivity activity = ...; // ❌ À remplacer
        pilgrimActivityRepository.save(activity);
    }
}
```

**Après :**
```java
@Service
public class ActivitiesService {
    private final UserActivityRepository userActivityRepository; // ✅ Unique repository
    
    public void logUserActivity(UUID userId, String type, ...) {
        UserActivity activity = UserActivity.builder()
            .userId(userId)
            .type(type)
            .occurredAt(Instant.now())
            .lat(lat)
            .lng(lng)
            .payloadJson(payload)
            .build();
        userActivityRepository.save(activity);
    }
}
```

#### C. Nettoyer les imports

Supprimer tous les imports de `PilgrimActivity` dans les fichiers suivants :
- `ActivitiesController.java`
- `ActivitiesService.java`
- Tout autre fichier utilisant `PilgrimActivity`

---

## 📊 ÉTAPE 3 : VÉRIFICATION ET TESTS

### 3.1 Tests de migration Liquibase

```bash
# 1. Démarrer la base de données
docker-compose up -d postgres

# 2. Exécuter les migrations
mvn liquibase:update

# 3. Vérifier que toutes les tables sont créées
psql -h localhost -U sahabi -d sahabi_db -c "\dt"
```

**Tables attendues après migration :**
```sql
-- Nouvelles tables
✅ user_ritual_progress
✅ file_objects
✅ stat_snapshots

-- Tables corrigées
✅ messages (avec colonnes renommées)
✅ positions (sans colonne timestamp en double)
```

### 3.2 Tests des entités JPA

```bash
# Tester que toutes les entités se mappent correctement
mvn test -Dtest=*EntityTest
```

### 3.3 Vérification des indexes

```sql
-- Vérifier que tous les indexes sont créés
SELECT 
    tablename, 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE schemaname = 'public' 
ORDER BY tablename, indexname;
```

---

## 🎯 ÉTAPE 4 : DOCUMENTATION ET VALIDATION

### 4.1 Mettre à jour la documentation

#### Fichiers à mettre à jour :

1. **README.md** - Section "Architecture de la base de données"
   - Ajouter les 3 nouvelles tables
   - Supprimer la référence à `pilgrim_activities`

2. **ENDPOINTS.md** - Documenter les nouveaux endpoints si nécessaire
   - GET `/api/v1/rituals/{id}/progress` (utilise user_ritual_progress)
   - GET `/api/v1/files/{id}` (utilise file_objects)
   - GET `/api/v1/dashboard/stats` (utilise stat_snapshots)

3. **Diagramme ERD** - Mettre à jour le schéma de base de données

### 4.2 Checklist de validation

- [ ] Toutes les migrations Liquibase s'exécutent sans erreur
- [ ] Les 3 tables manquantes sont créées
- [ ] La table `messages` a les bonnes colonnes
- [ ] La table `positions` n'a plus de colonne `timestamp` en double
- [ ] L'entité `PilgrimActivity` est supprimée
- [ ] Les services utilisent uniquement `UserActivity`
- [ ] Tous les tests unitaires passent
- [ ] Les indexes de performance sont créés
- [ ] La documentation est à jour

---

## 📈 RÉSULTATS ATTENDUS

### Avant l'audit :
- ❌ 4 entités sans table Liquibase
- ❌ 2 incohérences critiques (messages, positions)
- ❌ 1 entité redondante (PilgrimActivity)
- ⚠️ 21 tables créées / 25 entités = 84% de cohérence

### Après la refonte :
- ✅ Toutes les entités ont leur table Liquibase
- ✅ Aucune incohérence entre JPA et SQL
- ✅ Aucune redondance
- ✅ 24 tables créées / 24 entités = 100% de cohérence
- ✅ Indexes de performance optimisés
- ✅ Types TIMESTAMP normalisés

---

## 🚀 PROCHAINES ÉTAPES

1. **Tester les migrations localement**
   ```bash
   cd sahabi-guide-api
   docker-compose up -d postgres
   mvn clean install
   mvn spring-boot:run
   ```

2. **Vérifier les logs Liquibase**
   - S'assurer qu'il n'y a pas d'erreurs
   - Vérifier que chaque changeset s'exécute

3. **Supprimer PilgrimActivity**
   - Identifier tous les usages
   - Migrer vers UserActivity
   - Supprimer les fichiers

4. **Tests end-to-end**
   - Tester toutes les fonctionnalités impactées
   - Vérifier que les rituels fonctionnent
   - Tester l'upload de fichiers
   - Vérifier le dashboard

5. **Déploiement en production**
   - Backup de la base de données
   - Exécution des migrations
   - Tests de fumée

---

## ⚠️ AVERTISSEMENTS

### Migration 017 (fix-messages-schema)

**ATTENTION :** Cette migration renomme des colonnes de la table `messages`. Si des messages existent en production, ils seront préservés mais les anciens noms de colonnes ne seront plus valides.

**Action avant déploiement :**
- Vérifier qu'aucun code legacy n'utilise les anciens noms (`sender_id`, `recipient_id`, `content`)
- Faire un backup complet de la table `messages`

### Migration 018 (cleanup-positions-timestamp)

**ATTENTION :** Cette migration supprime la colonne `timestamp` de la table `positions`.

**Action avant déploiement :**
- Vérifier que toutes les positions ont une valeur dans la colonne `ts`
- S'assurer qu'aucun code n'utilise `timestamp` (doit utiliser `ts`)

---

## 📝 NOTES FINALES

Cette refonte améliore significativement :
- ✅ **Cohérence** : 100% de correspondance entre JPA et Liquibase
- ✅ **Maintenabilité** : Code plus simple sans redondances
- ✅ **Performance** : Nouveaux indexes optimisés
- ✅ **Fonctionnalités** : Tables manquantes créées
- ✅ **Qualité** : Structure normalisée et documentée

**Temps estimé pour l'implémentation complète :** 4-6 heures

---

*Généré par l'audit complet du 22 Octobre 2025*

