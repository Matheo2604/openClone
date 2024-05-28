#!/bin/bash

echo -e "[nftables]\n"

echo "Vous avez choisi d'utiliser nftables."
    ip a && ip r
    Recuperer_IP_LAN

    read -p "Quelle est son interface pour son sous réseaux NAT (exemple: eth0):" Interface_NAT
    read -p "Quelle sera son addresse IP cote NAT (exemple: 192.168.1.15):" IP_NAT
    read -p "Quelle est le masque du sous réseaux NAT aux format CIDR (24):" Masque_NAT_CIDR
    read -p "Quelle est son masque de son sous réseaux NAT (exemple: 255.255.255.0):" Masque_NAT
    read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR
    read -p "Quelle est l'IP du routeur du réseaux NAT (exemple: 192.168.1.254):" Routeur

    # Configure Nftables
    sed -i \
        -e "s/{Interface_NAT}/$Interface_NAT/g" \
        -e "s/{IP_NAT_SR}/$IP_NAT_SR/g" \
        -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_NAT_SR}/$IP_NAT_SR/g" \
        -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
        resources/nftables/nftables.conf
    apt -y install nftables
    cp resources/nftables/nftables.conf /etc/nftables.conf

