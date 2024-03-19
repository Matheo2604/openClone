#!/bin/bash

# Fonction pour afficher les interfaces disponibles
Afficher_interfaces() {
 echo "Interfaces disponibles :"
    ip -o link show | awk -F': ' '{print $2}'
}

# Trouver le nombre d'interfaces réseau
nombre_interfaces=$(($(ip -o link show | wc -l) - 1))

if [ $nombre_interfaces -gt 1 ]; then

    echo "Il y a $nombre_interfaces interfaces réseau disponibles."

    while true; do

        echo -e "Vous pouvez mettre en place l'une de ces fonctionnalité:\n1 - L'agrégation de liens\n2 - Nftables\n3 - Ne rien mettre en place"
        read choice

        case $choice in

            1* )
                echo "Vous avez choisi d'utiliser de l'agrégation."
                Afficher_interfaces
                read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
                read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
                echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
                # Ajoute ici des commandes pour configurer l'agrégation avec les interfaces choisies
                ;;

            2* )
                echo "Vous avez choisi d'utiliser nftables."
                Afficher_interfaces
                read -p "Quelle interface sera utiliser pour comme LAN ? " lan_interface
                read -p "Quelle interface sera utiliser pour comme WAN ? " wan_interface
                echo "Interfaces choisies pour le LAN : $interface_lan, pour le WAN : $interface_wan"
                # Ajoute ici des commandes pour configurer nftables avec les interfaces choisies
                ;;

            * )
                echo "Vous avez choisi de ne rien faire."
                break
                ;;
        esac
        
    done

else
    echo "Il n'y a qu'une interface réseau disponible."
    read -p "Quelle interface souhaitez-vous utiliser ? " interface

fi