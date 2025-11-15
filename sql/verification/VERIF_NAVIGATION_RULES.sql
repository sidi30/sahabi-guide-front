-- ============================================
-- VÉRIFICATION DES NAVIGATION RULES
-- ============================================

-- 1. Extraire toutes les étapes cibles des navigation_rules_json
WITH navigation_targets AS (
    SELECT 
        cs.step_code as source_step,
        cs.step_order,
        jsonb_object_keys(cs.navigation_rules_json) as reponse_key,
        cs.navigation_rules_json->>jsonb_object_keys(cs.navigation_rules_json) as target_step
    FROM conversation_steps cs
    WHERE cs.navigation_rules_json IS NOT NULL
)
SELECT 
    nt.source_step as "Étape Source",
    nt.step_order as "Ordre",
    nt.reponse_key as "Clé de Réponse",
    nt.target_step as "Étape Cible",
    CASE 
        WHEN cs.step_code IS NULL THEN '❌ MANQUANTE'
        ELSE '✅ OK'
    END as "Status"
FROM navigation_targets nt
LEFT JOIN conversation_steps cs ON nt.target_step = cs.step_code
ORDER BY nt.step_order, nt.reponse_key;

-- 2. Lister SEULEMENT les étapes cibles manquantes
WITH navigation_targets AS (
    SELECT 
        cs.step_code as source_step,
        cs.step_order,
        jsonb_object_keys(cs.navigation_rules_json) as reponse_key,
        cs.navigation_rules_json->>jsonb_object_keys(cs.navigation_rules_json) as target_step
    FROM conversation_steps cs
    WHERE cs.navigation_rules_json IS NOT NULL
)
SELECT 
    nt.source_step as "Étape Source",
    nt.reponse_key as "Clé",
    nt.target_step as "Cible MANQUANTE ❌"
FROM navigation_targets nt
LEFT JOIN conversation_steps cs ON nt.target_step = cs.step_code
WHERE cs.step_code IS NULL;

-- 3. Afficher les navigation_rules_json de toutes les étapes
SELECT 
    step_code,
    step_order,
    navigation_rules_json,
    next_step_code
FROM conversation_steps
WHERE navigation_rules_json IS NOT NULL
ORDER BY step_order;

