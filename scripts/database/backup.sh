#!/bin/bash

#######################################################
# 💾 Script de sauvegarde PostgreSQL - Sahabi Guide
#######################################################
# Ce script crée une sauvegarde de la base de données
#######################################################

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

# Configuration
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
COMPOSE_FILE="docker-compose.full.yml"

# Charger les variables d'environnement
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DB_NAME=${POSTGRES_DB:-sahabi_db}
DB_USER=${POSTGRES_USER:-sahabi}
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql"

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     💾 SAUVEGARDE BASE DE DONNÉES        ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Créer le dossier de sauvegarde
mkdir -p "$BACKUP_DIR"

# Vérifier que PostgreSQL est démarré
if ! docker-compose -f $COMPOSE_FILE ps postgres | grep -q "Up"; then
    log_error "PostgreSQL n'est pas démarré !"
    exit 1
fi

# Sauvegarde
log_info "Sauvegarde de la base de données '$DB_NAME'..."
docker-compose -f $COMPOSE_FILE exec -T postgres pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

# Compression
log_info "Compression..."
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Taille du fichier
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log_success "Sauvegarde créée : $BACKUP_FILE ($SIZE)"

# Nettoyage des anciennes sauvegardes (garder les 30 dernières)
log_info "Nettoyage des anciennes sauvegardes..."
cd "$BACKUP_DIR"
ls -t ${DB_NAME}_*.sql.gz | tail -n +31 | xargs -r rm -f
cd - > /dev/null

BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/${DB_NAME}_*.sql.gz 2>/dev/null | wc -l)
log_success "Nombre de sauvegardes conservées : $BACKUP_COUNT"

echo ""
log_info "Pour restaurer cette sauvegarde :"
echo "  gunzip -c $BACKUP_FILE | docker-compose -f $COMPOSE_FILE exec -T postgres psql -U $DB_USER $DB_NAME"
echo ""

