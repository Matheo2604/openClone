#!/bin/bash



# Vérifie si les paramètres ont été fournis en ligne de commande

if [ $# -eq 2 ]; then


 disque_cible="$1"


fi


# Vérifie si /sys/firmware/efi existe

[[ -d "/sys/firmware/efi" ]] && uefi=1 || uefi=0

echo $disque_cible
