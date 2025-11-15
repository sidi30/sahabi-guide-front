#!/bin/bash

#######################################################
# 🔄 Script de restauration PostgreSQL - Sahabi Guide
#######################################################
# Ce script restaure une sauvegarde de la base de données
#######################################################

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Configuration
BACKUP_DIR="./backups"
COMPOSE_FILE="docker-compose.full.yml"

# Charger les variables d'environnement
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DB_NAME=${POSTGRES_DB:-sahabi_db}
DB_USER=${POSTGRES_USER:-sahabi}

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     🔄 RESTAURATION BASE DE DONNÉES      ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Vérifier que PostgreSQL est démarré
if ! docker-compose -f $COMPOSE_FILE ps postgres | grep -q "Up"; then
    log_error "PostgreSQL n'est pas démarré !"
    exit 1
fi

# Lister les sauvegardes disponibles
if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]; then
    log_error "Aucune sauvegarde trouvée dans $BACKUP_DIR"
    exit 1
fi

log_info "Sauvegardes disponibles :"
echo ""
select backup_file in "$BACKUP_DIR"/*.sql.gz; do
    if [ -n "$backup_file" ]; then
        break
    fi
done

if [ -z "$backup_file" ]; then
    log_error "Aucune sauvegarde sélectionnée"
    exit 1
fi

echo ""
log_warning "⚠️  ATTENTION : Cette action va ÉCRASER la base de données actuelle !"
log_info "Base de données : $DB_NAME"
log_info "Sauvegarde      : $backup_file"
echo ""
read -p "Êtes-vous sûr ? Tapez 'OUI' pour confirmer : " confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Annulé"
    exit 0
fi

# Créer une sauvegarde de sécurité avant restauration
log_info "Création d'une sauvegarde de sécurité..."
DATE=$(date +%Y%m%d_%H%M%S)
SAFETY_BACKUP="$BACKUP_DIR/${DB_NAME}_avant_restauration_${DATE}.sql.gz"
docker-compose -f $COMPOSE_FILE exec -T postgres pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$SAFETY_BACKUP"
log_success "Sauvegarde de sécurité créée : $SAFETY_BACKUP"

# Restauration
log_info "Restauration en cours..."
gunzip -c "$backup_file" | docker-compose -f $COMPOSE_FILE exec -T postgres psql -U "$DB_USER" "$DB_NAME"

log_success "Base de données restaurée avec succès !"
echo ""
log_info "Si quelque chose ne va pas, vous pouvez restaurer la sauvegarde de sécurité :"
echo "  $0"
echo "  Et sélectionnez : $SAFETY_BACKUP"
echo ""

