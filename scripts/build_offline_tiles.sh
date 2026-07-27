#!/usr/bin/env bash
# Régénère les fonds de carte hors ligne (assets/maps/*.pmtiles).
#
# Les tuiles viennent du build quotidien Protomaps (données OpenStreetMap,
# licence ODbL) : on n'extrait que les emprises utiles, par requêtes HTTP Range
# — aucun téléchargement de la planète.
#
# Prérequis : le binaire `pmtiles` (https://github.com/protomaps/go-pmtiles).
#   Linux/macOS : télécharger l'archive de la release, mettre `pmtiles` dans le PATH.
#   Windows Git Bash : idem avec pmtiles.exe.
#
# Usage :
#   ./scripts/build_offline_tiles.sh              # dernier build disponible
#   ./scripts/build_offline_tiles.sh 20260726     # build daté précis
#
# À relancer avant chaque release notable : les tuiles embarquées datent du jour
# de génération (voir la clé `planetiler:osm:osmosisreplicationtime` via
# `pmtiles show assets/maps/makkah.pmtiles`).

set -euo pipefail

cd "$(dirname "$0")/.."
OUT_DIR="assets/maps"
MAX_ZOOM=15

PMTILES_BIN="${PMTILES_BIN:-pmtiles}"
command -v "$PMTILES_BIN" >/dev/null 2>&1 || {
  echo "Binaire '$PMTILES_BIN' introuvable. Installer go-pmtiles ou définir PMTILES_BIN." >&2
  exit 1
}

# Emprises. Makkah inclut Mina, Muzdalifah et Arafat (sites du Hajj, < 25 km
# du Haram) ; Madinah couvre l'agglomération autour de Masjid an-Nabawi.
REGIONS=(
  "makkah:39.68,21.24,40.06,21.58"
  "madinah:39.42,24.30,39.80,24.65"
)

# Le build du jour n'est pas toujours publié ; on remonte de quelques jours.
pick_build() {
  if [ $# -ge 1 ] && [ -n "${1:-}" ]; then
    echo "$1"
    return
  fi
  for offset in 1 2 3 4 5 6 7; do
    local day
    if date -d "-${offset} day" +%Y%m%d >/dev/null 2>&1; then
      day=$(date -d "-${offset} day" +%Y%m%d)      # GNU date
    else
      day=$(date -v-"${offset}"d +%Y%m%d)          # BSD/macOS date
    fi
    if curl -sS --ssl-no-revoke -I -m 30 \
        "https://build.protomaps.com/${day}.pmtiles" -o /dev/null -w '%{http_code}' \
        | grep -q 200; then
      echo "$day"
      return
    fi
  done
  echo "Aucun build Protomaps récent trouvé." >&2
  exit 1
}

BUILD_DAY=$(pick_build "${1:-}")
SOURCE="https://build.protomaps.com/${BUILD_DAY}.pmtiles"
echo "Source : $SOURCE"

mkdir -p "$OUT_DIR"
for region in "${REGIONS[@]}"; do
  name="${region%%:*}"
  bbox="${region#*:}"
  echo "→ $name ($bbox, z0-$MAX_ZOOM)"
  "$PMTILES_BIN" extract "$SOURCE" "$OUT_DIR/$name.pmtiles" \
    --bbox="$bbox" --maxzoom="$MAX_ZOOM"
done

echo
echo "Fonds de carte régénérés :"
ls -la "$OUT_DIR"/*.pmtiles
echo
echo "Attribution obligatoire dans l'app : © OpenStreetMap contributors (ODbL)."
