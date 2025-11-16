# Script pour build le dashboard React avec Cloud Build
# Utilise les URLs de production

param(
    [string]$MapboxToken = $env:MAPBOX_ACCESS_TOKEN
)

$PROJECT_ID = "sahabiguide-478323"
$REGION = "europe-west1"
$REGISTRY = "$REGION-docker.pkg.dev/$PROJECT_ID/sahabi-registry"

# URLs de production
$BACKEND_URL = "https://sahabi-backend-520537349678.europe-west1.run.app"
$KEYCLOAK_URL = "https://sahabi-keycloak-520537349678.europe-west1.run.app"

Write-Host "=== BUILD DASHBOARD AVEC CLOUD BUILD ===" -ForegroundColor Cyan
Write-Host "Backend URL: $BACKEND_URL" -ForegroundColor Yellow
Write-Host "Keycloak URL: $KEYCLOAK_URL" -ForegroundColor Yellow
if ($MapboxToken) {
    Write-Host "Mapbox: token détecté (non affiché pour sécurité)" -ForegroundColor Yellow
} else {
    Write-Host "Mapbox: aucun token fourni - les cartes avancées seront désactivées" -ForegroundColor Yellow
}
Write-Host ""

# Aller dans le dossier dashboard
$DASHBOARD_DIR = Join-Path $PSScriptRoot "..\sahabi-guide-dashboard"
Set-Location $DASHBOARD_DIR

Write-Host "Building Dashboard avec Cloud Build..." -ForegroundColor Cyan

# Vérifier que cloudbuild.yaml existe
if (-not (Test-Path "cloudbuild.yaml")) {
    Write-Host "ERREUR: cloudbuild.yaml introuvable dans $DASHBOARD_DIR" -ForegroundColor Red
    exit 1
}

# Si Mapbox token fourni, créer un cloudbuild.yaml temporaire avec le token
if ($MapboxToken) {
    Write-Host "Création de cloudbuild.yaml avec Mapbox token..." -ForegroundColor Yellow
    $cloudbuildContent = @"
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '--tag=europe-west1-docker.pkg.dev/`$PROJECT_ID/sahabi-registry/dashboard:latest'
      - '--build-arg=VITE_API_BASE_URL=$BACKEND_URL'
      - '--build-arg=VITE_API_BASE_PATH=/api/v1'
      - '--build-arg=VITE_ENABLE_KEYCLOAK=true'
      - '--build-arg=VITE_KEYCLOAK_URL=$KEYCLOAK_URL'
      - '--build-arg=VITE_KEYCLOAK_REALM=sahabi'
      - '--build-arg=VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard'
      - '--build-arg=VITE_MAPBOX_ACCESS_TOKEN=$MapboxToken'
      - '.'

  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'europe-west1-docker.pkg.dev/`$PROJECT_ID/sahabi-registry/dashboard:latest'

images:
  - 'europe-west1-docker.pkg.dev/`$PROJECT_ID/sahabi-registry/dashboard:latest'

options:
  machineType: 'E2_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY
"@
    $cloudbuildContent | Out-File -FilePath "cloudbuild.yaml" -Encoding UTF8 -Force
}

# Lancer Cloud Build avec cloudbuild.yaml
Write-Host "Lancement de Cloud Build..." -ForegroundColor Cyan
gcloud builds submit --config=cloudbuild.yaml .

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== DASHBOARD PRET ===" -ForegroundColor Green
    Write-Host "Image: $REGISTRY/dashboard:latest" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Déployer avec Terraform:" -ForegroundColor Cyan
    Write-Host "  cd terraform" -ForegroundColor White
    Write-Host "  terraform apply -target=google_cloud_run_v2_service.dashboard" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "=== ERREUR LORS DU BUILD ===" -ForegroundColor Red
    exit 1
}

Set-Location $PSScriptRoot

