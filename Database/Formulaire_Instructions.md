# Instructions pour créer le formulaire de modification des employés

## Formulaire principal : "Formulaire_Employes"

### 1. Création automatique du formulaire
1. Dans Access, sélectionnez la table "Employes"
2. Onglet "Créer" > "Formulaire"
3. Access créera automatiquement un formulaire avec tous les champs

### 2. Personnalisation du formulaire

#### Layout suggéré :
```
┌─────────────────────────────────────────────────────────┐
│                    GESTION DES EMPLOYÉS                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ID: [____] (Non modifiable)                           │
│                                                         │
│  Nom de l'employé: [_________________]                 │
│                                                         │
│  Feuille de temps: [____________]                      │
│                                                         │
│  Horaire: [__________]                                 │
│                                                         │
│  Ancienneté (années): [____]                          │
│                                                         │
│  Taux horaire (€): [_______]                          │
│                                                         │
│  Date de création: [______________] (Auto)             │
│                                                         │
│  Date de modification: [______________] (Auto)         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  [◀ Précédent] [▶ Suivant] [➕ Nouveau] [🗑️ Supprimer]  │
│                                                         │
│  [💾 Enregistrer] [❌ Annuler] [🔍 Rechercher]          │
└─────────────────────────────────────────────────────────┘
```

### 3. Propriétés des contrôles

#### Champ ID
- Propriété "Enabled": Non
- Propriété "Locked": Oui
- Couleur d'arrière-plan: Gris clair

#### Champ employes
- Propriété "Required": Oui
- Validation: Longueur max 50 caractères

#### Champ feuille_temps
- Propriété "Required": Oui
- Format suggéré: "Semaine ##"

#### Champ horaire  
- Propriété "Required": Oui
- Masque de saisie: "##\h-##\h"
- Exemple: "8h-16h"

#### Champ anciennete
- Propriété "Required": Oui
- Validation: >= 0
- Message d'erreur: "L'ancienneté ne peut pas être négative"

#### Champ taux_horaire
- Format: Monétaire
- Propriété "Required": Oui
- Validation: > 0
- Message d'erreur: "Le taux horaire doit être supérieur à zéro"

#### Champs de date
- Propriété "Enabled": Non
- Propriété "Locked": Oui
- Format: "jj/mm/aaaa hh:nn:ss"

### 4. Boutons d'action

#### Code VBA pour les boutons :

**Bouton Enregistrer :**
```vba
Private Sub btnEnregistrer_Click()
    On Error GoTo ErrorHandler
    
    If Me.Dirty Then
        ' Mettre à jour la date de modification
        Me.date_modification = Now()
        DoCmd.RunCommand acCmdSaveRecord
        MsgBox "Enregistrement sauvegardé!", vbInformation
    End If
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de la sauvegarde: " & Err.Description, vbCritical
End Sub
```

**Bouton Nouveau :**
```vba
Private Sub btnNouveau_Click()
    DoCmd.GoToRecord , , acNewRec
    Me.employes.SetFocus
End Sub
```

**Bouton Supprimer :**
```vba
Private Sub btnSupprimer_Click()
    If MsgBox("Êtes-vous sûr de vouloir supprimer cet employé?", vbYesNo + vbQuestion) = vbYes Then
        DoCmd.RunCommand acCmdSelectRecord
        DoCmd.RunCommand acCmdDeleteRecord
    End If
End Sub
```

**Bouton Rechercher :**
```vba
Private Sub btnRechercher_Click()
    Dim strCriteria As String
    Dim strNom As String
    
    strNom = InputBox("Entrez le nom de l'employé à rechercher:", "Recherche")
    
    If strNom <> "" Then
        strCriteria = "[employes] Like '*" & strNom & "*'"
        Me.Filter = strCriteria
        Me.FilterOn = True
    End If
End Sub
```

### 5. Événements du formulaire

#### Événement Form_Load :
```vba
Private Sub Form_Load()
    ' Aller au premier enregistrement
    DoCmd.GoToRecord , , acFirst
End Sub
```

#### Événement Before_Update :
```vba
Private Sub Form_BeforeUpdate(Cancel As Integer)
    ' Validation avant sauvegarde
    Dim strError As String
    
    strError = ValiderDonneesEmploye(Me.employes, Me.horaire, Me.anciennete, Me.taux_horaire)
    
    If strError <> "" Then
        MsgBox strError, vbCritical, "Erreur de validation"
        Cancel = True
    Else
        Me.date_modification = Now()
    End If
End Sub
```

### 6. Navigation et ergonomie

#### Propriétés du formulaire recommandées :
- Vue par défaut: Formulaire simple
- Autoriser les ajouts: Oui
- Autoriser les suppressions: Oui
- Autoriser les modifications: Oui
- Barre de navigation: Oui
- Boutons de navigation: Oui
- Sélecteurs d'enregistrement: Oui

### 7. Formatage et style

#### Couleurs suggérées :
- Arrière-plan du formulaire: Blanc ou gris très clair
- Étiquettes: Bleu foncé
- Champs modifiables: Blanc
- Champs non modifiables: Gris clair
- Boutons: Bleu avec texte blanc

#### Polices :
- Étiquettes: Arial 10pt, Gras
- Champs: Arial 10pt, Normal
- Titre: Arial 14pt, Gras

### 8. Tests recommandés

1. Tester la saisie de nouveaux employés
2. Vérifier la modification d'employés existants
3. Tester la suppression avec confirmation
4. Vérifier la fonctionnalité de recherche
5. Tester la validation des données
6. Vérifier la mise à jour automatique des dates

Cette configuration créera un formulaire professionnel et fonctionnel pour la gestion des employés.