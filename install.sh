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

read -p "Quelle est son interface pour son sous réseaux LAN :" Interface_LAN

read -p "Quelle sera l'addresse IP de son sous réseaux LAN :" IP_LAN

read -p "Quelle est le masque du sous réseaux LAN aux format CIDR (/24):" Masque_LAN_CIDR

read -p "Quelle est son masque de son sous réseaux LAN :" Masque_LAN

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
        sudo apt -y install ifenslave-2.6

        read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
        read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
        echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"

        # Ajouter ici des commandes pour configurer l'agrégation avec les interfaces choisies

    fi

    read -p "Voulez-vous mettre en place le système nftables ? [y|n] " choice_nftables

    if [ "$choice_nftables" == "y" ]; then

        echo "Vous avez choisi d'utiliser nftables."
        ip a
        Recuperer_IP_LAN

        read -p "Quelle est son interface pour son sous réseaux NAT :" Interface_NAT
        read -p "Quelle sera l'addresse IP de son sous réseaux NAT :" IP_NAT
        read -p "Quelle est le masque du sous réseaux NAT aux format CIDR (/24):" Masque_NAT_CIDR
        read -p "Quelle est son masque de son sous réseaux NAT :" Masque_NAT
        read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR
        read -p "Quelle est l'IP du routeur du réseaux NAT :" Routeur

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
    echo "1"
    nom_fichier="dsflssldkf"
    ;;
  "falsetrue")
    echo "2"
    ;;
  "truefalse")
    echo "3"
    ;;
  "falsefalse")
    echo "4"
    ;;
  *)
    echo "erreur"
    ;;
esac



#sudo sed -i "s/{Interface_NAT}/$Interface_NAT/g" ressource/interface/interfaces

#sudo sed -i "s/{IP_Nat}/$IP_Nat/g" ressource/interface/interfaces

#sudo sed -i "s/{Routeur}/$Routeur/g" ressource/interface/interface/interfaces

#sudo sed -i "s/{Interface_LAN}/$Interface_LAN/g" ressource/interface/interfaces

#sudo sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/interface/interfaces

#sudo sed -i "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" ressource/interface/interfaces

#sudo sed -i "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" ressource/interface/interfaces

#sudo mv ressource/interfaces /etc/network/interface/interfaces


echo "Fini "