#!/bin/bash

    apt -y install ifenslave
    echo ""
    ip a && ip r
    echo ""
    read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
    read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
    echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
    echo -e "\nune nouvelle interface nommer bond0 vient d'etre creer\n" 

echo -e "[aggregation]\n"

sed -i \
    -e "s/{Interface_LAN}/$Interface_LAN/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
    -e "s/{Routeur}/$Routeur/g" \
    -e "s/{interface1}/$interface1/g" \
    -e "s/{interface2}/$interface2/g" \
    ressource/network/interfacesAggregation

cp ressource/network/interfacesAggregation /etc/network/interfaces