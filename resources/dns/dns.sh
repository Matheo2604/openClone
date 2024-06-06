#!/bin/bash

# Copied config files
cp resources/dns/site22.fr.zone /var/cache/bind/site22.fr.zone
sed -i "s/{IP_LAN}/$IP_LAN/g" /var/cache/bind/site22.fr.zone

cp resources/dns/dns.fr.reverse /var/cache/bind/dns.fr.reverse
sed -i "s/{IP_LAN}/$IP_LAN/g" /var/cache/bind/dns.fr.reverse

IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.old
cp resources/dns/named.conf.local /etc/bind/named.conf.local
sed -i \
  -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
  -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
  -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
  /etc/bind/named.conf.local
  
