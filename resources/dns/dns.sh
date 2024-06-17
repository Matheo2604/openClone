#!/bin/bash

# Copied config files
cp resources/dns/site22.fr.zone /var/cache/bind/site22.fr.zone
sed -i "s/{ip_lan}/$ip_lan/g" /var/cache/bind/site22.fr.zone

cp resources/dns/dns.fr.reverse /var/cache/bind/dns.fr.reverse
sed -i "s/{ip_lan}/$ip_lan/g" /var/cache/bind/dns.fr.reverse

ip_lan_tableau=( $(echo $ip_lan | tr "." " ") )
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.old
cp resources/dns/named.conf.local /etc/bind/named.conf.local
sed -i \
  -e "s/{ip0}/${ip_lan_tableau[0]}/g" \
  -e "s/{ip1}/${ip_lan_tableau[1]}/g" \
  -e "s/{ip2}/${ip_lan_tableau[2]}/g" \
  /etc/bind/named.conf.local
  
