#!/bin/bash

# Install the package needed
apt-get -y install nftables >> /dev/null

# Copied and modification of the config file
cp /etc/nftables.conf /etc/nftables.conf.old
cp resources/nftables/nftables.conf /etc/nftables.conf
sed -i \
    -e "s/{interface_wan}/$interface_wan/g" \
    -e "s/{ip_wan_subnet}/$ip_wan_subnet/g" \
    -e "s/{ip_lan_subnet}/$ip_lan_subnet/g" \
    -e "s/{mask_lan_cidr}/$mask_lan_cidr/g" \
    -e "s/{interface_lan}/$interface_lan/g" \
    -e "s/{ip_wan_subnet}/$ip_wan_subnet/g" \
    -e "s/{ip_lan_subnet}/$ip_lan_subnet/g" \
    -e "s/{mask_lan_cidr}/$mask_lan_cidr/g" \
    -e "s/{mask_wan_cidr}/$mask_wan_cidr/g" \
    /etc/nftables.conf

# Enable the service for nftables
systemctl enable nftables