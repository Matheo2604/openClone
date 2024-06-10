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

# Création d'une partition fat32 pour EFI de 1 MiO à 1GiO
parted -s "/dev/$nom_disque" mkpart primary fat32 2048s 2050047s
parted -s "/dev/$nom_disque" set 1 esp on
mkfs.fat -F32 "/dev/${nom_disque}1"

# Création d'une partition ext4 pour GRUB de 1GiO à 2GiO
parted -s "/dev/$nom_disque" mkpart primary ext4 2050048s 4098047s
mkfs.ext4 "/dev/${nom_disque}2"

# Secteur de départ pour les partitions utilisateur
# Calcul de l'offset de départ pour les partitions supplémentaires
start_byte=4098048  

# Boucle pour créer les partitions ext4
for (( i=1; i<=nombre_partitions; i++ ))
do
  end_byte=$((start_byte + taille_partition - 1)) 
  # Création de la partition avec des unités en secteurs
  parted -s "/dev/$nom_disque" mkpart primary ext4 "${start_byte}s" "${end_byte}s"
  mkfs.ext4 "/dev/${nom_disque}""${i+2}"
  start_byte=$((end_byte + 1))
done
