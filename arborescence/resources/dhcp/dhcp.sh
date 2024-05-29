#!/bin/bash

IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )

# Installation of Kea
if [ "$Kea" = true ]; then

  # Install the package needed for the DHCP
  apt -y install kea-dhcp4-server

  # Copied and modification of the config file
  sed -i \
    -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
    -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
    -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
    -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
    -e "s/{MaxIP}/${MaxIP}/g" \
    -e "s/{MinIP}/${MinIP}/g" \
    -e "s/{PathTFTP}/${PathTFTP}/g" \
    resources/dhcp/kea-dhcp4.conf
  cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.old
  cp resources/dhcp/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf

systemctl start kea-dhcp4-server
systemctl enable kea-dhcp4-server

# Installation of isc-dhcp
elif [ "$Isc" = true ]; then

  # Install the package needed for the DHCP
  apt -y install isc-dhcp-server

  # Copied and modification of the config file
  sed -i \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Masque_LAN}/$Masque_LAN/g" \
    -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
    -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
    -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
    -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
    -e "s/{MaxIP}/${MaxIP}/g" \
    -e "s/{MinIP}/${MinIP}/g" \
    -e "s/{PathTFTP}/${PathTFTP}/g" \
    resources/dhcp/dhcpd.conf
  cp resources/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf

  # Ensures DHCP has access to the correct network interface
  chmod 666 /etc/default/isc-dhcp-server 
  echo -e "INTERFACESv4=\""$Interface_LAN"\"\nINTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
  chmod 644 /etc/default/isc-dhcp-server

fi


