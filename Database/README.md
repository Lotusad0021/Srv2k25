# Base de données Employes - Guide complet

## Description

Cette solution crée une base de données Access (.accdb) prête à l'emploi avec une table nommée "Employes" contenant les informations des employés et un formulaire pour la modification des données.

## Structure de la base de données

### Table: Employes

| Colonne | Type | Taille | Description |
|---------|------|--------|-------------|
| ID | AutoNumber | - | Clé primaire auto-incrémentée |
| employes | Text | 50 | Nom de l'employé |
| feuille_temps | Text | 20 | Période de travail |
| horaire | Text | 15 | Heures de travail |
| anciennete | Number (Integer) | - | Années d'ancienneté |
| taux_horaire | Currency | - | Salaire horaire |
| date_creation | DateTime | - | Date de création (automatique) |
| date_modification | DateTime | - | Date de modification (automatique) |

### Données de démonstration

La base de données contient 5 employés fictifs avec leurs informations :

1. **Lisa-Marie**
   - Feuille temps: Semaine 39
   - Horaire: 8h-16h
   - Ancienneté: 2 ans
   - Taux horaire: 23,50 €

2. **Noemie**
   - Feuille temps: Semaine 39
   - Horaire: 9h-17h
   - Ancienneté: 5 ans
   - Taux horaire: 26,70 €

3. **Nadia**
   - Feuille temps: Semaine 39
   - Horaire: 7h-15h
   - Ancienneté: 1 an
   - Taux horaire: 22,00 €

4. **Sarah**
   - Feuille temps: Semaine 39
   - Horaire: 10h-18h
   - Ancienneté: 4 ans
   - Taux horaire: 25,00 €

5. **Eve**
   - Feuille temps: Semaine 39
   - Horaire: 8h-14h
   - Ancienneté: 6 ans
   - Taux horaire: 28,20 €

## Fichiers inclus

### 1. `create_employes_database.py`
Script Python qui crée une démonstration de la structure de base de données en utilisant SQLite. Utile pour tester et comprendre la structure avant de créer la base Access.

**Utilisation :**
```bash
python3 create_employes_database.py
```

### 2. `employes_structure.sql`
Script SQL contenant les commandes pour créer la table et insérer les données. Peut être importé dans Microsoft Access.

### 3. `Create_Access_Database.ps1`
Script PowerShell qui crée automatiquement la base de données Access (.accdb) sur un système Windows.

**Prérequis :**
- Windows avec Microsoft Access installé
- Droits d'administration (recommandé)

**Utilisation :**
```powershell
.\Create_Access_Database.ps1
```

## Instructions de création manuelle

Si vous préférez créer la base de données manuellement dans Access :

### Étape 1: Créer la base de données
1. Ouvrir Microsoft Access
2. Sélectionner "Base de données vide"
3. Nommer le fichier "Employes.accdb"
4. Choisir l'emplacement de sauvegarde
5. Cliquer sur "Créer"

### Étape 2: Créer la table Employes
1. Dans l'onglet "Créer", cliquer sur "Création de table"
2. Ajouter les champs suivants :

| Nom du champ | Type de données | Propriétés |
|--------------|----------------|------------|
| ID | NuméroAuto | Clé primaire |
| employes | Texte court | Taille: 50, Obligatoire: Oui |
| feuille_temps | Texte court | Taille: 20, Obligatoire: Oui |
| horaire | Texte court | Taille: 15, Obligatoire: Oui |
| anciennete | Numérique | Type: Entier, Obligatoire: Oui |
| taux_horaire | Monétaire | Obligatoire: Oui |
| date_creation | Date/Heure | Valeur par défaut: Maintenant() |
| date_modification | Date/Heure | Valeur par défaut: Maintenant() |

3. Enregistrer la table sous le nom "Employes"

### Étape 3: Saisir les données
1. Ouvrir la table "Employes" en mode Feuille de données
2. Saisir les 5 employés avec leurs informations (voir section "Données de démonstration")

### Étape 4: Créer le formulaire
1. Sélectionner la table "Employes"
2. Dans l'onglet "Créer", cliquer sur "Formulaire"
3. Access créera automatiquement un formulaire basé sur la table
4. Personnaliser le formulaire selon vos besoins
5. Enregistrer le formulaire sous le nom "Formulaire_Employes"

## Fonctionnalités du formulaire

Le formulaire de modification permet :
- ✅ Affichage de tous les employés
- ✅ Modification des informations existantes
- ✅ Ajout de nouveaux employés
- ✅ Suppression d'employés
- ✅ Navigation entre les enregistrements
- ✅ Recherche et filtrage

## Validation des données

La structure inclut des contraintes pour assurer la qualité des données :
- Tous les champs principaux sont obligatoires
- Le taux horaire utilise le type monétaire pour la précision
- Les dates sont automatiquement gérées
- La clé primaire garantit l'unicité des enregistrements

## Personnalisation

Vous pouvez facilement étendre cette base de données en :
- Ajoutant de nouveaux champs (département, téléphone, email, etc.)
- Créant des relations avec d'autres tables
- Ajoutant des requêtes pour les rapports
- Créant des formulaires plus complexes
- Ajoutant des états (reports) pour l'impression

## Sauvegarde et maintenance

N'oubliez pas de :
- Faire des sauvegardes régulières de votre fichier .accdb
- Compacter et réparer la base de données périodiquement
- Documenter les modifications apportées à la structure

## Support et dépannage

En cas de problème :
1. Vérifiez que Microsoft Access est correctement installé
2. Assurez-vous d'avoir les droits nécessaires pour créer des fichiers
3. Consultez les messages d'erreur dans le script PowerShell
4. Vérifiez la compatibilité de la version d'Access

## Conclusion

Cette solution fournit une base de données Access complète et prête à l'emploi pour la gestion des informations des employés, avec tous les outils nécessaires pour la création et la maintenance.