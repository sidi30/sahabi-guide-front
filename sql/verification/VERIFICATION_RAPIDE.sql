-- ============================================
-- VÉRIFICATION RAPIDE DES ÉTAPES
-- ============================================

-- 1. Nombre total
SELECT COUNT(*) as "Total" FROM conversation_steps;

-- 2. Liste des step_codes
SELECT step_order, step_code, next_step_code 
FROM conversation_steps 
ORDER BY step_order;

-- 3. Vérifier les références manquantes dans next_step_code
SELECT 
    cs1.step_code as "Source",
    cs1.next_step_code as "Cible Manquante"
FROM conversation_steps cs1
LEFT JOIN conversation_steps cs2 ON cs1.next_step_code = cs2.step_code
WHERE cs1.next_step_code IS NOT NULL 
  AND cs2.step_code IS NULL;

-- 4. Vérifier les références manquantes dans navigation_rules_json
WITH targets AS (
    SELECT 
        step_code,
        jsonb_object_keys(navigation_rules_json) as key,
        navigation_rules_json->>jsonb_object_keys(navigation_rules_json) as target
    FROM conversation_steps
    WHERE navigation_rules_json IS NOT NULL
)
SELECT 
    t.step_code as "Source",
    t.key as "Réponse",
    t.target as "Cible Manquante"
FROM targets t
LEFT JOIN conversation_steps cs ON t.target = cs.step_code
WHERE cs.step_code IS NULL;

-- 5. Si aucune erreur ci-dessus → le problème vient du Flutter
--    Vérifier quelle étape l'utilisateur a atteint :
SELECT 
    ucp.step_code,
    ucp.answer,
    ucp.answered_at
FROM user_conversation_progress ucp
WHERE user_id = '550e8400-e29b-41d4-a716-446655440020'
ORDER BY answered_at DESC
LIMIT 10;

