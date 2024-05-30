#!/bin/bash

# Définir les informations de connexion à la base de données
DB_USER="responsable"
DB_PASSWORD="felix22"
DB_NAME="openclone"
table_name="clients"
# Exécuter la requête SQL pour récupérer les données de la table clients
mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SELECT * FROM clients;"
