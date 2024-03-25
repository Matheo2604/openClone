#!/bin/bash


#changer  switch
#plus de boulce while mais demande aggregation de lien en premier [y|n] puis nftables 
#garder en compte le nombre d'interface reseaux

# Fonction pour afficher les interfaces disponibles
Afficher_interfaces() {
 echo "Interfaces disponibles :"
    ip -o link show | awk -F': ' '{print $2}'
}

# Trouver le nombre d'interfaces réseau
nombre_interfaces=$(($(ip -o link show | wc -l) - 1))

if [ $nombre_interfaces -gt 1 ]; then
    echo "Il y a $nombre_interfaces interfaces réseau disponibles."

    read -p "Voulez vous mettre en place de l'aggregation de lien [y|n] " choice
    if[$choice == "yes" | $choice == "y" | $choice ==  "Y"] then
                Afficher_interfaces
                read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
                read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
                echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
                # Ajouter ici des commandes pour configurer l'agrégation avec les interfaces choisies
    fi
    read -p "Voulez vous mettre en place un systeme nftables [y|n] " choice
    if["$choice" == (yes|y|Y)] then
                echo "Vous avez choisi d'utiliser nftables."
                Afficher_interfaces
                read -p "Quelle interface sera utiliser comme LAN ? " lan_interface
                read -p "Quelle interface sera utiliser comme WAN ? " wan_interface
                echo "Interfaces choisies pour le LAN : $lan_interface, pour le WAN : $wan_interface"
                # Ajouter ici des commandes pour configurer nftables avec les interfaces choisies
    fi
else
    echo "Il n'y a qu'une interface réseau disponible."
    read -p "Quelle interface souhaitez-vous utiliser ? " interface
fi

# Le reste du script ici après la sortie de la boucle while
echo "La suite du script après la boucle while."
