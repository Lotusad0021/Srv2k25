Write-Host "`n VOICI LA LISTE DES ROLES ET FONCTIONNALITÉS INSTALLÉES"
Write-Host " SUR [$Env:ComputerName]"
Get-WindowsFeature | Where-Object { $_.Installed -eq $True }