-- Trouver un UUID d'utilisateur existant
SELECT id, passport_no, full_name 
FROM users 
LIMIT 5;

-- Si aucun utilisateur n'existe, en créer un :
-- INSERT INTO users (id, passport_no, full_name, email, created_at, updated_at)
-- VALUES (
--     '123e4567-e89b-12d3-a456-426614174000'::uuid,
--     'TEST123456',
--     'Utilisateur Test Assistant',
--     'test@assistant.com',
--     NOW(),
--     NOW()
-- );

