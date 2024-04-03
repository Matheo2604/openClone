#!/bin/bash

# Vérification du nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: $0 nombre_partitions"
    exit 1
fi

# Récupération du nombre de partitions
nombre_partitions=$1

# Appel du script externe pour obtenir le nom_disque et taille_une_partition
output=$(./partitionnage.sh)
read nom_disque taille_une_partition <<< "$output"

# Suppression de toutes les partitions et tables de partition sur nom_disque
sudo /sbin/sfdisk --delete $nom_disque

# Création d'une nouvelle table de partition
sudo /sbin/sfdisk $nom_disque << EOF
label: dos
unit: sectors

,4096000,0c,*
,4096000,83
EOF

# Calcul de la taille de partition restante
taille_restante=$((taille_une_partition - 4096000 * 2))

# Création des partitions supplémentaires
for ((i=1; i<=$nombre_partitions; i++)); do
    sudo /sbin/sfdisk $nom_disque << EOF
,${taille_restante}s,83
EOF
done
