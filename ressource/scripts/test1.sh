#!/bin/bash

# Vérification du nombre de paramètres
if [ $# -ne 2 ]; then
    echo "Usage: $0 nombre_partitions fichier_sortie"
    exit 1
fi

# Récupération du nombre de partitions et du nom du fichier de sortie
nombre_partitions=$1
fichier_sortie=$2

# Appel du script externe pour obtenir le nom_disque et taille_une_partition
output=$(./partitionnage.sh $nombre_partitions)
read nom_disque taille_une_partition <<< "$output"
echo "nom_disque = $nom_disque taille_une_partition = $taille_une_partition"
# Affichage de quelques informations pour le débogage
echo "Nom du disque: $nom_disque"
echo "Taille d'une partition: $taille_une_partition"

# Redirection de la sortie vers le fichier de sortie
{
    # Suppression de toutes les partitions et tables de partition sur nom_disque
    sudo /usr/sbin/sfdisk --delete /dev/$nom_disque
    echo "    sudo /usr/sbin/sfdisk --delete /dev/$nom_disque"

    # Création d'une nouvelle table de partition
    sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
label: dos
unit: sectors

,4096000,boot,*
,4096000,grub
EOF

    echo "    sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
label: dos
unit: sectors

,4096000,boot,*
,4096000,grub
EOF"
    # Affichage de quelques informations pour le débogage
    echo "Création des partitions supplémentaires..."

    # Création des partitions supplémentaires
    for ((i=3; i<=$nombre_partitions+2; i++)); do
sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
,${taille_une_partition}s,83
EOF

    echo "    for ((i=3; i<=$nombre_partitions+2; i++)); do
        sudo /usr/sbin/sfdisk /dev/$nom_disque << EOF
,${taille_une_partition}s,83
EOF"
# Écriture du contenu dans un fichier temporaire
echo ",${taille_une_partition}s,83" > temp_file

# Utilisation du fichier temporaire avec sfdisk
sudo /usr/sbin/sfdisk /dev/$nom_disque < temp_file

# Suppression du fichier temporaire
rm temp_file
        echo "Partition $i créée."
    done
} > "$fichier_sortie" 2>&1   # Redirection de la sortie standard (1) et de la sortie d'erreur (2) vers le fichier de sortie
