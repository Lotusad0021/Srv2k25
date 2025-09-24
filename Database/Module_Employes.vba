' Module VBA pour la base de données Employes
' Ce code peut être ajouté dans Microsoft Access pour étendre les fonctionnalités

Option Compare Database
Option Explicit

' Fonction pour mettre à jour automatiquement la date de modification
Public Function UpdateModificationDate(EmployeID As Long) As Boolean
    On Error GoTo ErrorHandler
    
    Dim strSQL As String
    strSQL = "UPDATE Employes SET date_modification = Now() WHERE ID = " & EmployeID
    
    CurrentDb.Execute strSQL
    UpdateModificationDate = True
    Exit Function
    
ErrorHandler:
    MsgBox "Erreur lors de la mise à jour: " & Err.Description
    UpdateModificationDate = False
End Function

' Fonction pour calculer le salaire hebdomadaire
Public Function CalculateSalaireHebdomadaire(TauxHoraire As Currency, Optional HeuresParSemaine As Integer = 35) As Currency
    CalculateSalaireHebdomadaire = TauxHoraire * HeuresParSemaine
End Function

' Fonction pour calculer le salaire mensuel
Public Function CalculateSalaireMensuel(TauxHoraire As Currency, Optional HeuresParSemaine As Integer = 35) As Currency
    CalculateSalaireMensuel = (TauxHoraire * HeuresParSemaine * 52) / 12
End Function

' Fonction pour extraire les heures de travail quotidiennes
Public Function ExtraireHeuresQuotidiennes(Horaire As String) As Integer
    On Error GoTo ErrorHandler
    
    Dim DebutHeure As String
    Dim FinHeure As String
    Dim PosTraits As Integer
    
    PosTraits = InStr(Horaire, "-")
    If PosTraits > 0 Then
        DebutHeure = Left(Horaire, PosTraits - 1)
        FinHeure = Mid(Horaire, PosTraits + 1)
        
        ' Extraire les heures (supposer format "8h-16h")
        Dim DebutHeureNum As Integer
        Dim FinHeureNum As Integer
        
        DebutHeureNum = CInt(Left(DebutHeure, InStr(DebutHeure, "h") - 1))
        FinHeureNum = CInt(Left(FinHeure, InStr(FinHeure, "h") - 1))
        
        ExtraireHeuresQuotidiennes = FinHeureNum - DebutHeureNum
    Else
        ExtraireHeuresQuotidiennes = 8 ' Valeur par défaut
    End If
    Exit Function
    
ErrorHandler:
    ExtraireHeuresQuotidiennes = 8 ' Valeur par défaut en cas d'erreur
End Function

' Fonction pour formater l'affichage des employés
Public Function FormatEmployeInfo(Nom As String, Anciennete As Integer, TauxHoraire As Currency) As String
    FormatEmployeInfo = Nom & " (" & Anciennete & " ans, " & Format(TauxHoraire, "0.00") & "€/h)"
End Function

' Procédure pour valider les données avant sauvegarde
Public Function ValiderDonneesEmploye(Nom As String, Horaire As String, Anciennete As Integer, TauxHoraire As Currency) As String
    Dim ErrorMessage As String
    ErrorMessage = ""
    
    ' Vérifier le nom
    If Trim(Nom) = "" Then
        ErrorMessage = ErrorMessage & "Le nom de l'employé est obligatoire." & vbCrLf
    End If
    
    ' Vérifier l'horaire
    If Trim(Horaire) = "" Then
        ErrorMessage = ErrorMessage & "L'horaire est obligatoire." & vbCrLf
    ElseIf InStr(Horaire, "-") = 0 Then
        ErrorMessage = ErrorMessage & "L'horaire doit être au format '8h-16h'." & vbCrLf
    End If
    
    ' Vérifier l'ancienneté
    If Anciennete < 0 Then
        ErrorMessage = ErrorMessage & "L'ancienneté ne peut pas être négative." & vbCrLf
    End If
    
    ' Vérifier le taux horaire
    If TauxHoraire <= 0 Then
        ErrorMessage = ErrorMessage & "Le taux horaire doit être supérieur à zéro." & vbCrLf
    End If
    
    ValiderDonneesEmploye = ErrorMessage
End Function

' Fonction pour rechercher un employé par nom
Public Function RechercherEmploye(NomRecherche As String) As Recordset
    Dim strSQL As String
    strSQL = "SELECT * FROM Employes WHERE employes LIKE '*" & NomRecherche & "*' ORDER BY employes"
    Set RechercherEmploye = CurrentDb.OpenRecordset(strSQL)
End Function

' Procédure pour exporter les données vers Excel (optionnel)
Public Sub ExporterVersExcel()
    On Error GoTo ErrorHandler
    
    Dim xlApp As Object
    Dim xlWorkbook As Object
    Dim xlWorksheet As Object
    Dim rs As Recordset
    Dim i As Integer
    
    ' Créer une instance d'Excel
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    
    Set xlWorkbook = xlApp.Workbooks.Add
    Set xlWorksheet = xlWorkbook.Worksheets(1)
    
    ' Ouvrir le recordset
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM Employes ORDER BY employes")
    
    ' Ajouter les en-têtes
    xlWorksheet.Cells(1, 1) = "Employé"
    xlWorksheet.Cells(1, 2) = "Feuille temps"
    xlWorksheet.Cells(1, 3) = "Horaire"
    xlWorksheet.Cells(1, 4) = "Ancienneté"
    xlWorksheet.Cells(1, 5) = "Taux horaire"
    
    ' Ajouter les données
    i = 2
    Do While Not rs.EOF
        xlWorksheet.Cells(i, 1) = rs!employes
        xlWorksheet.Cells(i, 2) = rs!feuille_temps
        xlWorksheet.Cells(i, 3) = rs!horaire
        xlWorksheet.Cells(i, 4) = rs!anciennete
        xlWorksheet.Cells(i, 5) = rs!taux_horaire
        i = i + 1
        rs.MoveNext
    Loop
    
    rs.Close
    MsgBox "Export terminé!"
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de l'export: " & Err.Description
    If Not rs Is Nothing Then rs.Close
End Sub