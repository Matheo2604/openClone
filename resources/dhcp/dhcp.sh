#!/bin/bash

IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )

# Installation of Kea
if [ "$Kea" = true ]; then

  # Install the package needed for the DHCP
  apt-get -y install kea-dhcp4-server

  # Copied and modification of the config file
  cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.old
  cp resources/dhcp/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf
  sed -i \
    -e "s/{IP_LAN_Subnet}/$IP_LAN_Subnet/g" \
    -e "s/{Mask_LAN_CIDR}/$Mask_LAN_CIDR/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
    -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
    -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
    -e "s/{MaxIP}/${MaxIP}/g" \
    -e "s/{MinIP}/${MinIP}/g" \
    -e "s/{PathTFTP}/${PathTFTP}/g" \
    -e "s/{Interface_LAN}/${Interface_LAN}/g" \
    /etc/kea/kea-dhcp4.conf

systemctl start kea-dhcp4-server
systemctl enable kea-dhcp4-server

# Installation of isc-dhcp
elif [ "$Isc" = true ]; then

  # Install the package needed for the DHCP
  apt-get -y install isc-dhcp-server

  # Copied and modification of the config file
  cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old
  cp resources/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
  sed -i \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Mask_LAN}/$Mask_LAN/g" \
    -e "s/{IP_LAN_Subnet}/$IP_LAN_Subnet/g" \
    -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
    -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
    -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
    -e "s/{MaxIP}/${MaxIP}/g" \
    -e "s/{MinIP}/${MinIP}/g" \
    -e "s/{PathTFTP}/${PathTFTP}/g" \
    /etc/dhcp/dhcpd.conf



  # Ensures DHCP has access to the correct network interface
  chmod 666 /etc/default/isc-dhcp-server 
  echo -e "INTERFACESv4=\""$Interface_LAN"\"\nINTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
  chmod 644 /etc/default/isc-dhcp-server

fi


