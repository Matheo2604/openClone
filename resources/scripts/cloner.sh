#!/bin/bash

# ajouter option pour automatisation


# Vérifie si les paramètres ont été fournis en ligne de commande

if [ $# -eq 2 ]; then

 partition_source="$1"

    partition_cible="$2"

else

    # Appel du script pour lister les partitions

    ./lister_disque.sh


    # Demande à l'utilisateur de saisir la partition source

 echo ""

    read -p "Entrez la partition source (ex : sda1) : " partition_source


    # Demande à l'utilisateur de saisir la partition cible

 echo ""

    read -p "Entrez la partition cible   (ex : sda1) : " partition_cible

fi


# Vérifie si les partitions source et cible ont été fournies

if [ -z "$partition_source" ] || [ -z "$partition_cible" ]; then

    echo "Erreur : les partitions source et cible doivent être spécifiées."

    exit 1

fi


# Clonage de la partition source vers la partition cible avec partclone

echo "Clonage de la partition $partition_source vers $partition_cible avec partclone..."


sudo partclone.ext4 -b -s "/dev/$partition_source" -o "/dev/$partition_cible"


echo "Clonage terminé."
