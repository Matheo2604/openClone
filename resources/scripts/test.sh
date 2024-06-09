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
# Convertir la taille de la partition de secteurs en MiB
taille_partition_MiB=$((taille_partition / 2048 - 1))

# Suppression de tout ce qui se trouve sur le disque
wipefs -a "/dev/$nom_disque"
dd if=/dev/zero of="/dev/$nom_disque" bs=1M count=10

# Création de la table de partition GPT
parted -s "/dev/$nom_disque" mklabel gpt

# Création d'une partition fat32 pour EFI de 1MiB à 2048MiB
parted -s "/dev/$nom_disque" mkpart primary fat32 1MiB 2048MiB
parted -s "/dev/$nom_disque" set 1 esp on
mkfs.fat -F32 "/dev/${nom_disque}1"

# Création d'une partition ext4 pour GRUB de 2048MiB à 4096MiB
parted -s "/dev/$nom_disque" mkpart primary ext4 2048MiB 4096MiB
mkfs.ext4 "/dev/${nom_disque}2"

# Calcul de l'offset de départ pour les partitions supplémentaires
start_MiB=4096  # Taille en MiB de la dernière partition créée

# Boucle pour créer les partitions ext4
for (( i=1; i<=nombre_partitions; i++ ))
do
  end_MiB=$((start_MiB + taille_partition_MiB))
  # Création de la partition avec des unités en MiB
  parted -s "/dev/$nom_disque" mkpart primary ext4 "${start_MiB}MiB" "${end_MiB}MiB"
  mkfs.ext4 "/dev/${nom_disque}${i+2}"
  start_MiB=$((end_MiB + 1))
done

echo "Partitions créées avec succès sur /dev/$nom_disque"
