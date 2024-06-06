#!/bin/bash

# Install the package needed
apt-get -y install nftables >> /dev/null

# Copied and modification of the config file
cp /etc/nftables.conf /etc/nftables.conf.old
cp resources/nftables/nftables.conf /etc/nftables.conf
sed -i \
    -e "s/{Interface_WAN}/$Interface_WAN/g" \
    -e "s/{IP_WAN_Subnet}/$IP_WAN_Subnet/g" \
    -e "s/{IP_LAN_Subnet}/$IP_LAN_Subnet/g" \
    -e "s/{Mask_LAN_CIDR}/$Mask_LAN_CIDR/g" \
    -e "s/{Interface_LAN}/$Interface_LAN/g" \
    -e "s/{IP_WAN_SR}/$IP_WAN_SR/g" \
    -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
    -e "s/{Mask_LAN_CIDR}/$Mask_LAN_CIDR/g" \
    -e "s/{Mask_WAN_CIDR}/$Mask_WAN_CIDR/g" \
    /etc/nftables.conf

# Enable the service for nftables
systemctl enable nftables