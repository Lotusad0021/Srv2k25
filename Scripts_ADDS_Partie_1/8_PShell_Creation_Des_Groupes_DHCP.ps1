# Script de création des groupes de sécurité pour l'administration DHCP
# A exécuter sur un contrôleur de domaine ou une machine avec les outils RSAT

# --- Détection de la langue du système d'exploitation ---
$LangueSysteme = (Get-Culture).Name
if ($LangueSysteme -like "fr-*") {
    $Langue = "FR"
    Write-Host "Langue du système détectée: Français ($LangueSysteme)" -ForegroundColor Cyan
} else {
    $Langue = "EN"
    Write-Host "Langue du système détectée: Anglais ou autre ($LangueSysteme)" -ForegroundColor Cyan
}

# --- Définition des noms de groupes selon la langue ---
if ($Langue -eq "FR") {
    $NomAdminDHCP = "Administrateurs DHCP"
    $NomUtilisateursDHCP = "Utilisateurs DHCP"
} else {
    $NomAdminDHCP = "DHCP Administrators"
    $NomUtilisateursDHCP = "DHCP Users"
}

# --- Chemin vers le conteneur Users ---
$NomDistinctifDomaine = (Get-ADDomain).DistinguishedName
$CheminUsers = "CN=Users,$NomDistinctifDomaine"

# --- Définition des groupes à créer ---
$GroupesACreer = @(
    @{
        Nom = $NomAdminDHCP
        Description = "Membres de ce groupe peuvent administrer le service DHCP (étendues, options, baux)"
    },
    @{
        Nom = $NomUtilisateursDHCP
        Description = "Membres de ce groupe peuvent visualiser (lecture seule) la configuration du service DHCP"
    }
)

# --- Création des groupes ---
Write-Host "Début de la création des groupes de sécurité DHCP dans le conteneur Users..." -ForegroundColor Cyan
Write-Host "Emplacement: $CheminUsers" -ForegroundColor Cyan

foreach ($Groupe in $GroupesACreer) {
    $NomGroupe = $Groupe.Nom
    if (-not (Get-ADGroup -Filter "Name -eq '$NomGroupe'")) {
        Write-Host "Création du groupe '$NomGroupe'..." -ForegroundColor Green
        New-ADGroup `
            -Name $NomGroupe `
            -DisplayName $NomGroupe `
            -Description $Groupe.Description `
            -GroupCategory Security `
            -GroupScope Global `
            -Path $CheminUsers
        Write-Host "Groupe '$NomGroupe' créé avec succès dans le conteneur Users." -ForegroundColor Green
    } else {
        Write-Host "Le groupe '$NomGroupe' existe déjà. Aucune action n'est nécessaire." -ForegroundColor Yellow
    }
    Write-Host "---"
}

# --- Message de fin ---
Write-Host "Opération terminée." -ForegroundColor Cyan
Write-Host "N'oubliez pas de déléguer les autorisations sur le serveur DHCP lui-même." -ForegroundColor Cyan

if ($Langue -eq "FR") {
    Write-Host "Dans le Gestionnaire DHCP, ajoutez ces groupes avec les autorisations appropriées." -ForegroundColor White
} else {
    Write-Host "In DHCP Manager, add these groups with the appropriate permissions." -ForegroundColor White
}

Write-Host " "
Write-Host "Pour déléguer les autorisations sur le serveur DHCP lui-même:" -ForegroundColor Cyan
Write-Host "1. Ouvrez le Gestionnaire DHCP" -ForegroundColor White
Write-Host "2. Clic-droit sur le serveur -> 'Déléguer l'administration...'" -ForegroundColor White
Write-Host "3. Ajoutez le groupe [$NomAdminDHCP] avec le rôle 'Accès total'." -ForegroundColor White
Write-Host "4. Ajoutez le groupe [$NomUtilisateursDHCP] avec le rôle 'Lecture'." -ForegroundColor White
Write-Host " "