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
taille_une_partition=$((taille_une_partition - 2048))

# Suppression de toutes les partitions et tables de partition sur nom_disque
sudo /usr/sbin/sfdisk --delete $nom_disque

# Création d'une nouvelle table de partition
echo ",4096000,ef" | sudo sfdisk --quiet "$DISK"
# Formater la partition en FAT32
PARTITION="${DISK}1"
sudo mkfs.fat -F32 "$PARTITION"

echo ",4096000,L" | sudo sfdisk --quiet "$DISK"
# Formater la partition en ext4
PARTITION="${DISK}1"
sudo mkfs.ext4 "$PARTITION"

# Création des partitions supplémentaires
#start_sector=8194047  # Début du premier espace libre
#for ((i=3; i<=$nombre_partitions+2; i++)); do
#    end_sector=$((start_sector + taille_une_partition - 1))
#    sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
#,$end_sector,83
#EOF
#    start_sector=$((end_sector + 1))
#done
