# 🔧 Guide de Résolution : Erreur 404 "Étape non trouvée"

## 🎯 Symptôme

```
404 NOT_FOUND "Étape non trouvée"
at AssistantService.lambda$getNextStep$5(AssistantService.java:188)
```

**Cause** : Le backend cherche une étape (par son UUID ou step_code) qui n'existe pas dans la base de données.

---

## 📊 Étape 1 : Diagnostic

### A. Exécuter le script de diagnostic

1. **Ouvrir pgAdmin**
2. **Query Tool** sur la base `sahabi_guide`
3. **Ouvrir** `DIAGNOSTIC_ETAPES_MANQUANTES.sql`
4. **Exécuter** (F5)

### B. Analyser les résultats

Le script va afficher :

#### ✅ Résultats attendus (bon)
```
✓ Total étapes : 25
✓ Aucune étape référencée manquante dans next_step_code
✓ Aucune étape référencée manquante dans navigation_rules_json
✓ Aucun step_code en double
```

#### ❌ Résultats problématiques (à corriger)
```
Étape source    | Étape cible (n'existe pas) | step_order
----------------|----------------------------|------------
HAJJ_BASICS     | HAJJ_MONTH_EXPLANATION     | 6
TAWAF_INTRO     | SUMMARY_SEND               | 18
```

---

## 🔧 Étape 2 : Corrections Possibles

### Problème A : Étapes référencées mais non créées

**Exemple** : `HAJJ_MONTH_EXPLANATION` est référencé dans `navigation_rules_json` de `HAJJ_BASICS`, mais n'existe pas.

**Solutions** :

#### Option 1 : Créer l'étape manquante

```sql
INSERT INTO conversation_steps (
  step_code, step_order, question, question_en, question_ar,
  answer_type, next_step_code, is_critical
) VALUES (
  'HAJJ_MONTH_EXPLANATION', 7,
  'Dhul Hijjah est le dernier mois...',
  'Dhul Hijjah is the last month...',
  'ذو الحجة هو الشهر الأخير...',
  'YES_NO',
  'HAJJ_DATES',
  false
);
```

#### Option 2 : Modifier la référence

```sql
UPDATE conversation_steps
SET navigation_rules_json = '{"OUI LE 12E": "HAJJ_DATES", "NON JE NE SAIS PLUS": "HAJJ_DATES"}'::jsonb
WHERE step_code = 'HAJJ_BASICS';
```

### Problème B : Ordre (step_order) en doublon

**Symptôme** : Deux étapes ont le même `step_order`.

**Solution** :
```sql
-- Renuméroter les étapes
UPDATE conversation_steps SET step_order = 1 WHERE step_code = 'WELCOME';
UPDATE conversation_steps SET step_order = 2 WHERE step_code = 'MOTIVATION_POSITIVE';
-- ... etc
```

### Problème C : Base de données pas synchronisée avec le SQL

**Symptôme** : Le SQL est bon, mais les anciennes données sont encore en base.

**Solution** :
```sql
-- Nettoyer complètement
DELETE FROM conversation_sessions;
DELETE FROM user_conversation_progress;
DELETE FROM conversation_steps;

-- Ré-exécuter SEED_ASSISTANT_ROBUSTE.sql
```

---

## 🚀 Étape 3 : Solutions Rapides

### Solution 1 : Ré-exécuter le SQL Complet

**Si le SQL est correct**, la méthode la plus simple :

```sql
-- 1. Nettoyer
DELETE FROM conversation_sessions;
DELETE FROM user_conversation_progress;
DELETE FROM conversation_steps;

-- 2. Ré-exécuter
-- Copier-coller tout le contenu de SEED_ASSISTANT_ROBUSTE.sql
```

### Solution 2 : Vérifier les Logs Backend

**Activer les logs SQL** dans `application.yml` :

```yaml
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

Puis **restart backend** et regarder quel `stepId` cause le problème :

```
Hibernate: select cs1_0.id, ... from conversation_steps cs1_0 where cs1_0.id=?
binding parameter [1] as [OTHER] - [12345678-1234-1234-1234-123456789012]
```

### Solution 3 : Tester Manuellement une Étape

```sql
-- Vérifier si une étape spécifique existe
SELECT * FROM conversation_steps WHERE step_code = 'WELCOME';

-- Vérifier tous les step_codes
SELECT step_code FROM conversation_steps ORDER BY step_order;
```

---

## 📋 Checklist de Résolution

- [ ] **1.** Exécuter `DIAGNOSTIC_ETAPES_MANQUANTES.sql`
- [ ] **2.** Identifier les étapes manquantes
- [ ] **3.** Nettoyer la base : `DELETE FROM conversation_steps;`
- [ ] **4.** Ré-exécuter `SEED_ASSISTANT_ROBUSTE.sql`
- [ ] **5.** Vérifier : `SELECT COUNT(*) FROM conversation_steps;` → Doit retourner **25**
- [ ] **6.** Hot restart Flutter (`R`)
- [ ] **7.** Tester l'assistant
- [ ] **8.** Vérifier les logs backend : plus d'erreur 404

---

## 🎯 Cas Spécifiques

### Erreur après 2-3 réponses

**Cause probable** : Une étape intermédiaire a un `navigation_rules_json` pointant vers une étape qui n'existe pas.

**Diagnostic** :
```sql
-- Voir quelle étape est atteinte avant l'erreur
SELECT * FROM user_conversation_progress 
WHERE user_id = '550e8400-e29b-41d4-a716-446655440020'
ORDER BY answered_at DESC
LIMIT 5;
```

### Erreur dès la première question

**Cause probable** : L'étape `WELCOME` n'existe pas ou a un problème.

**Diagnostic** :
```sql
SELECT * FROM conversation_steps WHERE step_code = 'WELCOME';
```

Si vide → le SQL n'a pas été exécuté correctement.

---

## 💡 Prévention Future

### 1. Valider le SQL avant exécution

Créer un script de validation :

```sql
-- validation.sql
DO $$
DECLARE
    missing_steps TEXT[];
BEGIN
    -- Vérifier next_step_code
    SELECT array_agg(DISTINCT cs1.next_step_code)
    INTO missing_steps
    FROM conversation_steps cs1
    LEFT JOIN conversation_steps cs2 ON cs1.next_step_code = cs2.step_code
    WHERE cs1.next_step_code IS NOT NULL AND cs2.step_code IS NULL;
    
    IF array_length(missing_steps, 1) > 0 THEN
        RAISE EXCEPTION 'Étapes manquantes dans next_step_code: %', missing_steps;
    END IF;
    
    RAISE NOTICE 'Validation réussie !';
END $$;
```

### 2. Contrainte d'intégrité (optionnel)

```sql
-- Ajouter une contrainte pour vérifier que next_step_code existe
-- Note : Cela empêche les références invalides, mais peut compliquer les insertions
ALTER TABLE conversation_steps
ADD CONSTRAINT fk_next_step
FOREIGN KEY (next_step_code) 
REFERENCES conversation_steps(step_code)
DEFERRABLE INITIALLY DEFERRED;
```

---

## 🎉 Résultat Attendu

Après correction :

```
✅ 25 étapes en base
✅ Aucune référence manquante
✅ Bot fonctionne sans erreur 404
✅ Navigation fluide du début à la fin
```

---

**Commencez par exécuter `DIAGNOSTIC_ETAPES_MANQUANTES.sql` et partagez les résultats !** 🚀

---

*Guide créé le 23 Octobre 2025*  
*Solution pour erreur 404 "Étape non trouvée"*

