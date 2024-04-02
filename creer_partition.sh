#!/bin/bash

# appel du script pour lister les partitions
./lister_disque.sh

read -p "Entrez le disque sur lequel vous voulez creer une partition (ex: sda) : " disque

# Demande à l'utilisateur de saisir le périphérique où créer la partition
read -p "Entrez le périphérique où créer la partition (ex: /dev/sda): " disk

# Affiche les partitions actuelles sur le périphérique choisi
./lister_disque.sh

# Demande à l'utilisateur de saisir le type de partition à créer (primaire, étendue...)
read -p "Entrez le type de partition à créer (primaire/p, étendue/e) : " part_type

# Demande à l'utilisateur de saisir le point de départ de la partition
read -p "Entrez le point de départ de la partition (en secteurs, ex: 2048) : " start_sector

# Demande à l'utilisateur de saisir la taille de la partition
read -p "Entrez la taille de la partition (en secteurs, ex: +10G) : " size

# Assemble la commande fdisk
command="n"
command="$command"$'\n'
command="$command"$part_type
command="$command"$'\n'
command="$command"$start_sector
command="$command"$'\n'
command="$command"$size
command="$command"$'\n'

# Affiche les modifications proposées
echo "Modifications proposées :"
echo "$command"

# Demande confirmation à l'utilisateur
read -p "Confirmez-vous la création de la partition ? (o/n) : " confirm

# Si la réponse est "o", alors applique les modifications avec fdisk
if [ "$confirm" == "o" ]; then
    echo "Application des modifications..."
    echo -e "$command" | fdisk $disk
    echo "Modifications appliquées avec succès."
else
    echo "Création de partition annulée."
fi
