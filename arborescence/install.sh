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
# Change the range in dhcp file in funcition of question or file.ini 

# THING THAT CAN HELP FOR THE FUTUR
# reset to clear the terminal
# source <(grep = config.ini)
# to debug dhcp do dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Verify if the id of the user is anything other then 0 (0 = root id) 
if [ "$EUID" -ne 0 ];then
 echo "Start the script with root permission"
 exit 1
fi

# Verify if the user that start the script is in the openClone folder 
cd "$(dirname $0)"  

rm resources/log
source <(grep = config.ini)

echo -e "
                                          ______   __                               \n
                                         /      \ /  |                              \n
  ______    ______    ______   _______  /$$$$$$  |$$ |  ______   _______    ______  \n
 /      \  /      \  /      \ /       \ $$ |  $$/ $$ | /      \ /       \  /      \ \n
/$$$$$$  |/$$$$$$  |/$$$$$$  |$$$$$$$  |$$ |      $$ |/$$$$$$  |$$$$$$$  |/$$$$$$  |\n
$$ |  $$ |$$ |  $$ |$$    $$ |$$ |  $$ |$$ |   __ $$ |$$ |  $$ |$$ |  $$ |$$    $$ |\n
$$ \__$$ |$$ |__$$ |$$$$$$$$/ $$ |  $$ |$$ \__/  |$$ |$$ \__$$ |$$ |  $$ |$$$$$$$$/ \n
$$    $$/ $$    $$/ $$       |$$ |  $$ |$$    $$/ $$ |$$    $$/ $$ |  $$ |$$       |\n
 $$$$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$/  $$/  $$$$$$/  $$/   $$/  $$$$$$$/ \n
          $$ |                                                                      \n
          $$ |                                                                      \n
          $$/                                                                       \n
"

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
        # add here commandes to configure l'agréggation with the chosen interfaces

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

    source .\aggregation/aggregation.sh >> resources/log
    source .\nftables/nftables.sh >> resources/log
    ;;

  "falsetrue")

    source .\nftables/nftables.sh >> resources/log
    ;;

  "truefalse")
    
    source .\aggregation/aggregation.sh >> resources/log
    ;;

  "falsefalse")

    sed -i \
        -e "s/{Interface_LAN}/$Interface_LAN/g" \
        -e "s/{IP_LAN}/$IP_LAN/g" \
        -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
        -e "s/{Routeur}/$Routeur/g" \
        ressource/network/interfaces

    cp ressource/network/interfaces /etc/network/interfaces
    ;;

  *)
    echo "erreur"
    ;;
esac

systemctl restart networking
ip r add default via $Routeur

# Update & install of paquets needed
apt update && apt -y upgrade

# apt -y install wget
#wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso

case "true -eq true" in
  "true")
    source .\interface/interface.sh >> resources/log

  "true")
    if [ "$ActivationDHCP" = true ]; then
      source .\dhcp/dhcp.sh >> resources/log
    fi

  "true")
    if [ "$ActivationDNS" = true ]; then
      source .\dns/dns.sh >> resources/log
    fi

  "true")
    if [ "$ActivationMariaDB" = true ]; then
      source .\database/database.sh >> resources/log
    fi

  "true")
    if [ "$ActivationHTTP" = true ]; then
      source .\http/http.sh >> resources/log
    fi

  "true")
    if [ "$ActivationNFS" = true ]; then
      source .\nfs/nfs.sh >> resources/log
    fi

  "true")
    if [ "$ActivationTFTP" = true ]; then
      source .\tftp/tftp.sh >> resources/log
    fi

  "true")
    if [ "$ActivationDeBootStrap" = true ]; then
      source .\debootstrap/debootstrap.sh >> resources/log
    fi

  "true")
      source .\core/core.sh >> resources/log
  ;;

  *)
    echo "Something went wrong"
    ;;
esac

# Restart every service so they take into account the new configuration
echo -e "\n [Systemctl Restart]" 
systemctl restart isc-dhcp-server bind9 atftpd nfs-kernel-server apache2 nftables mariadb >> resources/log

echo "Done"