#!/bin/bash

# Obtenir l'adresse IP et le masque de sous-réseau des interfaces réseau actives
ip_info=$(ip -o -4 addr show scope global | awk '{print $4}')

# Extraire l'adresse IP et le masque de sous-réseau de la première interface réseau
ip_address=$(echo "$ip_info" | head -n 1 | cut -d'/' -f1)
subnet_mask=$(echo "$ip_info" | head -n 1 | cut -d'/' -f2)

# Afficher l'adresse IP en notation CIDR
echo "Adresse IP en notation CIDR : $ip_address/$subnet_mask"
