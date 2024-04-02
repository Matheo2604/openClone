#!/bin/bash

# Obtenir l'adresse IP et le masque de sous-réseau des interfaces réseau actives
ip_info=$(ip -o -4 addr show scope global | awk '{print $4}')

# Extraire l'adresse IP et le masque de sous-réseau de la première interface réseau
ip_address=$(echo "$ip_info" | head -n 1 | cut -d'/' -f1)
subnet_mask=$(echo "$ip_info" | head -n 1 | cut -d'/' -f2)

# Fonction pour modifier l'adresse IP en fonction du masque de sous-réseau
function modify_ip {
    local ip="$1"
    local subnet_mask="$2"

    IFS='.' read -r -a ip_octets <<< "$ip"

    if [ "$subnet_mask" -eq 8 ]; then
        echo "${ip_octets[0]}.0.0.0"
    elif [ "$subnet_mask" -eq 16 ]; then
        echo "${ip_octets[0]}.${ip_octets[1]}.0.0"
    elif [ "$subnet_mask" -eq 24 ]; then
        echo "${ip_octets[0]}.${ip_octets[1]}.${ip_octets[2]}.0"
    else
        echo "$ip"
    fi
}

# Modifier l'adresse IP en fonction du masque de sous-réseau
modified_ip=$(modify_ip "$ip_address" "$subnet_mask")

# Afficher l'adresse IP modifiée en notation CIDR
echo "Adresse IP modifiée en fonction du masque de sous-réseau : $modified_ip/$subnet_mask"
