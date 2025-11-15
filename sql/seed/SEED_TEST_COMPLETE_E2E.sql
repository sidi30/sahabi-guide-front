-- ======================================
-- SEED COMPLET POUR TESTS END-TO-END
-- Projet: Sahabi Guide
-- Date: 26 Octobre 2025
-- ======================================

-- Note: Ce seed crée un environnement de test complet avec:
-- - 3 agences (France, Maroc, Tunisie)
-- - 6 utilisateurs (2 par agence: 1 admin + 1 guide)
-- - 6 groupes (2 par agence)
-- - 20 pèlerins (répartis dans les groupes actifs)
-- - Positions récentes
-- - POIs
-- - Alertes

-- ======================================
-- 1. CRÉATION DES AGENCES
-- ======================================

INSERT INTO agencies (id, name, country_code, email, phone, website, 
                      logo_url, description, identification_number,
                      contact_person_name, contact_person_phone,
                      address_street, address_city, address_postal_code, address_country,
                      subscription_type, status, contract_start_date, contract_end_date,
                      created_at, updated_at)
VALUES
-- Agence 1 : Al-Barakah (France)
('11111111-1111-1111-1111-111111111111', 'Al-Barakah Travel', 'FR', 
 'contact@albarakah.fr', '+33 1 23 45 67 89', 'https://www.albarakah.fr',
 'https://via.placeholder.com/150/3B82F6/FFFFFF?text=Al-Barakah', 
 'Agence spécialisée dans les pèlerinages depuis 1995. Accompagnement spirituel complet et service premium.',
 'SIRET 123 456 789 00012',
 'Mohammed Benali', '+33 6 12 34 56 78',
 '123 Rue de la République', 'Paris', '75011', 'France',
 'PREMIUM', 'ACTIVE', '2024-01-01', '2025-12-31',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Agence 2 : Omra Plus (Maroc)
('22222222-2222-2222-2222-222222222222', 'Omra Plus', 'MA',
 'info@omraplus.ma', '+212 5 22 12 34 56', 'https://www.omraplus.ma',
 'https://via.placeholder.com/150/10B981/FFFFFF?text=Omra+Plus', 
 'Votre partenaire de confiance pour le Hajj et la Omra. Plus de 20 ans d''expérience.',
 'RC 987654',
 'Amina Alaoui', '+212 6 78 90 12 34',
 '45 Avenue Hassan II', 'Casablanca', '20000', 'Maroc',
 'STANDARD', 'ACTIVE', '2024-06-01', '2025-05-31',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Agence 3 : Mambrouk (Tunisie)
('33333333-3333-3333-3333-333333333333', 'Mambrouk Voyages', 'TN',
 'admin@mambrouk.tn', '+216 71 12 34 56', 'https://www.mambrouk.tn',
 'https://via.placeholder.com/150/8B5CF6/FFFFFF?text=Mambrouk', 
 'Organisation de pèlerinages avec accompagnement spirituel et médical personnalisé.',
 'MF 12345678',
 'Ibrahim Trabelsi', '+216 98 76 54 32',
 '78 Avenue Bourguiba', 'Tunis', '1000', 'Tunisie',
 'ENTERPRISE', 'ACTIVE', '2023-01-01', '2026-12-31',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- 2. CRÉATION DES UTILISATEURS (Admins + Guides)
-- ======================================

-- Password hash pour tous: "password123" encodé avec BCrypt
-- $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

INSERT INTO users (id, agency_id, email, phone, password_hash, role, enabled,
                   first_name, last_name, full_name,
                   created_at, updated_at)
VALUES
-- Al-Barakah (France)
('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'admin@albarakah.fr', '+33601234567', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'ADMIN', true,
 'Mohammed', 'Benali', 'Mohammed Benali',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('g1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'guide1@albarakah.fr', '+33612345678', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'GUIDE', true,
 'Ahmed', 'Idrissi', 'Ahmed Idrissi',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Omra Plus (Maroc)
('a2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
 'admin@omraplus.ma', '+212678901234', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'ADMIN', true,
 'Amina', 'Alaoui', 'Amina Alaoui',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('g2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
 'guide1@omraplus.ma', '+212687654321', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'GUIDE', true,
 'Youssef', 'Benjelloun', 'Youssef Benjelloun',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Mambrouk (Tunisie)
('a3333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333',
 'admin@mambrouk.tn', '+216987654321', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'ADMIN', true,
 'Ibrahim', 'Trabelsi', 'Ibrahim Trabelsi',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('g3333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333',
 'guide1@mambrouk.tn', '+216912345678', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'GUIDE', true,
 'Salma', 'Karoui', 'Salma Karoui',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- 3. CRÉATION DES GROUPES
-- ======================================

INSERT INTO groups (id, agency_id, guide_id, name, color_code, description, max_capacity, 
                    status, start_date, end_date, rally_point, itinerary,
                    created_at, updated_at)
VALUES
-- Al-Barakah (France)
('11111111-1111-aaaa-aaaa-111111111111', '11111111-1111-1111-1111-111111111111',
 'g1111111-1111-1111-1111-111111111111',
 'Groupe A - Hajj 2025', '#3B82F6',
 'Groupe francophone avec accompagnement spirituel complet. Programme incluant tous les rites du Hajj avec guide expérimenté.',
 30,
 'ACTIF', '2025-06-15', '2025-07-10',
 'Aéroport Charles de Gaulle Terminal 2E',
 'Départ Paris → Jeddah → La Mecque (5 jours) → Arafat → Muzdalifah → Mina → Médine (3 jours) → Retour Paris',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('11111111-1111-bbbb-bbbb-111111111111', '11111111-1111-1111-1111-111111111111',
 'g1111111-1111-1111-1111-111111111111',
 'Groupe B - Omra Ramadan', '#10B981',
 'Groupe spécial Ramadan. Vivez votre Omra pendant le mois béni avec prières de Tarawih à la mosquée.',
 25,
 'EN_PREPARATION', '2025-03-15', '2025-03-30',
 'Aéroport Charles de Gaulle Terminal 2F',
 'Programme Omra pendant le Ramadan avec Tarawih à Masjid al-Haram et visite des lieux historiques',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Omra Plus (Maroc)
('22222222-2222-aaaa-aaaa-222222222222', '22222222-2222-2222-2222-222222222222',
 'g2222222-2222-2222-2222-222222222222',
 'Groupe Premium 1', '#F59E0B',
 'Groupe premium avec hébergement 5 étoiles face à la Kaaba. Service VIP et accompagnement personnalisé.',
 20,
 'ACTIF', '2025-01-10', '2025-01-25',
 'Aéroport Mohammed V Casablanca',
 'Omra de luxe avec visites guidées des sites historiques islamiques et hébergement premium',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('22222222-2222-bbbb-bbbb-222222222222', '22222222-2222-2222-2222-222222222222',
 'g2222222-2222-2222-2222-222222222222',
 'Groupe Économique', '#EF4444',
 'Groupe économique pour petits budgets. Même qualité de service à prix accessible.',
 40,
 'ACTIF', '2025-02-01', '2025-02-15',
 'Aéroport Mohammed V Casablanca',
 'Omra économique avec hébergement confortable et transport inclus',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Mambrouk (Tunisie)
('33333333-3333-aaaa-aaaa-333333333333', '33333333-3333-3333-3333-333333333333',
 'g3333333-3333-3333-3333-333333333333',
 'Groupe Familial', '#8B5CF6',
 'Groupe adapté aux familles avec enfants. Activités pour tous les âges et accompagnement familial.',
 35,
 'ACTIF', '2025-07-01', '2025-07-20',
 'Aéroport Tunis-Carthage',
 'Hajj familial avec activités pour enfants et adolescents, accompagnement adapté aux familles',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('33333333-3333-bbbb-bbbb-333333333333', '33333333-3333-3333-3333-333333333333',
 'g3333333-3333-3333-3333-333333333333',
 'Groupe Seniors', '#EC4899',
 'Groupe adapté aux personnes âgées avec assistance médicale et rythme adapté.',
 20,
 'EN_PREPARATION', '2025-04-15', '2025-05-05',
 'Aéroport Tunis-Carthage',
 'Omra adaptée aux seniors avec rythme doux, assistance médicale et fauteuils roulants disponibles',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- 4. CRÉATION DES PÈLERINS
-- ======================================

INSERT INTO users (id, agency_id, group_id, email, phone, password_hash, role, enabled,
                   first_name, last_name, full_name,
                   date_of_birth, address, city, country, nationality,
                   passport_number, passport_expiry_date, visa_number,
                   photo_url, pilgrim_status, hajj_start_date,
                   created_at, updated_at)
VALUES
-- Groupe A - Hajj 2025 (Al-Barakah) - 5 pèlerins
('p1111111-0001-0001-0001-111111111111', '11111111-1111-1111-1111-111111111111',
 '11111111-1111-aaaa-aaaa-111111111111',
 'fatima.benali@example.com', '+33 6 11 22 33 44', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Fatima', 'Benali', 'Fatima Benali',
 '1985-03-15', '12 Rue Voltaire', 'Lyon', 'France', 'Française',
 'FR123456', '2027-03-15', 'V987654',
 'https://i.pravatar.cc/150?img=1', 'ACTIVE', '2025-06-15',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p1111111-0001-0002-0002-111111111111', '11111111-1111-1111-1111-111111111111',
 '11111111-1111-aaaa-aaaa-111111111111',
 'karim.hassan@example.com', '+33 6 22 33 44 55', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Karim', 'Hassan', 'Karim Hassan',
 '1978-07-22', '45 Avenue de la Liberté', 'Marseille', 'France', 'Français',
 'FR234567', '2026-11-20', 'V876543',
 'https://i.pravatar.cc/150?img=2', 'ACTIVE', '2025-06-15',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p1111111-0001-0003-0003-111111111111', '11111111-1111-1111-1111-111111111111',
 '11111111-1111-aaaa-aaaa-111111111111',
 'aicha.mohamed@example.com', '+33 6 33 44 55 66', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Aicha', 'Mohamed', 'Aicha Mohamed',
 '1990-11-05', '78 Boulevard Victor Hugo', 'Toulouse', 'France', 'Française',
 'FR345678', '2028-01-10', 'V765432',
 'https://i.pravatar.cc/150?img=3', 'ACTIVE', '2025-06-15',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p1111111-0001-0004-0004-111111111111', '11111111-1111-1111-1111-111111111111',
 '11111111-1111-aaaa-aaaa-111111111111',
 'omar.said@example.com', '+33 6 44 55 66 77', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Omar', 'Said', 'Omar Said',
 '1982-05-30', '23 Rue Jean Jaurès', 'Nice', 'France', 'Français',
 'FR456789', '2027-09-25', 'V654321',
 'https://i.pravatar.cc/150?img=4', 'ACTIVE', '2025-06-15',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p1111111-0001-0005-0005-111111111111', '11111111-1111-1111-1111-111111111111',
 '11111111-1111-aaaa-aaaa-111111111111',
 'nadia.khaled@example.com', '+33 6 55 66 77 88', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Nadia', 'Khaled', 'Nadia Khaled',
 '1995-02-18', '67 Avenue Foch', 'Strasbourg', 'France', 'Française',
 'FR567890', '2026-06-30', 'V543210',
 'https://i.pravatar.cc/150?img=5', 'ACTIVE', '2025-06-15',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Groupe Premium 1 (Omra Plus) - 5 pèlerins
('p2222222-0001-0001-0001-222222222222', '22222222-2222-2222-2222-222222222222',
 '22222222-2222-aaaa-aaaa-222222222222',
 'safaa.berrada@example.com', '+212 6 11 22 33 44', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Safaa', 'Berrada', 'Safaa Berrada',
 '1988-09-10', '22 Rue Mohamed V', 'Rabat', 'Maroc', 'Marocaine',
 'MA111222', '2027-09-10', 'VM111222',
 'https://i.pravatar.cc/150?img=6', 'ACTIVE', '2025-01-10',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p2222222-0001-0002-0002-222222222222', '22222222-2222-2222-2222-222222222222',
 '22222222-2222-aaaa-aaaa-222222222222',
 'hamza.idrissi@example.com', '+212 6 22 33 44 55', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Hamza', 'Idrissi', 'Hamza Idrissi',
 '1980-04-25', '88 Boulevard Zerktouni', 'Casablanca', 'Maroc', 'Marocain',
 'MA222333', '2026-12-15', 'VM222333',
 'https://i.pravatar.cc/150?img=7', 'ACTIVE', '2025-01-10',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p2222222-0001-0003-0003-222222222222', '22222222-2222-2222-2222-222222222222',
 '22222222-2222-aaaa-aaaa-222222222222',
 'leila.tazi@example.com', '+212 6 33 44 55 66', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Leila', 'Tazi', 'Leila Tazi',
 '1992-12-03', '15 Avenue Hassan II', 'Marrakech', 'Maroc', 'Marocaine',
 'MA333444', '2028-03-20', 'VM333444',
 'https://i.pravatar.cc/150?img=8', 'ACTIVE', '2025-01-10',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p2222222-0001-0004-0004-222222222222', '22222222-2222-2222-2222-222222222222',
 '22222222-2222-aaaa-aaaa-222222222222',
 'youssef.alami@example.com', '+212 6 44 55 66 77', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Youssef', 'Alami', 'Youssef Alami',
 '1975-06-18', '44 Rue de Fès', 'Tanger', 'Maroc', 'Marocain',
 'MA444555', '2027-08-30', 'VM444555',
 'https://i.pravatar.cc/150?img=9', 'ACTIVE', '2025-01-10',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p2222222-0001-0005-0005-222222222222', '22222222-2222-2222-2222-222222222222',
 '22222222-2222-aaaa-aaaa-222222222222',
 'sara.fassi@example.com', '+212 6 55 66 77 88', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Sara', 'Fassi', 'Sara Fassi',
 '1998-01-28', '76 Rue Ibn Rochd', 'Agadir', 'Maroc', 'Marocaine',
 'MA555666', '2026-10-05', 'VM555666',
 'https://i.pravatar.cc/150?img=10', 'ACTIVE', '2025-01-10',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Groupe Familial (Mambrouk) - 5 pèlerins
('p3333333-0001-0001-0001-333333333333', '33333333-3333-3333-3333-333333333333',
 '33333333-3333-aaaa-aaaa-333333333333',
 'mariem.ben.salem@example.com', '+216 98 11 22 33', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Mariem', 'Ben Salem', 'Mariem Ben Salem',
 '1987-08-14', '33 Avenue Habib Bourguiba', 'Tunis', 'Tunisie', 'Tunisienne',
 'TN111222', '2027-08-14', 'VT111222',
 'https://i.pravatar.cc/150?img=11', 'ACTIVE', '2025-07-01',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p3333333-0001-0002-0002-333333333333', '33333333-3333-3333-3333-333333333333',
 '33333333-3333-aaaa-aaaa-333333333333',
 'fares.gharbi@example.com', '+216 98 22 33 44', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Fares', 'Gharbi', 'Fares Gharbi',
 '1983-11-22', '67 Rue de la République', 'Sfax', 'Tunisie', 'Tunisien',
 'TN222333', '2026-11-22', 'VT222333',
 'https://i.pravatar.cc/150?img=12', 'ACTIVE', '2025-07-01',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p3333333-0001-0003-0003-333333333333', '33333333-3333-3333-3333-333333333333',
 '33333333-3333-aaaa-aaaa-333333333333',
 'sana.chebbi@example.com', '+216 98 33 44 55', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Sana', 'Chebbi', 'Sana Chebbi',
 '1993-05-07', '91 Avenue Mohamed V', 'Sousse', 'Tunisie', 'Tunisienne',
 'TN333444', '2028-05-07', 'VT333444',
 'https://i.pravatar.cc/150?img=13', 'ACTIVE', '2025-07-01',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p3333333-0001-0004-0004-333333333333', '33333333-3333-3333-3333-333333333333',
 '33333333-3333-aaaa-aaaa-333333333333',
 'mehdi.bouzid@example.com', '+216 98 44 55 66', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Mehdi', 'Bouzid', 'Mehdi Bouzid',
 '1979-03-31', '12 Rue Mongi Slim', 'Nabeul', 'Tunisie', 'Tunisien',
 'TN444555', '2027-03-31', 'VT444555',
 'https://i.pravatar.cc/150?img=14', 'ACTIVE', '2025-07-01',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('p3333333-0001-0005-0005-333333333333', '33333333-3333-3333-3333-333333333333',
 '33333333-3333-aaaa-aaaa-333333333333',
 'amira.ferchichi@example.com', '+216 98 55 66 77', 
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
 'PILGRIM', true,
 'Amira', 'Ferchichi', 'Amira Ferchichi',
 '1996-09-19', '55 Avenue de Paris', 'Bizerte', 'Tunisie', 'Tunisienne',
 'TN555666', '2026-09-19', 'VT555666',
 'https://i.pravatar.cc/150?img=15', 'ACTIVE', '2025-07-01',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- 5. CRÉATION DES POSITIONS RÉCENTES
-- ======================================

-- Positions autour de La Mecque (Kaaba : 21.4225, 39.8262)
INSERT INTO positions (id, user_id, lat, lng, accuracy, speed, heading, ts, created_at, updated_at)
VALUES
-- Groupe A (France)
('pos11111-0001-0001-0001-000000000001', 'p1111111-0001-0001-0001-111111111111',
 21.4225, 39.8262, 10.0, 0.0, 0.0, 
 CURRENT_TIMESTAMP - INTERVAL '5 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos11111-0001-0002-0002-000000000002', 'p1111111-0001-0002-0002-111111111111',
 21.4230, 39.8270, 8.5, 1.2, 45.0,
 CURRENT_TIMESTAMP - INTERVAL '3 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos11111-0001-0003-0003-000000000003', 'p1111111-0001-0003-0003-111111111111',
 21.4220, 39.8255, 12.0, 0.5, 90.0,
 CURRENT_TIMESTAMP - INTERVAL '7 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos11111-0001-0004-0004-000000000004', 'p1111111-0001-0004-0004-111111111111',
 21.4235, 39.8265, 15.0, 2.0, 180.0,
 CURRENT_TIMESTAMP - INTERVAL '10 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos11111-0001-0005-0005-000000000005', 'p1111111-0001-0005-0005-111111111111',
 21.4215, 39.8260, 9.0, 0.8, 270.0,
 CURRENT_TIMESTAMP - INTERVAL '2 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Groupe Premium 1 (Maroc)
('pos22222-0001-0001-0001-000000000001', 'p2222222-0001-0001-0001-222222222222',
 21.4210, 39.8268, 11.0, 0.3, 15.0,
 CURRENT_TIMESTAMP - INTERVAL '4 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos22222-0001-0002-0002-000000000002', 'p2222222-0001-0002-0002-222222222222',
 21.4228, 39.8275, 9.5, 0.7, 60.0,
 CURRENT_TIMESTAMP - INTERVAL '6 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos22222-0001-0003-0003-000000000003', 'p2222222-0001-0003-0003-222222222222',
 21.4218, 39.8258, 13.0, 1.5, 120.0,
 CURRENT_TIMESTAMP - INTERVAL '8 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos22222-0001-0004-0004-000000000004', 'p2222222-0001-0004-0004-222222222222',
 21.4232, 39.8269, 10.5, 0.9, 200.0,
 CURRENT_TIMESTAMP - INTERVAL '9 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos22222-0001-0005-0005-000000000005', 'p2222222-0001-0005-0005-222222222222',
 21.4212, 39.8263, 8.0, 0.4, 290.0,
 CURRENT_TIMESTAMP - INTERVAL '1 minute', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Groupe Familial (Tunisie)
('pos33333-0001-0001-0001-000000000001', 'p3333333-0001-0001-0001-333333333333',
 21.4223, 39.8264, 12.5, 0.6, 30.0,
 CURRENT_TIMESTAMP - INTERVAL '11 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos33333-0001-0002-0002-000000000002', 'p3333333-0001-0002-0002-333333333333',
 21.4227, 39.8267, 9.8, 1.0, 75.0,
 CURRENT_TIMESTAMP - INTERVAL '12 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos33333-0001-0003-0003-000000000003', 'p3333333-0001-0003-0003-333333333333',
 21.4222, 39.8261, 11.5, 0.8, 135.0,
 CURRENT_TIMESTAMP - INTERVAL '13 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos33333-0001-0004-0004-000000000004', 'p3333333-0001-0004-0004-333333333333',
 21.4229, 39.8266, 14.0, 1.8, 210.0,
 CURRENT_TIMESTAMP - INTERVAL '14 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('pos33333-0001-0005-0005-000000000005', 'p3333333-0001-0005-0005-333333333333',
 21.4216, 39.8259, 10.2, 0.5, 300.0,
 CURRENT_TIMESTAMP - INTERVAL '15 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- 6. CRÉATION DES POIs
-- ======================================

INSERT INTO pois (id, agency_id, type, name, lat, lng, metadata_json, created_at, updated_at)
VALUES
-- POIs Al-Barakah
('poi11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'HAJJ_SITE', 'Hôtel Al-Firdaws - Groupe A', 21.4200, 39.8280,
 '{"address": "Rue Ajyad, La Mecque", "phone": "+966 12 123 4567", "groupId": "11111111-1111-aaaa-aaaa-111111111111", "stars": 4}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('poi11111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111',
 'MEDICAL', 'Clinique Al-Noor', 21.4150, 39.8300,
 '{"address": "Avenue King Abdul Aziz", "phone": "+966 12 234 5678", "services": ["Urgences", "Médecine générale", "Cardiologie"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- POIs Omra Plus
('poi22222-2222-2222-2222-222222222221', '22222222-2222-2222-2222-222222222222',
 'HAJJ_SITE', 'Hôtel Premium - Groupe Premium 1', 21.4180, 39.8290,
 '{"address": "Rue Ajyad, La Mecque", "phone": "+966 12 345 6789", "groupId": "22222222-2222-aaaa-aaaa-222222222222", "stars": 5, "rating": 4.8}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('poi22222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
 'RESTAURANT', 'Restaurant Al-Bayt', 21.4190, 39.8275,
 '{"address": "Près de la mosquée", "phone": "+966 12 456 7890", "cuisine": "Internationale et orientale"}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- POIs Mambrouk
('poi33333-3333-3333-3333-333333333331', '33333333-3333-3333-3333-333333333333',
 'HAJJ_SITE', 'Résidence Familiale - Groupe Familial', 21.4170, 39.8285,
 '{"address": "Quartier Ajyad", "phone": "+966 12 567 8901", "groupId": "33333333-3333-aaaa-aaaa-333333333333", "stars": 3, "family_friendly": true}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('poi33333-3333-3333-3333-333333333332', '33333333-3333-3333-3333-333333333333',
 'MEDICAL', 'Pharmacie Al-Shifa', 21.4160, 39.8295,
 '{"address": "Avenue Ibrahim Al-Khalil", "phone": "+966 12 678 9012", "services": ["Médicaments", "Premiers soins"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- POIs communs (sans agence spécifique)
('poi00000-0000-0000-0000-000000000001', NULL,
 'HAJJ_SITE', 'Masjid al-Haram (Grande Mosquée)', 21.4225, 39.8262,
 '{"description": "La mosquée sacrée de La Mecque abritant la Kaaba", "capacity": 4000000}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('poi00000-0000-0000-0000-000000000002', NULL,
 'HAJJ_SITE', 'Mont Arafat', 21.3550, 39.8433,
 '{"description": "Lieu principal du pèlerinage du Hajj", "significance": "Wuquf"}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('poi00000-0000-0000-0000-000000000003', NULL,
 'HAJJ_SITE', 'Muzdalifah', 21.4034, 39.9294,
 '{"description": "Lieu de repos entre Arafat et Mina", "significance": "Collecte de pierres"}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('poi00000-0000-0000-0000-000000000004', NULL,
 'HAJJ_SITE', 'Jamaraat (Lapidation)', 21.4163, 39.8776,
 '{"description": "Les trois piliers de la lapidation à Mina", "significance": "Lapidation du diable"}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- 7. CRÉATION DES ALERTES
-- ======================================

INSERT INTO alerts (id, agency_id, user_id, type, status, payload_json, resolved_at, created_at, updated_at)
VALUES
-- Alertes actives
('alert111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'p1111111-0001-0002-0002-111111111111',
 'SOS', 'ACTIVE',
 '{"message": "Pèlerin perdu près de la Kaaba", "lat": 21.4230, "lng": 39.8270, "severity": "HIGH"}',
 NULL, CURRENT_TIMESTAMP - INTERVAL '30 minutes', CURRENT_TIMESTAMP),

('alert222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
 'p2222222-0001-0004-0004-222222222222',
 'HEALTH', 'ACTIVE',
 '{"message": "Malaise signalé, besoin d''assistance médicale", "severity": "MEDIUM"}',
 NULL, CURRENT_TIMESTAMP - INTERVAL '20 minutes', CURRENT_TIMESTAMP),

-- Alertes résolues
('alert111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111',
 'p1111111-0001-0004-0004-111111111111',
 'LOW_BATTERY', 'RESOLVED',
 '{"battery": 5, "message": "Batterie faible"}',
 CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP),

('alert333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333',
 'p3333333-0001-0003-0003-333333333333',
 'GEOFENCE_EXIT', 'RESOLVED',
 '{"message": "Pèlerin sorti de la zone autorisée", "geofence": "Zone Mina", "lat": 21.4170, "lng": 39.8800}',
 CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ======================================
-- SEED TERMINÉ
-- ======================================

-- Statistiques du seed :
-- - 3 agences
-- - 6 utilisateurs (admins + guides)
-- - 6 groupes
-- - 15 pèlerins
-- - 15 positions
-- - 10 POIs
-- - 4 alertes

-- Connexion test :
-- Email: admin@albarakah.fr / Password: password123
-- Email: admin@omraplus.ma / Password: password123
-- Email: admin@mambrouk.tn / Password: password123







