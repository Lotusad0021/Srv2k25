#Requires -Version 5.1
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Import Nordika Solutions employee data into Windows Server 2025
    
.DESCRIPTION
    This script imports employee data from a CSV file and creates user accounts in Active Directory,
    sets up organizational units, and configures user properties based on the organizational structure.
    
.PARAMETER CSVPath
    Path to the CSV file containing employee data
    
.PARAMETER Domain
    The domain name for the organization (e.g., nordika.local)
    
.PARAMETER OUBasePath
    Base Distinguished Name for Organizational Units (e.g., "OU=Employees,DC=nordika,DC=local")
    
.PARAMETER DefaultPassword
    Default password for new user accounts (will be set to change at next logon)
    
.PARAMETER CreateOUs
    Switch to create Organizational Units based on department structure
    
.PARAMETER CreateUsers
    Switch to create user accounts
    
.PARAMETER WhatIf
    Show what would be done without actually making changes
    
.EXAMPLE
    .\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "nordika.local" -CreateOUs -CreateUsers
    
.EXAMPLE
    .\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "nordika.local" -WhatIf
    
.NOTES
    Author: IT Administrator
    Date: September 12, 2025
    Requires: Windows Server 2025, Active Directory PowerShell Module
    
    Make sure to run this script with appropriate permissions (Domain Admin or equivalent)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_})]
    [string]$CSVPath,
    
    [Parameter(Mandatory = $true)]
    [string]$Domain,
    
    [string]$OUBasePath = "OU=Employees,DC=$($Domain.Replace('.', ',DC='))",
    
    [SecureString]$DefaultPassword,
    
    [switch]$CreateOUs,
    
    [switch]$CreateUsers,
    
    [switch]$WhatIf
)

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✓ Active Directory module loaded successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to load Active Directory module: $($_.Exception.Message)"
    Write-Host "Please ensure you're running this on a domain controller or have RSAT installed" -ForegroundColor Yellow
    exit 1
}

# Function to create Organizational Units
function New-DepartmentOU {
    param(
        [string]$Name,
        [string]$ParentPath,
        [switch]$WhatIf
    )
    
    $OUPath = "OU=$Name,$ParentPath"
    
    try {
        $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $ParentPath -SearchScope OneLevel -ErrorAction SilentlyContinue
        
        if (-not $existingOU) {
            if ($WhatIf) {
                Write-Host "WHATIF: Would create OU: $OUPath" -ForegroundColor Cyan
            } else {
                New-ADOrganizationalUnit -Name $Name -Path $ParentPath -Description "Department: $Name" -ProtectedFromAccidentalDeletion $true
                Write-Host "✓ Created OU: $OUPath" -ForegroundColor Green
            }
        } else {
            Write-Host "→ OU already exists: $OUPath" -ForegroundColor Yellow
        }
        
        return $OUPath
    } catch {
        Write-Warning "Failed to create OU '$Name': $($_.Exception.Message)"
        return $ParentPath
    }
}

# Function to generate username
function Get-Username {
    param(
        [string]$FullName,
        [string]$Domain
    )
    
    # Remove accents and special characters, convert to lowercase
    $name = $FullName -replace '[àáâãäå]','a' -replace '[èéêë]','e' -replace '[ìíîï]','i' -replace '[òóôõö]','o' -replace '[ùúûü]','u' -replace '[ñ]','n' -replace '[ç]','c'
    $name = $name -replace '[^a-zA-Z\s-]','' -replace '\s+','' -replace '-',''
    
    $parts = $FullName.Split(' ')
    if ($parts.Count -ge 2) {
        $firstName = $parts[0].Substring(0, [Math]::Min(3, $parts[0].Length)).ToLower()
        $lastName = $parts[-1].Substring(0, [Math]::Min(5, $parts[-1].Length)).ToLower()
        $username = "$firstName$lastName"
    } else {
        $username = $name.Substring(0, [Math]::Min(8, $name.Length)).ToLower()
    }
    
    # Remove accents from username
    $username = $username -replace '[àáâãäå]','a' -replace '[èéêë]','e' -replace '[ìíîï]','i' -replace '[òóôõö]','o' -replace '[ùúûü]','u' -replace '[ñ]','n' -replace '[ç]','c'
    
    return $username
}

# Function to create user account
function New-EmployeeUser {
    param(
        [PSCustomObject]$Employee,
        [string]$OUPath,
        [SecureString]$Password,
        [string]$Domain,
        [switch]$WhatIf
    )
    
    $username = Get-Username -FullName $Employee.Name -Domain $Domain
    $userPrincipalName = "$username@$Domain"
    $email = "$username@$Domain"
    
    # Check if user already exists
    try {
        $existingUser = Get-ADUser -Identity $username -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Host "→ User already exists: $username" -ForegroundColor Yellow
            return
        }
    } catch {
        # User doesn't exist, proceed with creation
    }
    
    $userParams = @{
        Name = $Employee.Name
        SamAccountName = $username
        UserPrincipalName = $userPrincipalName
        EmailAddress = $email
        DisplayName = $Employee.Name
        GivenName = $Employee.Name.Split(' ')[0]
        Surname = $Employee.Name.Split(' ')[-1]
        Title = $Employee.Position
        Department = $Employee.Department
        Company = "Nordika Solutions"
        Path = $OUPath
        AccountPassword = $Password
        Enabled = $true
        ChangePasswordAtLogon = $true
        PasswordNeverExpires = $false
        CannotChangePassword = $false
    }
    
    # Add manager if specified
    if ($Employee.Reports_To -and $Employee.Reports_To -ne $Employee.Name) {
        $managerUsername = Get-Username -FullName $Employee.Reports_To -Domain $Domain
        try {
            $manager = Get-ADUser -Identity $managerUsername -ErrorAction SilentlyContinue
            if ($manager) {
                $userParams.Manager = $manager.DistinguishedName
            }
        } catch {
            Write-Verbose "Manager not found: $managerUsername"
        }
    }
    
    if ($WhatIf) {
        Write-Host "WHATIF: Would create user: $username ($($Employee.Name)) in $OUPath" -ForegroundColor Cyan
    } else {
        try {
            New-ADUser @userParams
            Write-Host "✓ Created user: $username ($($Employee.Name))" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to create user '$username': $($_.Exception.Message)"
        }
    }
}

# Main script execution
Write-Host "=== Nordika Solutions Employee Import Script ===" -ForegroundColor Magenta
Write-Host "Starting import process..." -ForegroundColor White

# Validate CSV file
Write-Host "`nValidating CSV file..." -ForegroundColor White
try {
    $employees = Import-Csv -Path $CSVPath -ErrorAction Stop
    Write-Host "✓ Successfully loaded $($employees.Count) employee records" -ForegroundColor Green
} catch {
    Write-Error "Failed to read CSV file: $($_.Exception.Message)"
    exit 1
}

# Validate required columns
$requiredColumns = @('Name', 'Position', 'Department', 'Sub_Department', 'Reports_To')
$csvColumns = $employees[0].PSObject.Properties.Name
$missingColumns = $requiredColumns | Where-Object { $_ -notin $csvColumns }

if ($missingColumns) {
    Write-Error "Missing required columns in CSV: $($missingColumns -join ', ')"
    exit 1
}

# Set default password if not provided
if (-not $DefaultPassword) {
    $DefaultPassword = ConvertTo-SecureString "NordikaTemp123!" -AsPlainText -Force
    Write-Host "→ Using default password (users will be required to change at first logon)" -ForegroundColor Yellow
}

# Create base OU structure
if ($CreateOUs) {
    Write-Host "`nCreating Organizational Unit structure..." -ForegroundColor White
    
    # Create base Employees OU if it doesn't exist
    try {
        $baseOUName = $OUBasePath.Split(',')[0].Replace('OU=', '')
        $parentPath = $OUBasePath.Substring($OUBasePath.IndexOf(',') + 1)
        
        $baseOU = Get-ADOrganizationalUnit -Filter "Name -eq '$baseOUName'" -SearchBase $parentPath -SearchScope OneLevel -ErrorAction SilentlyContinue
        if (-not $baseOU) {
            if ($WhatIf) {
                Write-Host "WHATIF: Would create base OU: $OUBasePath" -ForegroundColor Cyan
            } else {
                New-ADOrganizationalUnit -Name $baseOUName -Path $parentPath -Description "Nordika Solutions Employees" -ProtectedFromAccidentalDeletion $true
                Write-Host "✓ Created base OU: $OUBasePath" -ForegroundColor Green
            }
        }
    } catch {
        Write-Warning "Could not create base OU: $($_.Exception.Message)"
    }
    
    # Get unique departments and create OUs
    $departments = $employees | Where-Object { $_.Department -and $_.Department.Trim() -ne '' } | Select-Object -ExpandProperty Department -Unique
    $departmentOUs = @{}
    
    foreach ($dept in $departments) {
        $deptOU = New-DepartmentOU -Name $dept -ParentPath $OUBasePath -WhatIf:$WhatIf
        $departmentOUs[$dept] = $deptOU
        
        # Create sub-department OUs
        $subDepts = $employees | Where-Object { $_.Department -eq $dept -and $_.Sub_Department -and $_.Sub_Department.Trim() -ne '' } | Select-Object -ExpandProperty Sub_Department -Unique
        foreach ($subDept in $subDepts) {
            New-DepartmentOU -Name $subDept -ParentPath $deptOU -WhatIf:$WhatIf | Out-Null
        }
    }
}

# Create user accounts
if ($CreateUsers) {
    Write-Host "`nCreating user accounts..." -ForegroundColor White
    
    $userCount = 0
    $errorCount = 0
    
    foreach ($employee in $employees) {
        try {
            # Determine OU path
            $targetOU = $OUBasePath
            
            if ($employee.Department -and $employee.Department.Trim() -ne '') {
                $deptOU = "OU=$($employee.Department),$OUBasePath"
                
                if ($employee.Sub_Department -and $employee.Sub_Department.Trim() -ne '') {
                    $targetOU = "OU=$($employee.Sub_Department),$deptOU"
                } else {
                    $targetOU = $deptOU
                }
            }
            
            New-EmployeeUser -Employee $employee -OUPath $targetOU -Password $DefaultPassword -Domain $Domain -WhatIf:$WhatIf
            $userCount++
            
            # Progress indicator
            if ($userCount % 50 -eq 0) {
                Write-Host "→ Processed $userCount users..." -ForegroundColor Gray
            }
            
        } catch {
            $errorCount++
            $employeeName = if ($employee.Name) { $employee.Name } else { "Unknown" }
            $errorMessage = if ($_.Exception.Message) { $_.Exception.Message } else { "Unknown error" }
            Write-Warning "Error processing employee '$employeeName': $errorMessage"
        }
    }
    
    Write-Host "✓ User creation completed. Processed: $userCount, Errors: $errorCount" -ForegroundColor Green
}

# Generate summary report
Write-Host "`n=== Import Summary ===" -ForegroundColor Magenta
Write-Host "Total employees in CSV: $($employees.Count)" -ForegroundColor White
Write-Host "Unique departments: $(($employees | Select-Object Department -Unique | Measure-Object).Count)" -ForegroundColor White
Write-Host "Unique sub-departments: $(($employees | Where-Object Sub_Department | Select-Object Sub_Department -Unique | Measure-Object).Count)" -ForegroundColor White

if ($WhatIf) {
    Write-Host "`nThis was a WHAT-IF run. No actual changes were made." -ForegroundColor Yellow
    Write-Host "Remove the -WhatIf parameter to execute the actual import." -ForegroundColor Yellow
} else {
    Write-Host "`nImport process completed!" -ForegroundColor Green
    Write-Host "Remember to:" -ForegroundColor Yellow
    Write-Host "  1. Review created accounts and OUs" -ForegroundColor Yellow
    Write-Host "  2. Configure group memberships as needed" -ForegroundColor Yellow
    Write-Host "  3. Set up appropriate permissions" -ForegroundColor Yellow
    Write-Host "  4. Notify users of their initial passwords" -ForegroundColor Yellow
}

Write-Host "`nScript execution completed at $(Get-Date)" -ForegroundColor White