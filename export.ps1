# Script d'export automatique pour itch.io
# Necessite Godot installe et accessible via la ligne de commande

param(
    [string]$GodotPath = "",
    [switch]$SkipWeb,
    [switch]$SkipWindows,
    [switch]$SkipLinux,
    [switch]$SkipMac
)

$ErrorActionPreference = "Stop"
$ProjectPath = Join-Path $PSScriptRoot "ggj-2026"
$ProjectFile = Join-Path $ProjectPath "project.godot"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Export GGJ2026 pour itch.io" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Demander l'emplacement de Godot si non specifie
if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    Write-Host "Ou se trouve votre executable Godot ?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Emplacements courants :" -ForegroundColor Gray
    Write-Host "  - C:\Users\$env:USERNAME\Documents\Perso\Godot\Godot_v4.5.1-stable_win64.exe" -ForegroundColor Gray
    Write-Host "  - C:\Godot\Godot_v4.5.1-stable_win64.exe" -ForegroundColor Gray
    Write-Host "  - Tapez 'godot' si Godot est dans votre PATH" -ForegroundColor Gray
    Write-Host ""
    $GodotPath = Read-Host "Chemin vers Godot"
    
    if ([string]::IsNullOrWhiteSpace($GodotPath)) {
        Write-Host "Erreur : Aucun chemin specifie !" -ForegroundColor Red
        exit 1
    }
}

# Verifier que Godot est disponible
Write-Host ""
Write-Host "Verification de Godot..." -ForegroundColor Cyan
try {
    $godotVersion = & $GodotPath --version 2>&1
    Write-Host "Godot trouve : $godotVersion" -ForegroundColor Green
} catch {
    Write-Host "Erreur : Godot n'est pas trouve au chemin specifie !" -ForegroundColor Red
    Write-Host "  Chemin utilise : $GodotPath" -ForegroundColor Yellow
    Write-Host "  Veuillez verifier le chemin et reessayer." -ForegroundColor Yellow
    exit 1
}

# Verifier que le projet existe
if (-not (Test-Path $ProjectFile)) {
    Write-Host "Erreur : project.godot non trouve dans ggj-2026/" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "RECAPITULATIF AVANT EXPORT" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Projet : GGJ2026" -ForegroundColor White
Write-Host "Chemin : $ProjectPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Plateformes a exporter :" -ForegroundColor White

$platformesToExport = @()
if (-not $SkipWeb) { 
    Write-Host "  - Web (HTML5) - Jouable dans le navigateur" -ForegroundColor Green
    $platformesToExport += "Web"
}
if (-not $SkipWindows) { 
    Write-Host "  - Windows (telechargeable)" -ForegroundColor Green
    $platformesToExport += "Windows"
}
if (-not $SkipLinux) { 
    Write-Host "  - Linux (telechargeable)" -ForegroundColor Green
    $platformesToExport += "Linux"
}
if (-not $SkipMac) { 
    Write-Host "  - macOS (telechargeable)" -ForegroundColor Green
    $platformesToExport += "macOS"
}

if ($platformesToExport.Count -eq 0) {
    Write-Host "Aucune plateforme selectionnee !" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "IMPORTANT : Avez-vous installe les templates d'export Godot ?" -ForegroundColor Yellow
Write-Host "  (Editeur > Gerer les modeles d'exportation > Telecharger et installer)" -ForegroundColor Gray
Write-Host ""
$confirmation = Read-Host "Continuer l'export ? (O/N)"

if ($confirmation -ne "O" -and $confirmation -ne "o" -and $confirmation -ne "Y" -and $confirmation -ne "y") {
    Write-Host ""
    Write-Host "Export annule." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Demarrage des exports..." -ForegroundColor Cyan
Write-Host ""

# Fonction pour exporter une plateforme
function Export-Platform {
    param(
        [string]$PresetName,
        [string]$OutputPath,
        [string]$DisplayName
    )
    
    Write-Host "Exportation : $DisplayName..." -ForegroundColor Yellow
    
    try {
        # Creer le dossier de sortie s'il n'existe pas
        $outputDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        # Exporter
        & $GodotPath --headless --export-release $PresetName $OutputPath --path $ProjectPath 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  $DisplayName exporte avec succes" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  Echec de l'export $DisplayName" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  Erreur lors de l'export $DisplayName : $_" -ForegroundColor Red
        return $false
    }
}

$successCount = 0
$totalCount = 0

# Export Web
if (-not $SkipWeb) {
    $totalCount++
    $webPath = Join-Path $ProjectPath "publish\web\index.html"
    if (Export-Platform "Web" $webPath "Web (HTML5)") {
        $successCount++
    }
}

# Export Windows
if (-not $SkipWindows) {
    $totalCount++
    $windowsPath = Join-Path $ProjectPath "publish\windows\GGJ2026.exe"
    if (Export-Platform "Windows Desktop" $windowsPath "Windows") {
        $successCount++
        
        # Creer un ZIP pour Windows
        Write-Host "  Creation de l'archive Windows..." -ForegroundColor Yellow
        $windowsDir = Join-Path $ProjectPath "publish\windows"
        $zipPath = Join-Path $ProjectPath "publish\GGJ2026-Windows.zip"
        
        if (Test-Path $zipPath) {
            Remove-Item $zipPath -Force
        }
        
        Compress-Archive -Path "$windowsDir\*" -DestinationPath $zipPath -Force
        Write-Host "  Archive creee : publish/GGJ2026-Windows.zip" -ForegroundColor Green
    }
}

# Export Linux
if (-not $SkipLinux) {
    $totalCount++
    $linuxPath = Join-Path $ProjectPath "publish\linux\GGJ2026.x86_64"
    if (Export-Platform "Linux" $linuxPath "Linux") {
        $successCount++
        
        # Creer un ZIP pour Linux
        Write-Host "  Creation de l'archive Linux..." -ForegroundColor Yellow
        $linuxDir = Join-Path $ProjectPath "publish\linux"
        $zipPath = Join-Path $ProjectPath "publish\GGJ2026-Linux.zip"
        
        if (Test-Path $zipPath) {
            Remove-Item $zipPath -Force
        }
        
        Compress-Archive -Path "$linuxDir\*" -DestinationPath $zipPath -Force
        Write-Host "  Archive creee : publish/GGJ2026-Linux.zip" -ForegroundColor Green
    }
}

# Export macOS
if (-not $SkipMac) {
    $totalCount++
    $macPath = Join-Path $ProjectPath "publish\mac\GGJ2026.zip"
    if (Export-Platform "macOS" $macPath "macOS") {
        $successCount++
    }
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Resume de l'export" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "$successCount/$totalCount plateformes exportees avec succes" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "Fichiers prets pour itch.io dans le dossier publish/ :" -ForegroundColor Cyan
    Write-Host ""
    
    $webIndexPath = Join-Path $ProjectPath "publish\web\index.html"
    if (-not $SkipWeb -and (Test-Path $webIndexPath)) {
        Write-Host "  - Web (HTML5) : publish/web/" -ForegroundColor White
        Write-Host "    (Zipper le contenu du dossier web/ pour upload)" -ForegroundColor Gray
    }
    
    $winZipPath = Join-Path $ProjectPath "publish\GGJ2026-Windows.zip"
    if (-not $SkipWindows -and (Test-Path $winZipPath)) {
        Write-Host "  - Windows : publish/GGJ2026-Windows.zip" -ForegroundColor White
    }
    
    $linuxZipPath = Join-Path $ProjectPath "publish\GGJ2026-Linux.zip"
    if (-not $SkipLinux -and (Test-Path $linuxZipPath)) {
        Write-Host "  - Linux : publish/GGJ2026-Linux.zip" -ForegroundColor White
    }
    
    $macZipPath = Join-Path $ProjectPath "publish\mac\GGJ2026.zip"
    if (-not $SkipMac -and (Test-Path $macZipPath)) {
        Write-Host "  - macOS : publish/mac/GGJ2026.zip" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "PROCHAINES ETAPES - Publication sur itch.io" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Si export Web reussi
    if (-not $SkipWeb -and (Test-Path $webIndexPath)) {
        Write-Host "ETAPE 1 : Creer l'archive Web pour itch.io" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Executez cette commande :" -ForegroundColor White
        Write-Host "  Compress-Archive -Path `"ggj-2026\publish\web\*`" -DestinationPath `"GGJ2026-Web.zip`" -Force" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "ETAPE 2 : Uploader sur itch.io" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  1. Allez sur https://itch.io/game/new" -ForegroundColor White
        Write-Host "  2. Title : GGJ2026 (ou votre choix)" -ForegroundColor White
        Write-Host "  3. Kind of project : HTML" -ForegroundColor White
        Write-Host "  4. Dans Uploads :" -ForegroundColor White
        Write-Host "     - Uploadez GGJ2026-Web.zip" -ForegroundColor Gray
        Write-Host "     - Cochez : This file will be played in the browser" -ForegroundColor Gray
        Write-Host "     - Viewport dimensions : 1280 x 720" -ForegroundColor Gray
        Write-Host "  5. Ajoutez description et screenshots" -ForegroundColor White
        Write-Host "  6. Save & view page" -ForegroundColor White
        Write-Host ""
        Write-Host "  Votre jeu sera jouable directement dans le navigateur !" -ForegroundColor Green
    }
    
    # Si exports telechargeable
    $hasDownloadable = (-not $SkipWindows -and (Test-Path $winZipPath)) -or 
                       (-not $SkipLinux -and (Test-Path $linuxZipPath)) -or 
                       (-not $SkipMac -and (Test-Path $macZipPath))
    
    if ($hasDownloadable) {
        Write-Host ""
        Write-Host "VERSIONS TELECHARGEABLE :" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Dans itch.io, ajoutez aussi les fichiers telechargeable :" -ForegroundColor White
        if (-not $SkipWindows -and (Test-Path $winZipPath)) {
            Write-Host "  - GGJ2026-Windows.zip (cochez Windows)" -ForegroundColor Gray
        }
        if (-not $SkipLinux -and (Test-Path $linuxZipPath)) {
            Write-Host "  - GGJ2026-Linux.zip (cochez Linux)" -ForegroundColor Gray
        }
        if (-not $SkipMac -and (Test-Path $macZipPath)) {
            Write-Host "  - GGJ2026-Mac.zip (cochez macOS)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pour plus de details, consultez ITCH_IO_GUIDE.md" -ForegroundColor Gray
} else {
    Write-Host "Aucun export reussi." -ForegroundColor Red
    Write-Host ""
    Write-Host "VERIFICATIONS :" -ForegroundColor Yellow
    Write-Host "  1. Les templates d'export sont installes ?" -ForegroundColor White
    Write-Host "     Ouvrez Godot > Editeur > Gerer les modeles d'exportation" -ForegroundColor Gray
    Write-Host "  2. Le fichier export_presets.cfg existe dans ggj-2026/ ?" -ForegroundColor White
    Write-Host "  3. Essayez d'exporter manuellement depuis Godot pour voir l'erreur" -ForegroundColor White
}

Write-Host ""
