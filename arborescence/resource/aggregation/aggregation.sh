#!/bin/bash

sed -i \
    -e "s/{Interface_LAN}/$Interface_LAN/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
    -e "s/{Routeur}/$Routeur/g" \
    -e "s/{interface1}/$interface1/g" \
    -e "s/{interface2}/$interface2/g" \
    ressource/network/interfacesAggregation

mv ressource/network/interfacesAggregation /etc/network/interfaces