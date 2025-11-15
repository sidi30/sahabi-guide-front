# 🔍 AUDIT COMPLÉMENTAIRE : TABLES DUAS ET RITUALS

## 📅 Date : 22 Octobre 2025

---

## 🚨 PROBLÈMES CRITIQUES IDENTIFIÉS

### Problème #1 : Relation JPA manquante dans `Dua` ❌

**Gravité :** 🔴 CRITIQUE

**Description :**
L'entité `Dua` a une colonne `ritual_id` (UUID) mais **pas de relation JPA** `@ManyToOne` vers `Ritual`. C'est une incohérence majeure entre le modèle objet et la base de données.

**Code actuel (INCORRECT) :**
```java
@Column(name = "ritual_id", nullable = false)
private UUID ritualId;
```

**Code corrigé (RECOMMANDÉ) :**
```java
@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(name = "ritual_id", nullable = false)
private Ritual ritual;
```

**Avantages :**
- Navigation objet : `dua.getRitual().getName()`
- Lazy/Eager loading géré par Hibernate
- Cascade automatique si configuré
- Requêtes optimisées avec JOIN FETCH

---

### Problème #2 : Migration 003 duplique la migration 001 ❌

**Gravité :** 🔴 CRITIQUE (bloque la prod)

**Description :**
La migration `003-extend-rituals-jsonb.xml` tente d'ajouter des colonnes qui existent **déjà** dans `001-create-core-schema.xml`. Cela fonctionne en dev (drop tables) mais échouera en prod.

**Colonnes dupliquées :**
- `steps_json` (créée en 001, re-créée en 003)
- `tips_json` (créée en 001, re-créée en 003)
- `audio_urls_json` (créée en 001, re-créée en 003)
- `video_url` (créée en 001, re-créée en 003)
- `content_version` (créée en 001, re-créée en 003)

**Impact :**
```sql
-- En production, lors de l'exécution de la migration 003 :
ERROR: column "steps_json" of relation "rituals" already exists
```

**Solutions possibles :**

#### Option A : Supprimer la migration 003 (RECOMMANDÉ)
Si les colonnes sont déjà dans 001, la migration 003 est **inutile**.

```xml
<!-- À SUPPRIMER : 003-extend-rituals-jsonb.xml -->
```

#### Option B : Ajouter preConditions pour éviter l'erreur
```xml
<changeSet id="003-extend-rituals-jsonb" author="assistant">
    <preConditions onFail="MARK_RAN">
        <not>
            <columnExists tableName="rituals" columnName="steps_json"/>
        </not>
    </preConditions>
    <!-- ... reste du code ... -->
</changeSet>
```

**Recommandation :** **Option A** - Supprimer complètement la migration 003 car les colonnes sont déjà créées en 001.

---

### Problème #3 : Indexes inefficaces sur JSONB ⚠️

**Gravité :** 🟡 MOYEN (performance)

**Description :**
Les indexes B-tree créés sur des colonnes JSONB entières sont **inefficaces**. PostgreSQL ne peut pas les utiliser pour optimiser les requêtes JSON.

**Code actuel (INEFFICACE) :**
```xml
<createIndex tableName="rituals" indexName="idx_rituals_steps_json">
    <column name="steps_json"/>
</createIndex>
<createIndex tableName="rituals" indexName="idx_rituals_tips_json">
    <column name="tips_json"/>
</createIndex>
```

**Problèmes :**
- Un index B-tree sur une colonne JSONB complète n'améliore pas les performances
- Les requêtes `WHERE steps_json->>'key' = 'value'` n'utilisent pas l'index
- Gaspillage d'espace disque

**Solutions :**

#### Si on recherche dans le contenu JSON → Index GIN
```sql
-- Index GIN pour recherche dans tout le JSON
CREATE INDEX idx_rituals_steps_json_gin 
ON rituals USING GIN (steps_json);

-- Permet des requêtes comme :
-- WHERE steps_json @> '{"steps": ["Commencer à la Pierre Noire"]}'
```

#### Si on recherche des clés spécifiques → Index sur expression
```sql
-- Index sur une clé JSON spécifique
CREATE INDEX idx_rituals_step_count 
ON rituals ((steps_json->'steps'->0));

-- Permet des requêtes comme :
-- WHERE steps_json->'steps'->0 = '"Commencer à la Pierre Noire"'
```

#### Si on ne fait PAS de recherche → Supprimer les indexes
```sql
-- Si les colonnes JSONB sont juste pour le stockage
-- (pas de WHERE/ORDER BY dessus), supprimer les indexes
DROP INDEX idx_rituals_steps_json;
DROP INDEX idx_rituals_tips_json;
```

**Recommandation :** **Supprimer** ces indexes s'ils ne sont pas utilisés pour des requêtes de recherche.

---

### Problème #4 : Relation bidirectionnelle manquante ⚠️

**Gravité :** 🟡 MOYEN (confort de développement)

**Description :**
L'entité `Ritual` n'a pas de collection `@OneToMany` vers `Dua`, rendant impossible la navigation `ritual.getDuas()`.

**Code actuel :**
```java
public class Ritual extends AbstractAuditableEntity {
    // ... colonnes ...
    // ❌ Pas de relation vers les duas
}
```

**Code recommandé :**
```java
public class Ritual extends AbstractAuditableEntity {
    // ... colonnes existantes ...
    
    @OneToMany(mappedBy = "ritual", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("orderIndex ASC")
    private List<Dua> duas = new ArrayList<>();
}
```

**Avantages :**
- Navigation intuitive : `ritual.getDuas()`
- Tri automatique par `order_index`
- Cascade : suppression d'un rituel supprime ses duas
- Orphan removal : duas sans rituel sont supprimées

---

## 📋 PLAN DE CORRECTION

### Étape 1 : Supprimer la migration 003 (URGENT)

**Raison :** Elle duplique les colonnes de la migration 001

**Action :**
```bash
# Supprimer le fichier
rm sahabi-guide-api/src/main/resources/db/changelog/003-extend-rituals-jsonb.xml

# Retirer la référence dans db.changelog-master.xml
```

**Mise à jour de `db.changelog-master.xml` :**
```xml
<!-- AVANT -->
<include file="002-seed-test-data.xml" relativeToChangelogFile="true" context="dev"/>
<include file="003-extend-rituals-jsonb.xml" relativeToChangelogFile="true"/>
<include file="005-create-connectivity-tables.xml" relativeToChangelogFile="true"/>

<!-- APRÈS -->
<include file="002-seed-test-data.xml" relativeToChangelogFile="true" context="dev"/>
<!-- 003 SUPPRIMÉE : colonnes déjà dans 001 -->
<include file="005-create-connectivity-tables.xml" relativeToChangelogFile="true"/>
```

---

### Étape 2 : Corriger l'entité `Dua` (CRITIQUE)

**Fichier :** `Dua.java`

**Changement :**
```java
// SUPPRIMER cette ligne :
@Column(name = "ritual_id", nullable = false)
private UUID ritualId;

// AJOUTER à la place :
@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(name = "ritual_id", nullable = false)
private Ritual ritual;
```

---

### Étape 3 : Ajouter la relation bidirectionnelle dans `Ritual` (OPTIONNEL)

**Fichier :** `Ritual.java`

**Ajout :**
```java
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.CascadeType;
import java.util.ArrayList;
import java.util.List;

@OneToMany(mappedBy = "ritual", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
@OrderBy("orderIndex ASC")
private List<Dua> duas = new ArrayList<>();
```

---

### Étape 4 : Supprimer les indexes JSONB inefficaces (OPTIONNEL)

**Nouvelle migration :** `021-cleanup-rituals-indexes.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                   http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.24.xsd">

    <changeSet id="021-cleanup-rituals-indexes" author="sahabi-guide">
        <comment>Suppression des indexes B-tree inefficaces sur colonnes JSONB</comment>

        <sql>
            DROP INDEX IF EXISTS idx_rituals_steps_json;
            DROP INDEX IF EXISTS idx_rituals_tips_json;
        </sql>
    </changeSet>

</databaseChangeLog>
```

---

### Étape 5 : Mettre à jour les services utilisant `Dua`

**Fichiers à vérifier :**
- `DuasService.java`
- `DuasController.java`
- `RitualsService.java`

**Exemple de changement :**
```java
// AVANT
Dua dua = duaRepository.findById(id);
UUID ritualId = dua.getRitualId();
Ritual ritual = ritualRepository.findById(ritualId); // ❌ Requête supplémentaire

// APRÈS
Dua dua = duaRepository.findById(id);
Ritual ritual = dua.getRitual(); // ✅ Chargé automatiquement (lazy)
String ritualName = ritual.getName();
```

---

## 🧪 TESTS À EFFECTUER

### Test 1 : Vérifier que la migration 003 n'est plus exécutée

```bash
cd sahabi-guide-api
docker-compose up -d postgres
mvn liquibase:update

# Vérifier les logs - la migration 003 ne doit PAS apparaître
```

### Test 2 : Vérifier la relation JPA

```java
@Test
void testDuaRitualRelation() {
    Dua dua = duaRepository.findById(UUID.fromString("550e8400-e29b-41d4-a716-446655440070"))
        .orElseThrow();
    
    // ✅ Doit fonctionner maintenant
    Ritual ritual = dua.getRitual();
    assertNotNull(ritual);
    assertEquals("Tawaf", ritual.getName());
}
```

### Test 3 : Vérifier la relation bidirectionnelle (si implémentée)

```java
@Test
void testRitualDuasRelation() {
    Ritual ritual = ritualRepository.findById(UUID.fromString("550e8400-e29b-41d4-a716-446655440060"))
        .orElseThrow();
    
    // ✅ Doit fonctionner maintenant
    List<Dua> duas = ritual.getDuas();
    assertFalse(duas.isEmpty());
    assertEquals(2, duas.size()); // Tawaf a 2 duas dans les seeds
}
```

---

## 📊 IMPACT ESTIMÉ

### Problème #1 (Relation JPA manquante)
- **Gravité :** 🔴 CRITIQUE
- **Effort de correction :** 30 minutes
- **Impact métier :** Améliore la maintenabilité et les performances

### Problème #2 (Migration 003 dupliquée)
- **Gravité :** 🔴 CRITIQUE (bloque la prod)
- **Effort de correction :** 5 minutes
- **Impact métier :** Déploiement en production impossible sans cette correction

### Problème #3 (Indexes inefficaces)
- **Gravité :** 🟡 MOYEN
- **Effort de correction :** 10 minutes
- **Impact métier :** Libère de l'espace disque (~1-2 MB par index)

### Problème #4 (Relation bidirectionnelle)
- **Gravité :** 🟢 BASSE (confort)
- **Effort de correction :** 15 minutes
- **Impact métier :** Améliore l'ergonomie du code

---

## ✅ CHECKLIST DE VALIDATION

- [ ] Migration 003 supprimée du projet
- [ ] Migration 003 retirée de `db.changelog-master.xml`
- [ ] Entité `Dua` mise à jour avec `@ManyToOne`
- [ ] Entité `Ritual` mise à jour avec `@OneToMany` (optionnel)
- [ ] Services mis à jour pour utiliser la relation JPA
- [ ] Tests unitaires passent
- [ ] Migration testée en local
- [ ] Migration testée sur une copie de prod

---

## 📝 CONCLUSION

Ces problèmes sont **critiques** et doivent être corrigés **avant le déploiement en production** :

1. **Migration 003** → Suppression immédiate (bloque la prod)
2. **Relation JPA dans Dua** → Correction urgente (améliore la qualité)
3. **Indexes JSONB** → Correction recommandée (optimise les ressources)
4. **Relation bidirectionnelle** → Optionnel (améliore le confort)

**Temps total estimé :** 1 heure

---

*Audit complémentaire réalisé le 22 Octobre 2025*

