#!/bin/bash

# Install the package needed
apt-get -y install nftables

# Copied and modification of the config file
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

cp resources/nftables/nftables.conf /etc/nftables.conf

# Enable the service for nftables
systemctl enable nftables