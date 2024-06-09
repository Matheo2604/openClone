#!/bin/bash

# Vérification du passage par paramètre du nombre de partitions souhaité
if [ $# -ne 1 ]; then
  echo "Usage: $0 <nombre_de_partitions>"
  exit 1
fi

nombre_partitions=$1

# Appel du script tiers et récupération des variables
# Supposons que le script tiers s'appelle 'partitionnage.sh' et qu'il renvoie
# le nom du disque et la taille de partition utilisable
output=$(./partitionnage.sh "$nombre_partitions")
nom_disque=$(echo "$output" | awk '{print $1}')
taille_partition=$(echo "$output" | awk '{print $2}')

# Suppression de tout ce qui se trouve sur le disque
wipefs -a "/dev/$nom_disque"
dd if=/dev/zero of="/dev/$nom_disque" bs=1M count=10

# Création de la table de partition msdos
parted -s "/dev/$nom_disque" mklabel msdos

# Création d'une partition fat32 pour EFI de 4096000 secteurs
parted -s "/dev/$nom_disque" mkpart primary fat32 1s 4096000s
parted -s "/dev/$nom_disque" set 1 esp on
mkfs.fat -F32 "/dev/${nom_disque}1"

# Création d'une partition ext4 pour GRUB de 4096000 secteurs
start_grub=$((4096001))
end_grub=$((start_grub + 4095999))
parted -s "/dev/$nom_disque" mkpart primary ext4 ${start_grub}s ${end_grub}s
mkfs.ext4 "/dev/${nom_disque}2"

# Vérification de la taille du disque
taille_disque=$(parted /dev/$nom_disque unit s print | grep "Disk /dev" | awk '{print $3}' | sed 's/s//')

# Création des partitions supplémentaires
start_partition=$((end_grub + 1))
for i in $(seq 1 $nombre_partitions); do
  end_partition=$((start_partition + taille_partition - 1))
  if [ $end_partition -ge $taille_disque ]; then
    echo "Erreur : La partition $i dépasse la taille du disque."
    exit 1
  fi
  parted -s "/dev/$nom_disque" mkpart primary ext4 ${start_partition}s ${end_partition}s
  mkfs.ext4 "/dev/${nom_disque}$((i+2+1))"
  start_partition=$((end_partition + 1))
done

echo "Partitions créées avec succès sur /dev/$nom_disque"
