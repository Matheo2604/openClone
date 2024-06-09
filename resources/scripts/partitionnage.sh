#!/bin/bash

# Recupere le nombre de partiotion voulu par paramètre
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

# Soustraire 4100096 de la taille du disque l'equivalent de 2Gio plus 2Mio de securite (1Mio = 2048 secteur)
disque_taille_finale=$((disque_partitionner - 4100096))

if [ $disque_taille_finale -lt 4100096 ]; then
    echo "Erreur : La taille finale du disque est inférieure à 4100096."
    exit 1
fi

echo "$disque_nom $disque_taille_finale"