#!/bin/bash

ip_lan_tableau=( $(echo $ip_lan | tr "." " ") )

# Installation of Kea
if [ "$Kea" = true ]; then

  # Copied and modification of the config file
  cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.old
  cp resources/dhcp/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf
  sed -i \
    -e "s/{ip_lan_subnet}/$ip_lan_subnet/g" \
    -e "s/{mask_lan_cidr}/$mask_lan_cidr/g" \
    -e "s/{ip_lan}/$ip_lan/g" \
    -e "s/{ip0}/${ip_lan_tableau[0]}/g" \
    -e "s/{ip1}/${ip_lan_tableau[1]}/g" \
    -e "s/{ip2}/${ip_lan_tableau[2]}/g" \
    -e "s/{max_ip}/${max_ip}/g" \
    -e "s/{min_ip}/${min_ip}/g" \
    -e "s/{path_tftp}/${path_tftp}/g" \
    -e "s/{interface_lan}/${interface_lan}/g" \
    /etc/kea/kea-dhcp4.conf

systemctl start kea-dhcp4-server
systemctl enable kea-dhcp4-server

# Installation of isc-dhcp
elif [ "$Isc" = true ]; then

  # Copied and modification of the config file
  cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old
  cp resources/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
  sed -i \
    -e "s/{ip_lan}/$ip_lan/g" \
    -e "s/{Mask_LAN}/$Mask_LAN/g" \
    -e "s/{ip_lan_subnet}/$ip_lan_subnet/g" \
    -e "s/{ip0}/${ip_lan_tableau[0]}/g" \
    -e "s/{ip1}/${ip_lan_tableau[1]}/g" \
    -e "s/{ip2}/${ip_lan_tableau[2]}/g" \
    -e "s/{max_ip}/${max_ip}/g" \
    -e "s/{min_ip}/${min_ip}/g" \
    -e "s/{path_tftp}/${path_tftp}/g" \
    /etc/dhcp/dhcpd.conf



  # Ensures DHCP has access to the correct network interface
  chmod 666 /etc/default/isc-dhcp-server 
  echo -e "INTERFACESv4=\""$interface_lan"\"\nINTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
  chmod 644 /etc/default/isc-dhcp-server

fi


