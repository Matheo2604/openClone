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
disque_taille=$(echo $disque | awk '{print $4}')

# Calculer la taille du disque en fonction du diviseur
disque_partitionner=$((disque_taille / nombre_partition))

# Soustraire 2148532224 octest de la taille du disque l'equivalent de 2 Go 
disque_taille_finale=$((disque_partitionner - 2148532224))

if [ $disque_taille_finale -lt 2148532224 ]; then
    echo "Erreur : La taille finale du disque est inférieure à 2148532224 octets."
    exit 1
fi

echo "$disque_nom $disque_taille_finale"
