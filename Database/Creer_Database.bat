@echo off
REM Batch file pour créer la base de données Access Employes
REM Double-cliquez sur ce fichier pour exécuter le script PowerShell

echo ================================
echo Création de la base de données
echo      Employes Access
echo ================================
echo.

REM Vérifier si PowerShell est disponible
powershell -Command "Write-Host 'PowerShell détecté'" >nul 2>&1
if errorlevel 1 (
    echo ERREUR: PowerShell n'est pas disponible sur ce système.
    pause
    exit /b 1
)

REM Changer vers le répertoire du script
cd /d "%~dp0"

REM Exécuter le script PowerShell
echo Exécution du script PowerShell...
echo.
powershell -ExecutionPolicy Bypass -File "Create_Access_Database.ps1"

REM Pause pour voir les résultats
echo.
echo ================================
echo Script terminé
echo ================================
pause