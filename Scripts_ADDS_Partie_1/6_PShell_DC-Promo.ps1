##Importer le module ADDSDeployment
Import-Module ADDSDeployment

##Promouvoir le serveur en tant que contrôleur de domaine
##Contexte: nouvelle forêt et un nouveau domaine.
Install-ADDSForest `
    -DomainName "emica.lan" `
    -DomainNetbiosName "EMICA" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "Annexe123!" -AsPlainText -Force) `
    -InstallDNS:$true `
    -NoRebootOnCompletion

##Message de confirmation de redémarrage nécessaire pour finaliser la promotion du contrôleur de domaine.
$confirmation = Read-Host "Appuyez sur Entrée, l'ordinateur va redémarrer et compléter l'installation. Pour annuler, tapez 'A'"

if ($confirmation -ne 'A' -and $confirmation -ne 'a') {
    #Redémarrage
    Restart-Computer -Force
} else {
    Write-Host "`nVous devrez redémarrer manuellement" -ForegroundColor Yellow
}
