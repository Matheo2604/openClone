#!/bin/bash

# Exécuter lsblk -b -d pour obtenir la liste des disques
# Puis trier cette liste en fonction de la taille des disques
# Enfin, sélectionner le premier disque de la liste (celui avec la taille la plus grande)

largest_disk=$(lsblk -b -d | grep disk | sort -k 4 -nr | head -n 1)

# Extraire le nom et la taille du disque le plus grand
disk_name=$(echo $largest_disk | awk '{print $1}')
disk_size=$(echo $largest_disk | awk '{print $4}')

echo "Le disque le plus grand est $disk_name avec une taille de $disk_size bytes."
