#Variables
$NomEtendueDHCP = "Emica"
$IdentifiantEtendueDHCP = "10.10.10.0"
$MasqueSousReseau = "255.255.255.0"
$DebutDistribution = "10.10.10.1"
$FinDistribution = "10.10.10.254"
$DebutExclusion = "10.10.10.1"
$FinExclusion = "10.10.10.10"
$Passerelle = "10.10.10.1"
$ServeurDNS1 = "10.10.10.2"
$ServeurDNS2 = "1.1.1.1"
$SuffixeDNS = "emica.lan"
$DureeBailJours = 7

#Vérification si l'étendue existe déjà ou pas
$VerifEtendue = Get-DhcpServerv4Scope -ScopeId $IdentifiantEtendueDHCP -ErrorAction SilentlyContinue

if ($VerifEtendue) {
    Write-Host "L'étendue $IdentifiantEtendueDHCP existe déjà." -ForegroundColor Yellow
    Read-Host "Aucune action nécessaire. PRESSEZ LA TOUCHE [Entrée] POUR QUITTER"
    exit
} else {
	#Création du scope DHCP
	Add-DhcpServerv4Scope -Name $NomEtendueDHCP -StartRange $DebutDistribution -EndRange $FinDistribution -SubnetMask $MasqueSousReseau -State Active
	
	#Ajout de la plage d'exclusion
	Add-DhcpServerv4ExclusionRange -ScopeId $IdentifiantEtendueDHCP -StartRange $DebutExclusion -EndRange $FinExclusion
	
	#Configuration de la passerelle (routeur)
	Set-DhcpServerv4OptionValue -ScopeId $IdentifiantEtendueDHCP -Router $Passerelle
	
	#Configuration des serveurs DNS et du suffixe DNS
	Set-DhcpServerv4OptionValue -ScopeId $IdentifiantEtendueDHCP -DnsServer $ServeurDNS1, $ServeurDNS2 -DnsDomain $SuffixeDNS -Force
	
	#Configuration de la durée du bail
	Set-DhcpServerv4Scope -ScopeId $IdentifiantEtendueDHCP -LeaseDuration ([TimeSpan]::FromDays($DureeBailJours))
}
