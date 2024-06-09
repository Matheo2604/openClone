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

# Utilisation de read pour extraire les variables de sortie
read nom_disque taille_partition <<< "$output"
taille_partition=$((taille_partition - 800000))

# Suppression de tout ce qui se trouve sur le disque
wipefs -a "/dev/$nom_disque"
dd if=/dev/zero of="/dev/$nom_disque" bs=1M count=10

# Création de la table de partition GPT
parted -s "/dev/$nom_disque" mklabel gpt

# Création d'une partition fat32 pour EFI de 4096000 secteurs
parted -s "/dev/$nom_disque" mkpart primary fat32 1MiB 2048MiB
parted -s "/dev/$nom_disque" set 1 esp on
mkfs.fat -F32 "/dev/${nom_disque}1"

# Création d'une partition ext4 pour GRUB de 2048MiB à 4096MiB
parted -s "/dev/$nom_disque" mkpart primary ext4 2048MiB 4096MiB
mkfs.ext4 "/dev/${nom_disque}2"

# Calcul de l'offset de départ pour les partitions supplémentaires
start_sector=$((4096 * 2048))  # 4096MiB in sectors

# Obtenir la taille totale du disque en secteurs
disk_size=$(parted -m /dev/$nom_disque unit s print | grep "^/dev" | awk -F: '{print $2}' | sed 's/s//')

# Boucle pour créer les partitions ext4
for (( i=1; i<=nombre_partitions; i++ ))
do
  end_sector=$((start_sector + taille_partition - 1))
  
  # Vérifier si end_sector dépasse la taille totale du disque
  if [ $end_sector -ge $disk_size ]; then
    echo "Erreur : la taille des partitions dépasse la taille du disque."
    exit 1
  fi
  
  parted -s "/dev/$nom_disque" mkpart primary ext4 "${start_sector}s" "${end_sector}s"
  mkfs.ext4 "/dev/${nom_disque}${i+2}"
  start_sector=$((end_sector + 1))
done

echo "Partitions créées avec succès sur /dev/$nom_disque"
