-- ============================================
-- SEED ADMIN USERS - DASHBOARD AUTH
-- ============================================
-- Ce fichier crée des utilisateurs admin pour tester le système d'authentification
-- Mot de passe pour tous: "password123"
-- Hash BCrypt: $2a$10$rF9xKzJZ.vYGQk7qVz6hWOG0pKxP5xOoH6jE9U6xXsKqWwL7yXYsK

-- 1. SUPER_ADMIN (accès global)
INSERT INTO users_admin (id, email, password_hash, role, agency_id, first_name, last_name, is_active, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'admin@sahabi.com',
    '$2a$10$rF9xKzJZ.vYGQk7qVz6hWOG0pKxP5xOoH6jE9U6xXsKqWwL7yXYsK',
    'SUPER_ADMIN',
    NULL,
    'Super',
    'Admin',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO NOTHING;

-- 2. AGENCY_ADMIN pour l'agence de test 1 (550e8400-e29b-41d4-a716-446655440001)
INSERT INTO users_admin (id, email, password_hash, role, agency_id, first_name, last_name, is_active, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000002'::uuid,
    'agency1@sahabi.com',
    '$2a$10$rF9xKzJZ.vYGQk7qVz6hWOG0pKxP5xOoH6jE9U6xXsKqWwL7yXYsK',
    'AGENCY_ADMIN',
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'Ahmed',
    'Benali',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO NOTHING;

-- 3. AGENCY_ADMIN pour l'agence de test 2 (550e8400-e29b-41d4-a716-446655440002)
INSERT INTO users_admin (id, email, password_hash, role, agency_id, first_name, last_name, is_active, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000003'::uuid,
    'agency2@sahabi.com',
    '$2a$10$rF9xKzJZ.vYGQk7qVz6hWOG0pKxP5xOoH6jE9U6xXsKqWwL7yXYsK',
    'AGENCY_ADMIN',
    '550e8400-e29b-41d4-a716-446655440002'::uuid,
    'Fatima',
    'Zahra',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- RÉSUMÉ DES COMPTES CRÉÉS
-- ============================================
-- Email: admin@sahabi.com
-- Mot de passe: password123
-- Rôle: SUPER_ADMIN (accès à toutes les agences)
--
-- Email: agency1@sahabi.com
-- Mot de passe: password123
-- Rôle: AGENCY_ADMIN (accès uniquement à l'agence 550e8400-e29b-41d4-a716-446655440001)
--
-- Email: agency2@sahabi.com
-- Mot de passe: password123
-- Rôle: AGENCY_ADMIN (accès uniquement à l'agence 550e8400-e29b-41d4-a716-446655440002)
-- ============================================









