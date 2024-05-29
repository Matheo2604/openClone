#!/bin/bash

Recuperer_IP_LAN(){

read -p "Quelle est son interface pour son sous réseaux LAN (exemple: eth0):" Interface_LAN
read -p "Quelle sera son addresse IP cote LAN (exemple: 192.168.1.15):" IP_LAN
read -p "Quelle est le masque du sous réseaux LAN aux format CIDR (24):" Masque_LAN_CIDR
read -p "Quelle est son masque de son sous réseaux LAN (exemple: 255.255.255.0):" Masque_LAN
read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_LAN_SR

}

    read -p "Voulez-vous mettre en place de l'aggregation de liens ? [y|n] " choice_aggregation

    if [ "$choice_aggregation" == "y" ]; then
        
        ActivationAggregation=true
        apt -y install ifenslave
        echo ""
        ip a && ip r
        echo ""
        read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
        read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
        echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
        echo -e "\nune nouvelle interface nommer bond0 vient d'etre creer\n" 
    
    fi

    read -p "Voulez-vous mettre en place le système nftables ? [y|n] " choice_nftables

    if [ "$choice_nftables" == "y" ]; then

        echo "Vous avez choisi d'utiliser nftables."
        ip a && ip r
        Recuperer_IP_LAN
        ActivationNftables=true

     elif [ "$choice_nftables" == "n" ]; then
        
        echo ""
        ip a
        echo ""
        Recuperer_IP_LAN
        
        read -p "Quelle est l'IP du routeur du réseaux :" Routeur
        
    fi

else

    echo "Il n'y a qu'une interface réseau disponible."
    Recuperer_IP_LAN

fi

case "$ActivationAggregation$ActivationNftables" in
  "truetrue")

    source bash aggregation/aggregation.sh || { echo "something went wrong during the installation of the aggregation" && exit 1; }
    source bash nftables/nftables.sh || { echo "something went wrong during the installation of the nftable" && exit 1; }
    sed -i \
    -e "s/{Interface_NAT}/$Interface_NAT/g" \
    -e "s/{IP_NAT}/$IP_NAT/g" \
    -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
    -e "s/{Routeur}/$Routeur/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
    -e "s/{interface1}/$interface1/g" \
    -e "s/{interface2}/$interface2/g" \
    resources/interface/interfacesAggregationNftables
    cp resources/interface/interfacesAggregationNftables /etc/network/interfaces
    ;;

  "falsetrue")

    source bash nftables/nftables.sh || { echo "something went wrong during the installation of the nftables" && exit 1; }
    sed -i \
    -e "s/{Interface_LAN}/$Interface_LAN/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
    -e "s/{Interface_NAT}/$Interface_NAT/g" \
    -e "s/{IP_NAT}/$IP_NAT/g" \
    -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
    -e "s/{Routeur}/$Routeur/g" \
    resources/interface/interfacesNftables
    cp resources/interface/interfacesNftables /etc/network/interfaces
    ;;

  "truefalse")
    
    source bash aggregation/aggregation.sh || { echo "something went wrong during the installation of the aggregation" && exit 1; }
    sed -i \
    -e "s/{Interface_LAN}/$Interface_LAN/g" \
    -e "s/{IP_LAN}/$IP_LAN/g" \
    -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
    -e "s/{Routeur}/$Routeur/g" \
    -e "s/{interface1}/$interface1/g" \
    -e "s/{interface2}/$interface2/g" \
    resources/interface/interfacesAggregation
    cp resources/interface/interfacesAggregation /etc/network/interfaces
    ;;

  "falsefalse")

    sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        resources/interface/interfaces

    cp resources/interface/interfaces /etc/network/interfaces
    ;;

  *)
    echo "something went wrong"
    exit 1
    ;;
esac

systemctl restart networking
ip r add default via $Routeur