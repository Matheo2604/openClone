#!/bin/bash

# Vérification du passage par paramètre du nombre de partitions souhaité
if [ $# -ne 1 ]; then
  echo "Usage: $0 <nombre_de_partitions>"
  exit 1
fi

nombre_partitions=$1

# Appel du script tiers et récupération des variables
output=$(./partitionnage.sh "$nombre_partitions")

# Utilisation de read pour extraire les variables de sortie
read nom_disque taille_partition <<< "$output"

# Suppression de tout ce qui se trouve sur le disque
wipefs -a "/dev/$nom_disque"
dd if=/dev/zero of="/dev/$nom_disque" bs=1M count=10

# Création de la table de partition GPT
parted -s "/dev/$nom_disque" mklabel gpt

# Création d'une partition fat32 pour EFI de 1 MiB à 2048 MiB
parted -s "/dev/$nom_disque" mkpart primary fat32 2048s 4116479s
parted -s "/dev/$nom_disque" set 1 esp on
mkfs.fat -F32 "/dev/${nom_disque}1"

# Création d'une partition ext4 pour GRUB de 2049 MiB à 4096 MiB
parted -s "/dev/$nom_disque" mkpart primary ext4 4116480s 8191999s
mkfs.ext4 "/dev/${nom_disque}2"

# Calcul de l'offset de départ pour les partitions supplémentaires
start_sector=8192000  # Secteur de départ pour les partitions supplémentaires

# Boucle pour créer les partitions ext4
for (( i=1; i<=nombre_partitions; i++ ))
do
  end_sector=$((start_sector + taille_partition - 1))
  # Création de la partition avec des unités en secteurs
  parted -s "/dev/$nom_disque" mkpart primary ext4 "${start_sector}s" "${end_sector}s"
  mkfs.ext4 "/dev/${nom_disque}${i+2}"
  start_sector=$((end_sector + 1))
done
