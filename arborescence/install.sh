#!/bin/bash

# TO DO
# Put every services in a different script
# Make the file.ini useful
# Implementation of KEA
# Change the name of web site and lets the user chose it
# in the readME need to presice to start the script with the commande bash
# In the end restart every services then do a final check of these services
# MariaDB create an account with random password by default
# Doesn't need to start the script without having root permission by consequences ask the user to create an account 
# Ask to change the password with an script when the first remote connexion is done DeBootStrap 

# THING TO DO BUT NO THE PRIORITIES 
# CONFIGURE THE NETWORK INTERFACE WITH ANOTHER WAY  
# Do the most importante script (the part of Elouen)
# Add the possibility to have an ssl certificat with lets encrypt for an web server
# MariaDB remote connexion

# THING THAT CAN HELP FOR THE FUTUR
# reset to clear the terminal
# source <(grep = config.ini)

if [ "$(id -u)" -eq 0 ]; then
 echo "Ce script ne doit pas être exécuté en tant que root."
    exit 1
fi
cd "$(dirname $0)"  
username="$(whoami)"


echo -e "
                                          ______   __                                         \n
                                         /      \ /  |                                        \n
  ______    ______    ______   _______  /$$$$$$  |$$ |  ______   _______   _______    ______  \n
 /      \  /      \  /      \ /       \ $$ |  $$/ $$ | /      \ /       \ /       \  /      \ \n
/$$$$$$  |/$$$$$$  |/$$$$$$  |$$$$$$$  |$$ |      $$ |/$$$$$$  |$$$$$$$  |$$$$$$$  |/$$$$$$  |\n
$$ |  $$ |$$ |  $$ |$$    $$ |$$ |  $$ |$$ |   __ $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$    $$ |\n
$$ \__$$ |$$ |__$$ |$$$$$$$$/ $$ |  $$ |$$ \__/  |$$ |$$ \__$$ |$$ |  $$ |$$ |  $$ |$$$$$$$$/ \n
$$    $$/ $$    $$/ $$       |$$ |  $$ |$$    $$/ $$ |$$    $$/ $$ |  $$ |$$ |  $$ |$$       |\n
 $$$$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$/  $$/  $$$$$$/  $$/   $$/ $$/   $$/  $$$$$$$/ \n
          $$ |                                                                                \n
          $$ |                                                                                \n
          $$/                                                                                 \n
"


# Fonction to show network interface
Afficher_interfaces() {

    echo "Interfaces disponibles :"
    ip -o link show | awk -F': ' '{print $2}'

}

Recuperer_IP_LAN(){

read -p "Quelle est son interface pour son sous réseaux LAN (exemple: eth0):" Interface_LAN
read -p "Quelle sera son addresse IP cote LAN (exemple: 192.168.1.15):" IP_LAN
read -p "Quelle est le masque du sous réseaux LAN aux format CIDR (24):" Masque_LAN_CIDR
read -p "Quelle est son masque de son sous réseaux LAN (exemple: 255.255.255.0):" Masque_LAN
read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_LAN_SR

}

# Find the number of network interface
nombre_interfaces=$(($(ip -o link show | wc -l) - 1))

# Know if the user chose one of these fonctionality
aggregation=false
nftables=false

if [ $nombre_interfaces -gt 1 ]; then

    echo "Il y a $nombre_interfaces interfaces réseau disponibles."
    read -p "Voulez-vous mettre en place de l'aggregation de liens ? [y|n] " choice_aggregation

    if [ "$choice_aggregation" == "y" ]; then
        
        aggregation=true
        sudo apt -y install ifenslave
        echo ""
        Afficher_interfaces
        echo ""

        read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
        read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
        echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
        echo -e "\nune nouvelle interface nommer bond0 vient d'etre creer\n" 
        # add here commandes to configure l'agréggation with the chosen interfaces

    fi

    read -p "Voulez-vous mettre en place le système nftables ? [y|n] " choice_nftables

    if [ "$choice_nftables" == "y" ]; then

        echo "Vous avez choisi d'utiliser nftables."
        ip a
        Recuperer_IP_LAN
        nftables=true

        read -p "Quelle est son interface pour son sous réseaux NAT (exemple: eth0):" Interface_NAT
        read -p "Quelle sera son addresse IP cote NAT (exemple: 192.168.1.15):" IP_NAT
        read -p "Quelle est le masque du sous réseaux NAT aux format CIDR (24):" Masque_NAT_CIDR
        read -p "Quelle est son masque de son sous réseaux NAT (exemple: 255.255.255.0):" Masque_NAT
        read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR
        read -p "Quelle est l'IP du routeur du réseaux NAT (exemple: 192.168.1.254):" Routeur

        # Configure Nftables
        sudo sed -i \
          -e "s/{Interface_NAT}/$Interface_NAT/g" \
          -e "s/{IP_NAT_SR}/$IP_NAT_SR/g" \
          -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
          -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
          -e "s/{Interface_LAN}/$Interface_LAN/g" \
          -e "s/{IP_NAT_SR}/$IP_NAT_SR/g" \
          -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
          -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
          -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
          ressource/network/nftables.conf
        apt -y install nftables
        mv ressource/network/nftables.conf /etc/nftables.conf


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

case "$aggregation$nftables" in
  "truetrue")

    sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Interface_NAT}/$Interface_NAT/g" \
        -e "s/{IP_NAT}/$IP_NAT/g" \
        -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        -e "s/{interface1}/$interface1/g" \
        -e "s/{interface2}/$interface2/g" \
        ressource/network/interfacesAggregationNftables

    mv ressource/network/interfacesAggregationNftables /etc/network/interfaces
    ;;

  "falsetrue")

    sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Interface_NAT}/$Interface_NAT/g" \
        -e "s/{IP_NAT}/$IP_NAT/g" \
        -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        ressource/network/interfacesNftables

    mv ressource/network/interfacesNftables /etc/network/interfaces
    ;;

  "truefalse")

    sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        -e "s/{interface1}/$interface1/g" \
        -e "s/{interface2}/$interface2/g" \
        ressource/network/interfacesAggregation

    mv ressource/network/interfacesAggregation /etc/network/interfaces
    ;;

  "falsefalse")

    sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        ressource/network/interfaces

    mv ressource/network/interfaces /etc/network/interfaces
    ;;

  *)
    echo "erreur"
    ;;
esac

systemctl restart networking
service networking restart
ip r add default via $Routeur

# Update & install of paquets needed
apt update && apt -y upgrade
apt -y install wget

#wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso

.\aggregation/aggregation.sh
.\core/core.sh
.\database/database.sh
.\ debootstrap/debootstrap.sh
.\dhcp/dhcp.sh
.\ dns/dns.sh
.\ http/http.sh
.\ interface/interface.sh
.\ nfs/nfs.sh
.\ nftables/nftables.sh
.\ tftp/tftp.sh

# Add Boot file for linux (vmlinuz & initrd & grub.cfg)
grub-mknetdir
sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/grub.cfg
mv ressource/grub.cfg /srv/tftp/boot/grub/grub.cfg

# test to restart all the services with only one commande 
systemctl restart isc-dhcp-server.service
systemctl restart bind9.service
systemctl restart atftpd.service
systemctl restart nfs-kernel-server
systemctl restart apache2.service
systemctl restart nftables

echo "Fini "