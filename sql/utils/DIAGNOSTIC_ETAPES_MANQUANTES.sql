-- ============================================
-- DIAGNOSTIC : ÉTAPES MANQUANTES
-- ============================================
-- Script pour identifier les problèmes de navigation
-- ============================================

-- 1. Vérifier le nombre total d'étapes
SELECT COUNT(*) as "Total étapes" FROM conversation_steps;

-- 2. Lister toutes les étapes avec leur ordre
SELECT step_code, step_order, next_step_code, is_critical
FROM conversation_steps
ORDER BY step_order;

-- 3. Vérifier les étapes référencées dans next_step_code qui n'existent pas
SELECT 
    cs1.step_code as "Étape source",
    cs1.next_step_code as "Étape cible (n'existe pas)",
    cs1.step_order
FROM conversation_steps cs1
LEFT JOIN conversation_steps cs2 ON cs1.next_step_code = cs2.step_code
WHERE cs1.next_step_code IS NOT NULL 
  AND cs2.step_code IS NULL
ORDER BY cs1.step_order;

-- 4. Vérifier les étapes référencées dans navigation_rules_json qui n'existent pas
WITH navigation_targets AS (
    SELECT 
        step_code,
        step_order,
        jsonb_object_keys(navigation_rules_json) as reponse,
        navigation_rules_json->>jsonb_object_keys(navigation_rules_json) as target_step
    FROM conversation_steps
    WHERE navigation_rules_json IS NOT NULL
)
SELECT 
    nt.step_code as "Étape source",
    nt.reponse as "Réponse",
    nt.target_step as "Étape cible (n'existe pas)"
FROM navigation_targets nt
LEFT JOIN conversation_steps cs ON nt.target_step = cs.step_code
WHERE cs.step_code IS NULL
ORDER BY nt.step_order;

-- 5. Vérifier les step_codes en double (ne devrait pas exister)
SELECT step_code, COUNT(*) as "Nombre"
FROM conversation_steps
GROUP BY step_code
HAVING COUNT(*) > 1;

-- 6. Vérifier les étapes orphelines (non référencées)
WITH all_targets AS (
    -- next_step_code
    SELECT DISTINCT next_step_code as target_code
    FROM conversation_steps
    WHERE next_step_code IS NOT NULL
    
    UNION
    
    -- navigation_rules_json
    SELECT DISTINCT navigation_rules_json->>jsonb_object_keys(navigation_rules_json) as target_code
    FROM conversation_steps
    WHERE navigation_rules_json IS NOT NULL
)
SELECT cs.step_code, cs.step_order
FROM conversation_steps cs
LEFT JOIN all_targets at ON cs.step_code = at.target_code
WHERE at.target_code IS NULL
  AND cs.step_order > 1  -- Exclure la première étape
ORDER BY cs.step_order;

-- 7. Afficher la structure complète de navigation
SELECT 
    cs.step_code,
    cs.step_order,
    cs.answer_type,
    cs.next_step_code,
    cs.navigation_rules_json
FROM conversation_steps cs
ORDER BY cs.step_order;

-- ============================================
-- FIN DU DIAGNOSTIC
-- ============================================

