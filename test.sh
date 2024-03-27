#!/bin/bash

# Fonction pour afficher les interfaces disponibles
Afficher_interfaces() {
    echo "Interfaces disponibles :"
    ip -o link show | awk -F': ' '{print $2}'
}

Recuperer_IP_LAN(){
read -p "Quelle sera l'addresse IP de son sous réseaux LAN :" IP_LAN

read -p "Quelle est son masque de son sous réseaux LAN :" Masque_LAN

read -p "Quelle est son interface pour son sous réseaux LAN :" Interface_LAN

read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_LAN_SR

read -p "Quelle est l'IP de broadcast local du sous réseaux LAN (exemple: 192.168.1.255):" Masque_LAN_CIDR

}

# Trouver le nombre d'interfaces réseau
nombre_interfaces=$(($(ip -o link show | wc -l) - 1))

if [ $nombre_interfaces -gt 1 ]; then

    echo "Il y a $nombre_interfaces interfaces réseau disponibles."
    read -p "Voulez-vous mettre en place de l'agrégation de liens ? [y|n] " choice_aggregation

    if [ "$choice_aggregation" == "y" ]; then
        
        Afficher_interfaces
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

        read -p "Quelle est son masque de son sous réseaux NAT :" Masque_NAT

        read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR

        read -p "Quelle est l'IP de broadcast local du sous réseaux NAT (exemple: 192.168.1.255):" Masque_NAT_CIDR

        read -p "Quelle est l'IP du routeur du réseaux NAT :" Routeur_NAT

     elif [ "$choice_nftables" == "n" ]; then
        
        ip a
        Recuperer_IP_LAN
        
    fi

else

    echo "Il n'y a qu'une interface réseau disponible."
    Recuperer_IP_LAN

fi

# Le reste du script ici après la sortie de la boucle while
echo "La suite du script après la boucle while."