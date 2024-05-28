#!/bin/bash

# Install the package needed for the DNS
apt -y install bind9

# Copied config files
sed -i "s/{IP_LAN}/$IP_LAN/g" ressources/dns/site22.fr.zone
cp resources/dns/site22.fr.zone /var/cache/bind/site22.fr.zone
sed -i "s/{IP_LAN}/$IP_LAN/g" resources/dns/dns.fr.reverse
cp resources/dns/dns.fr.reverse /var/cache/bind/dns.fr.reverse
IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )
sed -i \
  -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
  -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
  -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
  resources/dns/named.conf.local
cp resources/dns/named.conf.local /etc/bind/named.conf.local