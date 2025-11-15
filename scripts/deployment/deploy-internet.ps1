#######################################################
# 🌐 SCRIPT DE DÉPLOIEMENT INTERNET - SAHABI GUIDE
#######################################################
# Ce script configure automatiquement l'accès Internet
# pour votre application Sahabi Guide
#######################################################

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("tailscale", "caddy", "direct", "help")]
    [string]$Mode = "help",
    
    [Parameter(Mandatory=$false)]
    [string]$Domain = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Email = "",
    
    [Parameter(Mandatory=$false)]
    [string]$TailscaleKey = ""
)

# Couleurs pour l'affichage
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
    Write-ColorOutput "  $Title" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Error-Custom {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" "Yellow"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️  $Message" "Blue"
}

function Show-Help {
    Write-Header "Guide d'utilisation - Déploiement Internet"
    
    Write-Host "Ce script configure automatiquement l'accès Internet pour Sahabi Guide."
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\deploy-internet.ps1 -Mode <mode> [options]"
    Write-Host ""
    Write-Host "MODES DISPONIBLES:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. TAILSCALE (Recommandé - Le plus simple)" -ForegroundColor Cyan
    Write-Host "     .\deploy-internet.ps1 -Mode tailscale -TailscaleKey `"tskey-auth-...`""
    Write-Host "     • Pas besoin de domaine"
    Write-Host "     • Configuration automatique"
    Write-Host "     • Sécurisé par défaut"
    Write-Host ""
    Write-Host "  2. CADDY (Production - Avec nom de domaine)" -ForegroundColor Cyan
    Write-Host "     .\deploy-internet.ps1 -Mode caddy -Domain `"sahabi-guide.com`" -Email `"admin@example.com`""
    Write-Host "     • Nécessite un nom de domaine"
    Write-Host "     • SSL automatique (Let's Encrypt)"
    Write-Host "     • Professionnel"
    Write-Host ""
    Write-Host "  3. DIRECT (Tests uniquement - Sans SSL)" -ForegroundColor Cyan
    Write-Host "     .\deploy-internet.ps1 -Mode direct"
    Write-Host "     • Exposition directe des ports"
    Write-Host "     • Pas de SSL"
    Write-Host "     • Non recommandé en production"
    Write-Host ""
    Write-Host "EXEMPLES:" -ForegroundColor Yellow
    Write-Host "  # Avec Tailscale"
    Write-Host '  .\deploy-internet.ps1 -Mode tailscale -TailscaleKey "tskey-auth-kH5XSEoevj11CNTRL-..."'
    Write-Host ""
    Write-Host "  # Avec Caddy et nom de domaine"
    Write-Host '  .\deploy-internet.ps1 -Mode caddy -Domain "sahabi-guide.com" -Email "admin@example.com"'
    Write-Host ""
    Write-Host "  # Exposition directe (tests)"
    Write-Host "  .\deploy-internet.ps1 -Mode direct"
    Write-Host ""
    Write-Host "DOCUMENTATION:" -ForegroundColor Yellow
    Write-Host "  Consultez ACCES_INTERNET.md pour plus de détails"
    Write-Host ""
}

function Test-Prerequisites {
    Write-Header "Vérification des prérequis"
    
    $allGood = $true
    
    # Vérifier Docker
    Write-Info "Vérification de Docker..."
    try {
        $dockerVersion = docker --version
        Write-Success "Docker installé : $dockerVersion"
    } catch {
        Write-Error-Custom "Docker n'est pas installé ou n'est pas dans le PATH"
        Write-Host "  → Installez Docker Desktop : https://www.docker.com/products/docker-desktop"
        $allGood = $false
    }
    
    # Vérifier Docker Compose
    Write-Info "Vérification de Docker Compose..."
    try {
        $composeVersion = docker-compose --version
        Write-Success "Docker Compose installé : $composeVersion"
    } catch {
        Write-Error-Custom "Docker Compose n'est pas installé"
        $allGood = $false
    }
    
    # Vérifier que Docker est démarré
    Write-Info "Vérification du démon Docker..."
    try {
        docker ps | Out-Null
        Write-Success "Docker est en cours d'exécution"
    } catch {
        Write-Error-Custom "Docker n'est pas démarré"
        Write-Host "  → Démarrez Docker Desktop"
        $allGood = $false
    }
    
    # Vérifier les fichiers nécessaires
    Write-Info "Vérification des fichiers du projet..."
    $requiredFiles = @(
        "docker-compose.yml",
        "Caddyfile",
        "tailscale-serve.json",
        "env.template"
    )
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Success "Fichier trouvé : $file"
        } else {
            Write-Error-Custom "Fichier manquant : $file"
            $allGood = $false
        }
    }
    
    Write-Host ""
    return $allGood
}

function Create-EnvFile {
    Write-Header "Configuration du fichier .env"
    
    if (Test-Path ".env") {
        Write-Warning-Custom "Le fichier .env existe déjà"
        $overwrite = Read-Host "Voulez-vous le remplacer ? (o/N)"
        if ($overwrite -ne "o" -and $overwrite -ne "O") {
            Write-Info "Conservation du fichier .env existant"
            return
        }
    }
    
    Write-Info "Copie de env.template vers .env..."
    Copy-Item "env.template" ".env"
    Write-Success "Fichier .env créé"
}

function Configure-Tailscale {
    Write-Header "Configuration Tailscale"
    
    if ([string]::IsNullOrWhiteSpace($TailscaleKey)) {
        Write-Error-Custom "La clé Tailscale est requise"
        Write-Host ""
        Write-Host "Pour obtenir une clé Tailscale :" -ForegroundColor Yellow
        Write-Host "  1. Créez un compte sur https://login.tailscale.com/start"
        Write-Host "  2. Allez sur https://login.tailscale.com/admin/settings/keys"
        Write-Host "  3. Cliquez sur 'Generate auth key'"
        Write-Host "  4. Cochez 'Reusable' et générez la clé"
        Write-Host "  5. Relancez le script avec : -TailscaleKey `"tskey-auth-...`""
        Write-Host ""
        exit 1
    }
    
    # Créer le fichier .env si nécessaire
    Create-EnvFile
    
    # Mettre à jour la clé Tailscale dans .env
    Write-Info "Mise à jour de la clé Tailscale dans .env..."
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "TAILSCALE_AUTHKEY=.*", "TAILSCALE_AUTHKEY=$TailscaleKey"
    Set-Content ".env" $envContent -NoNewline
    Write-Success "Clé Tailscale configurée"
    
    # Arrêter les services existants
    Write-Info "Arrêt des services en cours..."
    docker-compose down 2>$null
    
    # Démarrer avec le profil production
    Write-Info "Démarrage des services avec Tailscale..."
    Write-Host ""
    docker-compose --profile production up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Services démarrés avec succès !"
        
        # Attendre que Tailscale soit prêt
        Write-Info "Attente du démarrage de Tailscale (30 secondes)..."
        Start-Sleep -Seconds 30
        
        # Afficher le statut Tailscale
        Write-Header "Statut Tailscale"
        docker exec sahabi-tailscale tailscale status 2>$null
        
        # Instructions pour Tailscale Serve
        Write-Host ""
        Write-Header "Configuration Tailscale Serve"
        Write-Host "Pour exposer votre application via Tailscale, exécutez :" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  docker exec -it sahabi-tailscale sh" -ForegroundColor Cyan
        Write-Host "  tailscale serve https / http://frontend:80" -ForegroundColor Cyan
        Write-Host "  exit" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Pour un accès PUBLIC (sans installation Tailscale) :" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  docker exec -it sahabi-tailscale sh" -ForegroundColor Cyan
        Write-Host "  tailscale funnel 443 on" -ForegroundColor Cyan
        Write-Host "  exit" -ForegroundColor Cyan
        Write-Host ""
        
    } else {
        Write-Error-Custom "Erreur lors du démarrage des services"
        Write-Host ""
        Write-Host "Consultez les logs avec : docker-compose logs" -ForegroundColor Yellow
        exit 1
    }
}

function Configure-Caddy {
    Write-Header "Configuration Caddy + Domaine"
    
    if ([string]::IsNullOrWhiteSpace($Domain)) {
        Write-Error-Custom "Le nom de domaine est requis"
        Write-Host ""
        Write-Host "Exemple : .\deploy-internet.ps1 -Mode caddy -Domain `"sahabi-guide.com`" -Email `"admin@example.com`"" -ForegroundColor Yellow
        exit 1
    }
    
    if ([string]::IsNullOrWhiteSpace($Email)) {
        Write-Error-Custom "L'email est requis pour les certificats SSL"
        Write-Host ""
        Write-Host "Exemple : .\deploy-internet.ps1 -Mode caddy -Domain `"sahabi-guide.com`" -Email `"admin@example.com`"" -ForegroundColor Yellow
        exit 1
    }
    
    # Vérifier les DNS
    Write-Info "Vérification des DNS pour $Domain..."
    try {
        $dnsResult = Resolve-DnsName $Domain -ErrorAction Stop
        $ipAddress = $dnsResult | Where-Object { $_.Type -eq "A" } | Select-Object -First 1 -ExpandProperty IPAddress
        Write-Success "DNS configuré : $Domain → $ipAddress"
    } catch {
        Write-Warning-Custom "Impossible de résoudre $Domain"
        Write-Host "  Assurez-vous que les enregistrements DNS sont configurés :" -ForegroundColor Yellow
        Write-Host "    A    @     VOTRE_IP_SERVEUR"
        Write-Host "    A    api   VOTRE_IP_SERVEUR"
        Write-Host "    A    auth  VOTRE_IP_SERVEUR"
        Write-Host ""
        $continue = Read-Host "Continuer quand même ? (o/N)"
        if ($continue -ne "o" -and $continue -ne "O") {
            exit 1
        }
    }
    
    # Créer le fichier .env si nécessaire
    Create-EnvFile
    
    # Mettre à jour .env
    Write-Info "Mise à jour de la configuration dans .env..."
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DOMAIN=.*", "DOMAIN=$Domain"
    $envContent = $envContent -replace "ACME_EMAIL=.*", "ACME_EMAIL=$Email"
    $envContent = $envContent -replace "KEYCLOAK_HOSTNAME=.*", "KEYCLOAK_HOSTNAME=auth.$Domain"
    $envContent = $envContent -replace "VITE_API_BASE_URL=.*", "VITE_API_BASE_URL=https://api.$Domain"
    $envContent = $envContent -replace "VITE_KEYCLOAK_URL=.*", "VITE_KEYCLOAK_URL=https://auth.$Domain"
    $envContent = $envContent -replace "CORS_ALLOWED_ORIGINS=.*", "CORS_ALLOWED_ORIGINS=https://$Domain,https://api.$Domain,https://auth.$Domain"
    Set-Content ".env" $envContent -NoNewline
    Write-Success "Configuration mise à jour"
    
    # Avertissement pour Keycloak realm
    Write-Host ""
    Write-Warning-Custom "ACTION REQUISE : Mise à jour du Keycloak Realm"
    Write-Host "  Vous devez mettre à jour les URLs de redirection dans :" -ForegroundColor Yellow
    Write-Host "  sahabi-guide-api/keycloak/import/sahabi-realm.json" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Ajoutez ces URLs dans le client 'sahabi-dashboard' :" -ForegroundColor Yellow
    Write-Host "    redirectUris: [`"https://$Domain/*`"]" -ForegroundColor Cyan
    Write-Host "    webOrigins: [`"https://$Domain`"]" -ForegroundColor Cyan
    Write-Host ""
    $continue = Read-Host "Appuyez sur Entrée quand c'est fait (ou Ctrl+C pour annuler)"
    
    # Arrêter les services existants
    Write-Info "Arrêt des services en cours..."
    docker-compose down 2>$null
    
    # Supprimer l'image frontend pour forcer le rebuild
    Write-Info "Suppression de l'image frontend pour rebuild..."
    docker rmi sahabi-guide-dashboard-frontend 2>$null
    
    # Démarrer avec le profil production et rebuild
    Write-Info "Démarrage des services avec Caddy..."
    Write-Host ""
    docker-compose --profile production up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Services démarrés avec succès !"
        
        # Attendre que Caddy soit prêt
        Write-Info "Attente du démarrage de Caddy (30 secondes)..."
        Start-Sleep -Seconds 30
        
        # Vérifier les certificats
        Write-Header "Vérification des certificats SSL"
        docker exec sahabi-caddy caddy list-certificates 2>$null
        
        Write-Host ""
        Write-Header "🎉 Déploiement terminé !"
        Write-Host ""
        Write-Host "Votre application est accessible via :" -ForegroundColor Green
        Write-Host "  🎨 Frontend   : https://$Domain" -ForegroundColor Cyan
        Write-Host "  🔧 API        : https://api.$Domain" -ForegroundColor Cyan
        Write-Host "  🔐 Keycloak   : https://auth.$Domain" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Vérifiez les logs avec : docker-compose logs -f caddy" -ForegroundColor Yellow
        Write-Host ""
        
    } else {
        Write-Error-Custom "Erreur lors du démarrage des services"
        Write-Host ""
        Write-Host "Consultez les logs avec : docker-compose logs" -ForegroundColor Yellow
        exit 1
    }
}

function Configure-Direct {
    Write-Header "Configuration Exposition Directe"
    
    Write-Warning-Custom "ATTENTION : Cette méthode n'est PAS recommandée en production !"
    Write-Host "  • Pas de SSL (données non chiffrées)" -ForegroundColor Yellow
    Write-Host "  • Ports non standard" -ForegroundColor Yellow
    Write-Host "  • Moins sécurisé" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Utilisez cette méthode uniquement pour des TESTS !" -ForegroundColor Red
    Write-Host ""
    $continue = Read-Host "Continuer quand même ? (o/N)"
    if ($continue -ne "o" -and $continue -ne "O") {
        Write-Info "Déploiement annulé"
        exit 0
    }
    
    # Créer le fichier .env si nécessaire
    Create-EnvFile
    
    # Modifier docker-compose.yml pour exposer Keycloak publiquement
    Write-Info "Modification de docker-compose.yml pour exposer Keycloak..."
    $composeContent = Get-Content "docker-compose.yml" -Raw
    $composeContent = $composeContent -replace '127\.0\.0\.1:\$\{KEYCLOAK_PORT:-8080\}:8080', '${KEYCLOAK_PORT:-8080}:8080'
    Set-Content "docker-compose.yml" $composeContent -NoNewline
    Write-Success "docker-compose.yml modifié"
    
    # Arrêter les services existants
    Write-Info "Arrêt des services en cours..."
    docker-compose down 2>$null
    
    # Démarrer les services de base
    Write-Info "Démarrage des services..."
    Write-Host ""
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Services démarrés avec succès !"
        
        # Obtenir l'IP publique
        Write-Info "Récupération de votre IP publique..."
        try {
            $publicIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
            Write-Success "IP publique : $publicIp"
        } catch {
            $publicIp = "VOTRE_IP_PUBLIQUE"
            Write-Warning-Custom "Impossible de récupérer l'IP publique automatiquement"
        }
        
        Write-Host ""
        Write-Header "⚠️  Configuration du Pare-feu Requise"
        Write-Host "Vous devez ouvrir ces ports sur votre pare-feu Windows :" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "New-NetFirewallRule -DisplayName `"Frontend`" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow" -ForegroundColor Cyan
        Write-Host "New-NetFirewallRule -DisplayName `"Keycloak`" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow" -ForegroundColor Cyan
        Write-Host "New-NetFirewallRule -DisplayName `"Backend`" -Direction Inbound -Protocol TCP -LocalPort 8084 -Action Allow" -ForegroundColor Cyan
        Write-Host ""
        $configFirewall = Read-Host "Configurer le pare-feu maintenant ? (o/N)"
        if ($configFirewall -eq "o" -or $configFirewall -eq "O") {
            try {
                New-NetFirewallRule -DisplayName "Sahabi Frontend" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -ErrorAction Stop | Out-Null
                New-NetFirewallRule -DisplayName "Sahabi Keycloak" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -ErrorAction Stop | Out-Null
                New-NetFirewallRule -DisplayName "Sahabi Backend" -Direction Inbound -Protocol TCP -LocalPort 8084 -Action Allow -ErrorAction Stop | Out-Null
                Write-Success "Règles de pare-feu créées"
            } catch {
                Write-Error-Custom "Erreur lors de la création des règles de pare-feu"
                Write-Host "  Vous devez exécuter PowerShell en tant qu'Administrateur" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Header "🎉 Déploiement terminé !"
        Write-Host ""
        Write-Host "Votre application est accessible via :" -ForegroundColor Green
        Write-Host "  🎨 Frontend   : http://${publicIp}:3000" -ForegroundColor Cyan
        Write-Host "  🔧 API        : http://${publicIp}:8084" -ForegroundColor Cyan
        Write-Host "  🔐 Keycloak   : http://${publicIp}:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "⚠️  N'oubliez pas :" -ForegroundColor Yellow
        Write-Host "  • Configurer le port forwarding sur votre box Internet" -ForegroundColor Yellow
        Write-Host "  • Cette configuration n'a PAS de SSL (HTTP uniquement)" -ForegroundColor Yellow
        Write-Host ""
        
    } else {
        Write-Error-Custom "Erreur lors du démarrage des services"
        Write-Host ""
        Write-Host "Consultez les logs avec : docker-compose logs" -ForegroundColor Yellow
        exit 1
    }
}

function Show-Status {
    Write-Header "État des Services"
    docker-compose ps
    
    Write-Host ""
    Write-Info "Pour voir les logs : docker-compose logs -f"
    Write-Info "Pour arrêter : docker-compose down"
}

#######################################################
# MAIN
#######################################################

Write-Header "🌐 Déploiement Internet - Sahabi Guide"

# Afficher l'aide si demandé
if ($Mode -eq "help") {
    Show-Help
    exit 0
}

# Vérifier les prérequis
if (-not (Test-Prerequisites)) {
    Write-Host ""
    Write-Error-Custom "Les prérequis ne sont pas satisfaits"
    Write-Host "Corrigez les erreurs ci-dessus et relancez le script" -ForegroundColor Yellow
    exit 1
}

# Exécuter le mode choisi
switch ($Mode) {
    "tailscale" {
        Configure-Tailscale
    }
    "caddy" {
        Configure-Caddy
    }
    "direct" {
        Configure-Direct
    }
    default {
        Write-Error-Custom "Mode invalide : $Mode"
        Write-Host ""
        Show-Help
        exit 1
    }
}

# Afficher le statut final
Write-Host ""
Show-Status

Write-Host ""
Write-Success "Déploiement terminé avec succès !"
Write-Host ""
Write-Host "📚 Pour plus d'informations, consultez ACCES_INTERNET.md" -ForegroundColor Cyan
Write-Host ""

