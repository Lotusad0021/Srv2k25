-- Script SQL pour créer la table Employes dans Microsoft Access
-- Ce fichier peut être importé dans Access pour créer la structure

-- Création de la table Employes
CREATE TABLE Employes (
    ID AUTOINCREMENT PRIMARY KEY,
    employes TEXT(50) NOT NULL,
    feuille_temps TEXT(20) NOT NULL,
    horaire TEXT(15) NOT NULL,
    anciennete INTEGER NOT NULL,
    taux_horaire CURRENCY NOT NULL,
    date_creation DATETIME DEFAULT NOW(),
    date_modification DATETIME DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_employes_nom ON Employes (employes);
CREATE INDEX idx_employes_anciennete ON Employes (anciennete);

-- Insertion des données de démonstration
INSERT INTO Employes (employes, feuille_temps, horaire, anciennete, taux_horaire) VALUES
('Lisa-Marie', 'Semaine 39', '8h-16h', 2, 23.50),
('Noemie', 'Semaine 39', '9h-17h', 5, 26.70),
('Nadia', 'Semaine 39', '7h-15h', 1, 22.00),
('Sarah', 'Semaine 39', '10h-18h', 4, 25.00),
('Eve', 'Semaine 39', '8h-14h', 6, 28.20);

-- Requête pour afficher tous les employés
-- SELECT * FROM Employes ORDER BY employes;