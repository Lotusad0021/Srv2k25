#Requires -Version 5.1
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    View Active Directory Organizational Units and Users for Nordika Solutions
    
.DESCRIPTION
    This script provides various commands to view the OU structure and users in Active Directory.
    Useful for verification after running the Import-NordikaEmployees.ps1 script.
    
.PARAMETER Domain
    The domain name (e.g., nordika.local)
    
.PARAMETER ShowOUs
    Display all Organizational Units
    
.PARAMETER ShowUsers
    Display all users in the domain
    
.PARAMETER ShowUsersByOU
    Display users grouped by their Organizational Unit
    
.PARAMETER ShowDepartments
    Display unique departments from user accounts
    
.PARAMETER ExportToCSV
    Export results to CSV file
    
.EXAMPLE
    .\View-NordikaAD.ps1 -Domain "nordika.local" -ShowOUs
    
.EXAMPLE
    .\View-NordikaAD.ps1 -Domain "nordika.local" -ShowUsers -ExportToCSV
    
.EXAMPLE
    .\View-NordikaAD.ps1 -Domain "nordika.local" -ShowUsersByOU
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,
    
    [switch]$ShowOUs,
    [switch]$ShowUsers,
    [switch]$ShowUsersByOU,
    [switch]$ShowDepartments,
    [switch]$ExportToCSV
)

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✓ Active Directory module loaded successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to load Active Directory module: $($_.Exception.Message)"
    exit 1
}

# Get domain DN
$domainDN = "DC=" + $Domain.Replace('.', ',DC=')
Write-Host "=== Nordika Solutions AD Viewer ===" -ForegroundColor Magenta
Write-Host "Domain: $Domain ($domainDN)" -ForegroundColor White

if ($ShowOUs) {
    Write-Host "`n=== Organizational Units ===" -ForegroundColor Cyan
    try {
        $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $domainDN | Sort-Object DistinguishedName
        
        foreach ($OU in $OUs) {
            $level = ($OU.DistinguishedName.Split(',') | Where-Object { $_ -like "OU=*" }).Count - 1
            $indent = "  " * $level
            Write-Host "$indent$($OU.Name)" -ForegroundColor White
            Write-Host "$indent  Path: $($OU.DistinguishedName)" -ForegroundColor Gray
        }
        
        Write-Host "`nTotal OUs found: $($OUs.Count)" -ForegroundColor Green
        
        if ($ExportToCSV) {
            $OUs | Select-Object Name, DistinguishedName, Description | Export-Csv -Path "NordikaOUs_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
            Write-Host "OUs exported to CSV file" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to retrieve OUs: $($_.Exception.Message)"
    }
}

if ($ShowUsers) {
    Write-Host "`n=== User Accounts ===" -ForegroundColor Cyan
    try {
        $Users = Get-ADUser -Filter * -SearchBase $domainDN -Properties Department, Title, Manager, EmailAddress | Sort-Object Name
        
        foreach ($User in $Users) {
            Write-Host "User: $($User.Name)" -ForegroundColor White
            Write-Host "  Username: $($User.SamAccountName)" -ForegroundColor Gray
            Write-Host "  Email: $($User.EmailAddress)" -ForegroundColor Gray
            Write-Host "  Department: $($User.Department)" -ForegroundColor Gray
            Write-Host "  Title: $($User.Title)" -ForegroundColor Gray
            Write-Host "  OU: $($User.DistinguishedName.Split(',')[1..-1] -join ',')" -ForegroundColor Gray
            if ($User.Manager) {
                $managerName = (Get-ADUser $User.Manager).Name
                Write-Host "  Manager: $managerName" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        Write-Host "Total users found: $($Users.Count)" -ForegroundColor Green
        
        if ($ExportToCSV) {
            $Users | Select-Object Name, SamAccountName, EmailAddress, Department, Title, @{Name='OU';Expression={$_.DistinguishedName.Split(',')[1..-1] -join ','}}, @{Name='Manager';Expression={if($_.Manager) {(Get-ADUser $_.Manager).Name}}} | Export-Csv -Path "NordikaUsers_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
            Write-Host "Users exported to CSV file" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to retrieve users: $($_.Exception.Message)"
    }
}

if ($ShowUsersByOU) {
    Write-Host "`n=== Users by Organizational Unit ===" -ForegroundColor Cyan
    try {
        $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $domainDN | Sort-Object DistinguishedName
        
        foreach ($OU in $OUs) {
            $Users = Get-ADUser -Filter * -SearchBase $OU.DistinguishedName -SearchScope OneLevel | Sort-Object Name
            if ($Users.Count -gt 0) {
                Write-Host "`nOU: $($OU.Name)" -ForegroundColor Yellow
                Write-Host "Path: $($OU.DistinguishedName)" -ForegroundColor Gray
                Write-Host "Users ($($Users.Count)):" -ForegroundColor White
                foreach ($User in $Users) {
                    Write-Host "  - $($User.Name) ($($User.SamAccountName))" -ForegroundColor White
                }
            }
        }
    } catch {
        Write-Error "Failed to retrieve users by OU: $($_.Exception.Message)"
    }
}

if ($ShowDepartments) {
    Write-Host "`n=== Departments ===" -ForegroundColor Cyan
    try {
        $Users = Get-ADUser -Filter * -SearchBase $domainDN -Properties Department | Where-Object { $_.Department }
        $Departments = $Users | Group-Object Department | Sort-Object Name
        
        foreach ($Dept in $Departments) {
            Write-Host "Department: $($Dept.Name)" -ForegroundColor Yellow
            Write-Host "  User Count: $($Dept.Count)" -ForegroundColor White
            Write-Host "  Users:" -ForegroundColor Gray
            foreach ($User in ($Dept.Group | Sort-Object Name)) {
                Write-Host "    - $($User.Name)" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        Write-Host "Total departments: $($Departments.Count)" -ForegroundColor Green
        
        if ($ExportToCSV) {
            $DeptStats = $Departments | Select-Object @{Name='Department';Expression={$_.Name}}, @{Name='UserCount';Expression={$_.Count}}
            $DeptStats | Export-Csv -Path "NordikaDepartments_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
            Write-Host "Department statistics exported to CSV file" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to retrieve departments: $($_.Exception.Message)"
    }
}

Write-Host "`nScript completed at $(Get-Date)" -ForegroundColor White