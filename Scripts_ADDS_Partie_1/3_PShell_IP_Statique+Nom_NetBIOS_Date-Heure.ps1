#Définition des variables
$NouveauNomNetBios = 'SRV-DC'
$NomInterface = "Ethernet"
$AdresseIP = "10.10.10.2"
$NetMaskCIDR = 24
$Passerelle = "10.10.10.1"
$ServeursDNS = @("10.10.10.2", "1.1.1.1", "8.8.8.8", "8.8.4.4")

#Ajustement du fuseau horaire
Set-TimeZone -Id "Eastern Standard Time"
Get-TimeZone

#Vérification si le nom d'ordinateur est déjà configuré
$NomActuel = $env:COMPUTERNAME
if ($NomActuel -eq $NouveauNomNetBios) {
    Write-Host "Le nom d'ordinateur est déjà configuré sur '$NouveauNomNetBios' - Aucune action nécessaire."
    $NomDejaConfigure = $true
} else {
    Write-Host "Le nom d'ordinateur actuel est '$NomActuel', il sera changé pour '$NouveauNomNetBios'"
    $NomDejaConfigure = $false
}

#Vérification si l'adresse IP est déjà configurée
$ConfigIPActuelle = Get-NetIPAddress -InterfaceAlias $NomInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue
$IPDejaConfiguree = $false

if ($ConfigIPActuelle) {
    #Vérifier l'adresse IP et le masque
    if ($ConfigIPActuelle.IPAddress -eq $AdresseIP -and $ConfigIPActuelle.PrefixLength -eq $NetMaskCIDR) {
        Write-Host "L'adresse IP $AdresseIP/$NetMaskCIDR est déjà configurée sur l'interface '$NomInterface'"
        
        #Vérifier la passerelle par défaut
        $RouteDefaut = Get-NetRoute -InterfaceAlias $NomInterface -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
        if ($RouteDefaut -and $RouteDefaut.NextHop -eq $Passerelle) {
            Write-Host "La passerelle par défaut est déjà configurée sur $Passerelle"
            
            #Vérifier les serveurs DNS
            $DNSActuels = (Get-DnsClientServerAddress -InterfaceAlias $NomInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($DNSActuels) {
                #Comparer les tableaux DNS (sans tenir compte de l'ordre)
                $Difference = Compare-Object $DNSActuels $ServeursDNS
                if (-not $Difference) {
                    Write-Host "Les serveurs DNS sont déjà configurés avec les mêmes valeurs"
                    $IPDejaConfiguree = $true
                } else {
                    Write-Host "Les serveurs DNS actuels diffèrent de la configuration souhaitée"
                }
            }
        }
    }
}

#Si tout est déjà configuré, ne rien faire
if ($NomDejaConfigure -and $IPDejaConfiguree) {
    Write-Host "`nLa configuration est déjà appliquée - Aucune action nécessaire."
    exit
}

#Configuration réseau si nécessaire
if (-not $IPDejaConfiguree) {
    Write-Host "`nApplication de la configuration réseau..."
    
    #Suppression de la configuration IP existante (s'il y en a une différente)
    try {
        Remove-NetIPAddress -InterfaceAlias $NomInterface -Confirm:$false -ErrorAction Stop
        Write-Host "Ancienne configuration IP supprimée"
    } catch {
        Write-Host "Aucune ancienne configuration IP à supprimer ou erreur lors de la suppression"
    }

    #Attribution de l'adresse IP statique
    try {
        New-NetIPAddress -InterfaceAlias $NomInterface `
                         -IPAddress $AdresseIP `
                         -PrefixLength $NetMaskCIDR `
                         -DefaultGateway $Passerelle -ErrorAction Stop
        Write-Host "Nouvelle adresse IP configurée: $AdresseIP/$NetMaskCIDR"
    } catch {
        Write-Host "Erreur lors de la configuration de l'adresse IP: $($_.Exception.Message)"
    }

    #Configuration des serveurs DNS
    try {
        Set-DnsClientServerAddress -InterfaceAlias $NomInterface -ServerAddresses $ServeursDNS -ErrorAction Stop
        Write-Host "Serveurs DNS configurés: $($ServeursDNS -join ', ')"
    } catch {
        Write-Host "Erreur lors de la configuration des serveurs DNS: $($_.Exception.Message)"
    }

    Write-Host "`nLa configuration réseau a été appliquée avec succès."
}

#Renommer l'ordinateur si nécessaire
if (-not $NomDejaConfigure) {
    try {
        Rename-Computer -NewName $NouveauNomNetBios -Force -ErrorAction Stop
        Write-Host "Le nom d'ordinateur a été changé pour '$NouveauNomNetBios'"
        
        #Demande de redémarrage
        $QuestionReponse = Read-Host "`nSouhaitez-vous redémarrer maintenant ? (Oui/Non)"

        if ($QuestionReponse -match "^[Oo]$") {
            Write-Host "`nRedémarrage en cours..."
            Restart-Computer -Force
        } else {
            Write-Host "`nLe redémarrage a été annulé."
            Write-Host "Le nouveau nom [$NouveauNomNetBios] sera appliqué au prochain démarrage."
        }
    } catch {
        Write-Host "Erreur lors du changement de nom: $($_.Exception.Message)"
    }
} else {
    Write-Host "`nAucun redémarrage nécessaire - la configuration est déjà à jour."
}