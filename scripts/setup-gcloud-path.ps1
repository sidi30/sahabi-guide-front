#######################################################
# Script pour Ajouter Google Cloud SDK au PATH
#######################################################
# Ce script ajoute gcloud au PATH de manière permanente
# pour l'utilisateur actuel
#
# Usage: .\scripts\setup-gcloud-path.ps1
#######################################################

Write-Host "🔧 Configuration de Google Cloud SDK dans le PATH" -ForegroundColor Blue
Write-Host ""

# Chemin vers Google Cloud SDK
$gcloudPath = "C:\Users\$env:USERNAME\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin"

# Vérifier que le chemin existe
if (-not (Test-Path $gcloudPath)) {
    Write-Host "❌ Google Cloud SDK non trouvé à: $gcloudPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez vérifier l'installation de Google Cloud SDK." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Google Cloud SDK trouvé à: $gcloudPath" -ForegroundColor Green

# Récupérer le PATH actuel de l'utilisateur
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Vérifier si gcloud est déjà dans le PATH
if ($currentPath -like "*$gcloudPath*") {
    Write-Host "✅ Google Cloud SDK est déjà dans le PATH" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous pouvez maintenant utiliser 'gcloud' depuis n'importe quel terminal." -ForegroundColor Cyan
    exit 0
}

Write-Host ""
Write-Host "⚠️  Google Cloud SDK n'est pas dans le PATH" -ForegroundColor Yellow
Write-Host "Voulez-vous l'ajouter de manière permanente ? (O/N)" -ForegroundColor Cyan
$response = Read-Host

if ($response -eq "O" -or $response -eq "o" -or $response -eq "Y" -or $response -eq "y") {
    try {
        # Ajouter au PATH
        $newPath = "$currentPath;$gcloudPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        
        Write-Host ""
        Write-Host "✅ Google Cloud SDK ajouté au PATH avec succès !" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  Important: Redémarrez PowerShell pour que les changements prennent effet." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Après le redémarrage, vous pourrez utiliser:" -ForegroundColor Cyan
        Write-Host "  - gcloud --version" -ForegroundColor White
        Write-Host "  - gcloud auth list" -ForegroundColor White
        Write-Host "  - gcloud projects list" -ForegroundColor White
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "❌ Erreur lors de l'ajout au PATH: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Essayez d'exécuter ce script en tant qu'administrateur." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host ""
    Write-Host "⏭️  Ajout au PATH annulé" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pour utiliser gcloud dans cette session, exécutez:" -ForegroundColor Cyan
    Write-Host "`$env:PATH = `"$gcloudPath;`$env:PATH`"" -ForegroundColor White
}

Write-Host ""
Write-Host "Pour plus d'informations, consultez:" -ForegroundColor Cyan
Write-Host "   - CONFIGURATION_ENVIRONNEMENT.md" -ForegroundColor White
Write-Host ""

