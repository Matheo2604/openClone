#!/bin/bash

# Récupère le nombre de partitions voulu par paramètre
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nombre_partition>"
    exit 1
fi

nombre_partition=$1

# Recherche du disque le plus grand disponible sur le poste
disque=$(lsblk -b -d | grep disk | sort -k 4 -nr | head -n 1)

# Extraire le nom et la taille du disque le plus grand
disque_nom=$(echo $disque | awk '{print $1}')
taille_disque=$(echo $disque | awk '{print $4}')

# Passage d'octets à secteur
taille_disque=$((taille_disque / 512))
# Prise en compte de la partition grub et efi
taille_disque=$((taille_disque - 4100096))

# Calculer la taille du disque en fonction du diviseur
disque_partitionner=$((taille_disque / nombre_partition))

if [ $disque_partitionner -lt 4098048 ]; then
    echo "Erreur : La taille finale du disque est inférieure à 4098048 octets."
    exit 1
fi

echo "$disque_nom $disque_partitionner"
