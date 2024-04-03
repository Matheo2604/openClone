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

# Affichage de quelques informations pour le débogage
echo "Nom du disque: $nom_disque"
echo "Taille d'une partition: $taille_une_partition"

# Suppression de toutes les partitions et tables de partition sur nom_disque
sudo /usr/sbin/sfdisk --delete /dev/$nom_disque

# Création d'une nouvelle table de partition
sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
label: dos
unit: sectors

,4096000,boot,*
,4096000,grub
EOF

# Affichage de quelques informations pour le débogage
echo "Création des partitions supplémentaires..."

# Création des partitions supplémentaires
for ((i=3; i<=$nombre_partitions+2; i++)); do
    sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
,${taille_une_partition}s,83
EOF
    echo "Partition $i créée."
done
