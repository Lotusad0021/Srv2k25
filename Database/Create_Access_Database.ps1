# Script PowerShell pour créer une base de données Access (.accdb) avec la table Employes
# Exécuter sur un système Windows avec Microsoft Access installé

# Variables de configuration
$DatabasePath = "C:\Employes\Employes.accdb"
$DatabaseDir = Split-Path $DatabasePath -Parent

Write-Host "Script de création de la base de données Employes" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

try {
    # Créer le répertoire si il n'existe pas
    if (-not (Test-Path $DatabaseDir)) {
        New-Item -ItemType Directory -Path $DatabaseDir -Force
        Write-Host "Répertoire créé: $DatabaseDir" -ForegroundColor Green
    }

    # Supprimer le fichier existant s'il existe
    if (Test-Path $DatabasePath) {
        Remove-Item $DatabasePath -Force
        Write-Host "Base de données existante supprimée" -ForegroundColor Yellow
    }

    # Créer une instance de l'objet Access
    $Access = New-Object -ComObject Access.Application
    $Access.Visible = $false
    
    Write-Host "Création de la base de données Access..." -ForegroundColor Green
    
    # Créer la nouvelle base de données
    $Database = $Access.DBEngine.CreateDatabase($DatabasePath, ";LANGID=0x040c;CP=1252;COUNTRY=0")
    
    # Créer la table Employes
    $TableDef = $Database.CreateTableDef("Employes")
    
    # Définir les champs de la table
    $Fields = @(
        @{Name="ID"; Type=4; Attributes=17}, # AutoNumber, Primary Key
        @{Name="employes"; Type=10; Size=50}, # Text
        @{Name="feuille_temps"; Type=10; Size=20}, # Text
        @{Name="horaire"; Type=10; Size=15}, # Text
        @{Name="anciennete"; Type=3}, # Integer
        @{Name="taux_horaire"; Type=6}, # Currency
        @{Name="date_creation"; Type=8}, # DateTime
        @{Name="date_modification"; Type=8} # DateTime
    )
    
    # Ajouter les champs à la table
    foreach ($Field in $Fields) {
        $NewField = $TableDef.CreateField($Field.Name, $Field.Type)
        if ($Field.Size) {
            $NewField.Size = $Field.Size
        }
        if ($Field.Attributes) {
            $NewField.Attributes = $Field.Attributes
        }
        if ($Field.Name -eq "date_creation" -or $Field.Name -eq "date_modification") {
            $NewField.DefaultValue = "Now()"
        }
        $TableDef.Fields.Append($NewField)
    }
    
    # Ajouter la table à la base de données
    $Database.TableDefs.Append($TableDef)
    
    Write-Host "Table 'Employes' créée avec succès" -ForegroundColor Green
    
    # Insérer les données de démonstration
    $EmployesData = @(
        @{nom="Lisa-Marie"; feuille="Semaine 39"; horaire="8h-16h"; anciennete=2; taux=23.50},
        @{nom="Noemie"; feuille="Semaine 39"; horaire="9h-17h"; anciennete=5; taux=26.70},
        @{nom="Nadia"; feuille="Semaine 39"; horaire="7h-15h"; anciennete=1; taux=22.00},
        @{nom="Sarah"; feuille="Semaine 39"; horaire="10h-18h"; anciennete=4; taux=25.00},
        @{nom="Eve"; feuille="Semaine 39"; horaire="8h-14h"; anciennete=6; taux=28.20}
    )
    
    # Ouvrir la table pour l'insertion des données
    $Recordset = $Database.OpenRecordset("Employes")
    
    foreach ($Employe in $EmployesData) {
        $Recordset.AddNew()
        $Recordset.Fields("employes").Value = $Employe.nom
        $Recordset.Fields("feuille_temps").Value = $Employe.feuille
        $Recordset.Fields("horaire").Value = $Employe.horaire
        $Recordset.Fields("anciennete").Value = $Employe.anciennete
        $Recordset.Fields("taux_horaire").Value = $Employe.taux
        $Recordset.Fields("date_creation").Value = Get-Date
        $Recordset.Fields("date_modification").Value = Get-Date
        $Recordset.Update()
    }
    
    $Recordset.Close()
    Write-Host "Données insérées avec succès" -ForegroundColor Green
    
    # Créer un formulaire simple pour la modification des données
    Write-Host "Création du formulaire de modification..." -ForegroundColor Green
    
    # Le formulaire sera créé automatiquement par Access avec l'assistant
    $Access.Visible = $true
    $Access.OpenCurrentDatabase($DatabasePath)
    
    # Utiliser DoCmd pour créer un formulaire basé sur la table
    $Access.DoCmd.RunCommand(2067) # acCmdNewObjectForm
    
    Write-Host "`n✅ Base de données créée avec succès!" -ForegroundColor Green
    Write-Host "Emplacement: $DatabasePath" -ForegroundColor Cyan
    Write-Host "`nLa base de données contient:" -ForegroundColor White
    Write-Host "• Table 'Employes' avec 5 employés" -ForegroundColor White
    Write-Host "• Formulaire pour la modification des données" -ForegroundColor White
    Write-Host "`nAccess est maintenant ouvert avec la base de données." -ForegroundColor Yellow
    Write-Host "Vous pouvez créer un formulaire personnalisé en utilisant l'assistant formulaire." -ForegroundColor Yellow
    
    # Fermer les objets
    $Database.Close()
    
} catch {
    Write-Host "❌ Erreur lors de la création de la base de données:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Nettoyer en cas d'erreur
    if ($Access) {
        try {
            $Access.Quit()
        } catch {
            # Ignorer les erreurs de fermeture
        }
    }
}

Write-Host "`nScript terminé. Appuyez sur une touche pour continuer..." -ForegroundColor Gray
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")