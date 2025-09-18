#Vérification et installation des fonctionnalités si elles ne sont pas déjà installées
$Fonctionnalites = @(
    "AD-Domain-Services",
    "DNS", 
    "DHCP"
)

$FonctionnalitesAInstaller = @()

foreach ($Fonctionnalite in $Fonctionnalites) {
    $EtatFonctionnalite = Get-WindowsFeature -Name $Fonctionnalite
    if ($EtatFonctionnalite.InstallState -ne "Installed") {
        Write-Host "La fonctionnalité $Fonctionnalite n'est pas installée. Ajoutée à la liste d'installation." -ForegroundColor Yellow
        $FonctionnalitesAInstaller += $Fonctionnalite
    } else {
        Write-Host "La fonctionnalité $Fonctionnalite est déjà installée." -ForegroundColor Green
    }
}

if ($FonctionnalitesAInstaller.Count -gt 0) {
    Write-Host "`nInstallation des fonctionnalités manquantes..." -ForegroundColor Cyan
    Install-WindowsFeature -Name $FonctionnalitesAInstaller -IncludeManagementTools
    
    #Message de confirmation pour le redémarrage
    $Confirmation = Read-Host "`nAppuyez sur Entrée, l'ordinateur va redémarrer et compléter l'installation. Pour annuler, tapez 'A'"

    if ($Confirmation -ne 'A' -and $Confirmation -ne 'a') {
        Write-Host "Redémarrage en cours..." -ForegroundColor Red
        Restart-Computer -Force
    } else {
        Write-Host "`nInstallation terminée. Vous devrez redémarrer manuellement pour finaliser." -ForegroundColor Yellow
    }
} else {
    Write-Host "`nToutes les fonctionnalités sont déjà installées. Aucune action nécessaire." -ForegroundColor Green
}