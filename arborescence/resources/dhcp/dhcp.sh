#!/bin/bash

#KEA a mettre en place
#if [ "$variable" = true ]; then
#    # Exécution du script si la condition est remplie
#    echo "La variable est égale à true. Exécution du script..."
#    # Ajoutez ici les commandes que vous souhaitez exécuter
#elif [ "$variable" = true ]; then
#   
#fi


# Install the package needed for the DHCP
apt -y install isc-dhcp-server

# Copied and modification of the config file
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

# Ensures DHCP has access to the correct network interface
chmod 666 /etc/default/isc-dhcp-server 
echo -e "INTERFACESv4=\""$Interface_LAN"\"\nINTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
chmod 644 /etc/default/isc-dhcp-server 