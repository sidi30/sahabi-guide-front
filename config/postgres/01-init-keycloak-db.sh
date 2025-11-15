#!/bin/bash
set -e

# Création de la base de données et de l'utilisateur pour Keycloak
echo "🔐 Création de la base de données Keycloak..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Créer l'utilisateur keycloak
    CREATE USER keycloak WITH PASSWORD 'keycloak';
    
    -- Créer la base de données keycloak_db
    CREATE DATABASE keycloak_db;
    
    -- Donner tous les privilèges à l'utilisateur keycloak
    GRANT ALL PRIVILEGES ON DATABASE keycloak_db TO keycloak;
    
    -- Se connecter à keycloak_db et donner les privilèges sur le schéma public
    \c keycloak_db
    GRANT ALL ON SCHEMA public TO keycloak;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO keycloak;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO keycloak;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO keycloak;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO keycloak;
EOSQL

echo "✅ Base de données Keycloak créée avec succès!"

