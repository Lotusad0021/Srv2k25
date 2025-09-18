# Vérifier si le DHCP est déjà autorisé dans AD
$dhcpAuthorized = Get-DhcpServerInDC | Where-Object { $_.DnsName -eq "SRV-DC.emica.lan" -or $_.IPAddress -eq "10.10.10.2" }

if (-not $dhcpAuthorized) {
    # Autoriser le serveur DHCP dans Active Directory seulement s'il n'est pas déjà autorisé
    Write-Host "Autorisation du serveur DHCP dans Active Directory..."
    Add-DhcpServerInDC -DnsName "SRV-DC.emica.lan" -IPAddress "10.10.10.2"
} else {
    Write-Host "Le serveur DHCP est déjà autorisé dans AD. Aucune action nécessaire."
}

# Configurer les mises à jour DNS dynamiques pour DHCP (optionnel)
Set-DhcpServerv4DnsSetting -ComputerName "SRV-DC.emica.lan" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True -ErrorAction SilentlyContinue

# Vérification post-action
Write-Host " "
Write-Host "État d'autorisation du DHCP."
Get-DhcpServerInDC

# Lancer la console DHCP
Start-Process DhcpMgmt.msc
