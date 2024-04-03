#!/bin/bash

# Vérification du nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: $0 nombre_partitions"
    exit 1
fi

# Récupération du nombre de partitions
nombre_partitions=$1

# Appel du script externe pour obtenir le nom_disque et taille_une_partition
output=$(./partitionnage.sh $nombre_partitions)
read nom_disque taille_une_partition <<< "$output"

# Suppression de toutes les partitions et tables de partition sur nom_disque
sudo /usr/sbin/sfdisk --delete $nom_disque

# Création d'une nouvelle table de partition
sudo /usr/sbin/sfdisk $nom_disque << EOF
label: dos
unit: sectors

,4096000,0c,*
,4096000,83
EOF

# Création des partitions supplémentaires
for ((i=1; i<=$nombre_partitions; i++)); do
    sudo /usr/sbin/sfdisk $nom_disque << EOF
,${taille_une_partition}s,83
EOF
done
