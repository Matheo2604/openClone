#!/bin/bash

apt -y install isc-dhcp-server

IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )
sed -i \
  -e "s/{IP_LAN}/$IP_LAN/g" \
  -e "s/{Masque_LAN}/$Masque_LAN/g" \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
  -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
  -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
  ressource/dhcpd.conf
mv ressource/dhcpd.conf /etc/dhcp/dhcpd.conf

chmod 666 /etc/default/isc-dhcp-server 
echo -e "INTERFACESv4="\"$Interface_LAN\"\n"INTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
chmod 644 /etc/default/isc-dhcp-server 