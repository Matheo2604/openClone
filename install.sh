#!/bin/bash

# Verification du script lancement en root ????
# Assigner les paramètres à des variables

cd "$(dirname $0)"  
username="$(whoami)"

# Fonction pour afficher les interfaces disponibles
Afficher_interfaces() {

    echo "Interfaces disponibles :"
    ip -o link show | awk -F': ' '{print $2}'

}

Recuperer_IP_LAN(){

read -p "Quelle est son interface pour son sous réseaux LAN (exemple: eth0):" Interface_LAN

read -p "Quelle sera l'addresse IP de son sous réseaux LAN (exemple: 192.168.1.15):" IP_LAN

read -p "Quelle est le masque du sous réseaux LAN aux format CIDR (/24):" Masque_LAN_CIDR

read -p "Quelle est son masque de son sous réseaux LAN (exemple: 255.255.255.0):" Masque_LAN

read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_LAN_SR

}

# Trouver le nombre d'interfaces réseau
nombre_interfaces=$(($(ip -o link show | wc -l) - 1))

# Connaitre si l'utilisateur choisit l'une de c'est fonctionnalite
aggregation=false
nftable=false

if [ $nombre_interfaces -gt 1 ]; then

    echo "Il y a $nombre_interfaces interfaces réseau disponibles."
    read -p "Voulez-vous mettre en place de l'aggregation de liens ? [y|n] " choice_aggregation

    if [ "$choice_aggregation" == "y" ]; then
        
        Afficher_interfaces
        sudo apt -y install ifenslave
        aggregation=true

        read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
        read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
        echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
        echo "une nouvelle interface nommer bond0 vient d'etre creer" 
        # Ajouter ici des commandes pour configurer l'agrégation avec les interfaces choisies

    fi

    read -p "Voulez-vous mettre en place le système nftables ? [y|n] " choice_nftables

    if [ "$choice_nftables" == "y" ]; then

        echo "Vous avez choisi d'utiliser nftables."
        ip a
        Recuperer_IP_LAN
        nftable=true

        read -p "Quelle est son interface pour son sous réseaux NAT (exemple: eth0):" Interface_NAT
        read -p "Quelle sera l'addresse IP de son sous réseaux NAT (exemple: 192.168.1.15):" IP_NAT
        read -p "Quelle est le masque du sous réseaux NAT aux format CIDR (/24):" Masque_NAT_CIDR
        read -p "Quelle est son masque de son sous réseaux NAT (exemple: 255.255.255.0):" Masque_NAT
        read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR
        read -p "Quelle est l'IP du routeur du réseaux NAT (exemple: 192.168.1.254):" Routeur

     elif [ "$choice_nftables" == "n" ]; then
        
        ip a
        Recuperer_IP_LAN
        
        read -p "Quelle est l'IP du routeur du réseaux :" Routeur
        
    fi

else

    echo "Il n'y a qu'une interface réseau disponible."
    Recuperer_IP_LAN

fi

case "$aggregation$nftable" in
  "truetrue")

    sudo sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Interface_NAT}/$Interface_NAT/g" \
        -e "s/{IP_NAT}/$IP_NAT/g" \
        -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        -e "s/{interface1}/$interface1/g" \
        -e "s/{interface2}/$interface2/g" \
        ressource/interface/interfaces+aggregation+nftable

    sudo mv ressource/interface/interfaces+aggregation+nftable /etc/network/interface/interfaces
    sudo systemctl restart networking
    sudo service networking restart
    ;;

  "falsetrue")

    sudo sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Interface_NAT}/$Interface_NAT/g" \
        -e "s/{IP_NAT}/$IP_NAT/g" \
        -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        ressource/interface/interfaces+nftable

    sudo mv ressource/interface/interfaces+nftable /etc/network/interface/interfaces
    sudo systemctl restart networking
    sudo service networking restart
    ;;

  "truefalse")

    sudo sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        -e "s/{interface1}/$interface1/g" \
        -e "s/{interface2}/$interface2/g" \
        ressource/interface/interfaces+aggregation

    sudo mv ressource/interface/interfaces+aggregation /etc/network/interface/interfaces
    sudo systemctl restart networking
    sudo service networking restart
    ;;

  "falsefalse")

    sudo sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        ressource/interface/interfaces

    sudo mv ressource/interface/interfaces /etc/network/interface/interfaces
    sudo systemctl restart networking
    sudo service networking restart
    ;;

  *)
    echo "erreur"
    ;;
esac



#sudo sed -i "s/{Interface_NAT}/$Interface_NAT/g" ressource/interface/interfaces

#sudo sed -i "s/{IP_Nat}/$IP_Nat/g" ressource/interface/interfaces

#sudo sed -i "s/{Routeur}/$Routeur/g" ressource/interface/interface/interfaces

#sudo sed -i "s/{Interface_LAN}/$Interface_LAN/g" ressource/interface/interfaces



#sudo sed -i "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" ressource/interface/interfaces

#sudo mv ressource/interfaces /etc/network/interface/interfaces


echo "Fini "