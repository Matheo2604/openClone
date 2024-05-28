#!/bin/bash

#if [ "$variable" = true ]; then
#    # Exécution du script si la condition est remplie
#    echo "La variable est égale à true. Exécution du script..."
#    # Ajoutez ici les commandes que vous souhaitez exécuter
#elif [ "$variable" = true ]; then
#   
#fi

echo -e "[dhcp]\n"

apt -y install isc-dhcp-server

IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )
sed -i \
  -e "s/{IP_LAN}/$IP_LAN/g" \
  -e "s/{Masque_LAN}/$Masque_LAN/g" \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
  -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
  -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
  resources/dhcp/dhcpd.conf
cp resources/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf

chmod 666 /etc/default/isc-dhcp-server 
echo -e "INTERFACESv4=\""$Interface_LAN"\"\nINTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
chmod 644 /etc/default/isc-dhcp-server 