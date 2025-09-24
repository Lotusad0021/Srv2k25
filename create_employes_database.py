#!/usr/bin/env python3
"""
Script pour créer une base de données des employés avec SQLite (démonstration)
Ce script peut être adapté pour créer une base de données Access (.accdb)

Structure de la table:
- employes: nom de l'employé
- feuille_temps: période de travail
- horaire: heures de travail
- anciennete: années d'ancienneté
- taux_horaire: salaire horaire
"""

import sqlite3
import os
from pathlib import Path

def create_employes_database():
    """Crée la base de données des employés avec les données de démonstration"""
    
    # Créer le répertoire s'il n'existe pas
    db_dir = Path("/home/runner/work/Srv2k25/Srv2k25/Database")
    db_dir.mkdir(exist_ok=True)
    
    # Chemin vers la base de données
    db_path = db_dir / "employes_demo.db"
    
    # Supprimer la base existante si elle existe
    if db_path.exists():
        os.remove(db_path)
    
    # Connexion à la base de données SQLite
    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()
    
    try:
        # Création de la table Employes
        cursor.execute('''
            CREATE TABLE Employes (
                ID INTEGER PRIMARY KEY AUTOINCREMENT,
                employes TEXT NOT NULL,
                feuille_temps TEXT NOT NULL,
                horaire TEXT NOT NULL,
                anciennete INTEGER NOT NULL,
                taux_horaire DECIMAL(5,2) NOT NULL,
                date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
                date_modification DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Données des employés
        employes_data = [
            ('Lisa-Marie', 'Semaine 39', '8h-16h', 2, 23.50),
            ('Noemie', 'Semaine 39', '9h-17h', 5, 26.70),
            ('Nadia', 'Semaine 39', '7h-15h', 1, 22.00),
            ('Sarah', 'Semaine 39', '10h-18h', 4, 25.00),
            ('Eve', 'Semaine 39', '8h-14h', 6, 28.20)
        ]
        
        # Insertion des données
        cursor.executemany('''
            INSERT INTO Employes (employes, feuille_temps, horaire, anciennete, taux_horaire)
            VALUES (?, ?, ?, ?, ?)
        ''', employes_data)
        
        # Validation des données
        conn.commit()
        
        print(f"Base de données créée avec succès: {db_path}")
        print("Données insérées:")
        
        # Affichage des données
        cursor.execute('SELECT * FROM Employes')
        rows = cursor.fetchall()
        
        print("\n" + "="*80)
        print(f"{'ID':<3} {'Employé':<12} {'Feuille temps':<13} {'Horaire':<9} {'Ancienneté':<10} {'Taux horaire':<12}")
        print("="*80)
        
        for row in rows:
            print(f"{row[0]:<3} {row[1]:<12} {row[2]:<13} {row[3]:<9} {row[4]:<10} {row[5]:<12}")
        
        print("="*80)
        print(f"Total: {len(rows)} employés")
        
        return True
        
    except Exception as e:
        print(f"Erreur lors de la création de la base de données: {e}")
        return False
    
    finally:
        conn.close()

def show_database_structure():
    """Affiche la structure de la base de données"""
    
    db_path = "/home/runner/work/Srv2k25/Srv2k25/Database/employes_demo.db"
    
    if not os.path.exists(db_path):
        print("La base de données n'existe pas. Veuillez l'exécuter d'abord.")
        return
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Obtenir la structure de la table
        cursor.execute("PRAGMA table_info(Employes)")
        columns = cursor.fetchall()
        
        print("\nStructure de la table Employes:")
        print("-" * 60)
        print(f"{'Colonne':<20} {'Type':<15} {'Obligatoire':<12}")
        print("-" * 60)
        
        for column in columns:
            name = column[1]
            data_type = column[2]
            not_null = "Oui" if column[3] else "Non"
            print(f"{name:<20} {data_type:<15} {not_null:<12}")
        
        print("-" * 60)
        
    except Exception as e:
        print(f"Erreur lors de la lecture de la structure: {e}")
    
    finally:
        conn.close()

def main():
    """Fonction principale"""
    print("Création de la base de données des employés")
    print("=" * 50)
    
    success = create_employes_database()
    
    if success:
        show_database_structure()
        print("\n✅ Base de données créée avec succès!")
        print("\nPour utiliser cette structure dans Access:")
        print("1. Créez une nouvelle base de données Access (.accdb)")
        print("2. Importez la structure et les données depuis le fichier SQL")
        print("3. Ajoutez un formulaire pour la modification des données")
    else:
        print("\n❌ Échec de la création de la base de données")

if __name__ == "__main__":
    main()