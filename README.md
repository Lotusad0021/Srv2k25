# Nordika Solutions Active Directory Import Scripts

This repository contains PowerShell scripts for importing employee data from Nordika Solutions into Windows Server 2025 Active Directory.

## Files Included

- `nordika_solutions_employees.csv` - Employee data file containing 359 employees
- `Import-NordikaEmployees.ps1` - Main import script for creating OUs and user accounts
- `View-NordikaAD.ps1` - Utility script for viewing and exporting AD structure
- `Import-NordikaEmployees-Original.ps1` - Backup of original script (for reference)

## Prerequisites

- Windows Server 2025
- Active Directory PowerShell Module
- Domain Administrator privileges
- PowerShell 5.1 or later

## Quick Start

### 1. Test the Import (Recommended First Step)
```powershell
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "nordika.local" -WhatIf
```

### 2. Create Organizational Units Only
```powershell
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "nordika.local" -CreateOUs
```

### 3. Full Import (OUs and Users)
```powershell
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "nordika.local" -CreateOUs -CreateUsers
```

### 4. View Results
```powershell
# View all OUs
.\View-NordikaAD.ps1 -Domain "nordika.local" -ShowOUs

# View all users
.\View-NordikaAD.ps1 -Domain "nordika.local" -ShowUsers

# View users by OU
.\View-NordikaAD.ps1 -Domain "nordika.local" -ShowUsersByOU
```

## CSV File Structure

The `nordika_solutions_employees.csv` file contains the following columns:

| Column | Description | Example |
|--------|-------------|---------|
| Name | Full employee name | Amina El-Sayed |
| Position | Job title | Directeur Général |
| Department | Main department | Direction Générale |
| Sub_Department | Sub-department or team | Comptabilité |
| Reports_To | Manager's name | Jean-Pierre Dubois |
| Employee_Count_In_Unit | Number of people in unit | 35 |

## Import Script Features

### Organizational Units
- Creates department-based OU structure
- Creates sub-department OUs
- Protects OUs from accidental deletion
- Handles existing OUs gracefully

### User Accounts
- Generates usernames from employee names
- Sets up email addresses
- Creates manager relationships
- Forces password change at first logon
- Handles special characters and accents

### Safety Features
- **WhatIf Mode**: Test without making changes
- **Error Handling**: Comprehensive error logging
- **Duplicate Detection**: Skips existing users and OUs
- **Progress Indicators**: Shows progress for large imports

## Command Reference

### Import-NordikaEmployees.ps1 Parameters

| Parameter | Description | Required | Example |
|-----------|-------------|----------|---------|
| -CSVPath | Path to CSV file | Yes | ".\nordika_solutions_employees.csv" |
| -Domain | Domain name | Yes | "nordika.local" |
| -OUBasePath | Base OU path | No | "OU=Employees,DC=nordika,DC=local" |
| -DefaultPassword | Password for new accounts | No | SecureString |
| -CreateOUs | Create organizational units | No | Switch |
| -CreateUsers | Create user accounts | No | Switch |
| -WhatIf | Show what would be done | No | Switch |

### View-NordikaAD.ps1 Parameters

| Parameter | Description | Required | Example |
|-----------|-------------|----------|---------|
| -Domain | Domain name | Yes | "nordika.local" |
| -ShowOUs | Display all OUs | No | Switch |
| -ShowUsers | Display all users | No | Switch |
| -ShowUsersByOU | Display users by OU | No | Switch |
| -ShowDepartments | Display departments | No | Switch |
| -ExportToCSV | Export results to CSV | No | Switch |

## Examples

### Basic Import Workflow
```powershell
# 1. Test the import first
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "contoso.local" -WhatIf

# 2. Create OUs first
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "contoso.local" -CreateOUs

# 3. Create users
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "contoso.local" -CreateUsers

# 4. Verify results
.\View-NordikaAD.ps1 -Domain "contoso.local" -ShowUsersByOU
```

### Custom Password
```powershell
$SecurePassword = ConvertTo-SecureString "MyCustomPassword123!" -AsPlainText -Force
.\Import-NordikaEmployees.ps1 -CSVPath ".\nordika_solutions_employees.csv" -Domain "nordika.local" -CreateOUs -CreateUsers -DefaultPassword $SecurePassword
```

### Export Current AD Structure
```powershell
# Export all users to CSV
.\View-NordikaAD.ps1 -Domain "nordika.local" -ShowUsers -ExportToCSV

# Export department statistics
.\View-NordikaAD.ps1 -Domain "nordika.local" -ShowDepartments -ExportToCSV
```

## Troubleshooting

### Common Issues

1. **Module Not Found**: Install RSAT or run on domain controller
2. **Permission Denied**: Run as Domain Administrator
3. **OU Already Exists**: Script will skip existing OUs (safe)
4. **User Already Exists**: Script will skip existing users (safe)

### Syntax Errors Fixed

The original script had several syntax issues that have been resolved:
- Missing catch blocks in try-catch statements
- Unmatched braces in conditional statements
- String interpolation issues
- Improved error handling

### Viewing Active Directory

Use these PowerShell commands to view AD structure:

```powershell
# List all OUs
Get-ADOrganizationalUnit -Filter * | Sort-Object DistinguishedName

# List users in specific OU
Get-ADUser -Filter * -SearchBase "OU=Employees,DC=nordika,DC=local"

# List users with details
Get-ADUser -Filter * -Properties Department,Title,Manager | Select-Object Name,Department,Title

# Count users by department
Get-ADUser -Filter * -Properties Department | Group-Object Department | Sort-Object Name
```

## Default Settings

- **Default Password**: "NordikaTemp123!" (changed at first logon)
- **Base OU**: "OU=Employees,DC={domain},DC={tld}"
- **Username Format**: First 3 letters + Last 5 letters (lowercase)
- **Email Format**: {username}@{domain}

## Security Considerations

- Users are required to change password at first logon
- Passwords never expire is set to False
- Users can change their passwords
- OUs are protected from accidental deletion
- All operations are logged for audit purposes

## Support

For issues or questions about these scripts, please refer to the Windows Server 2025 documentation or Active Directory PowerShell module help.

```powershell
Get-Help Import-NordikaEmployees.ps1 -Full
Get-Help View-NordikaAD.ps1 -Full
```
