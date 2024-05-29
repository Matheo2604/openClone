#!/bin/bash

# TO DO
# Implementation of KEA
# MariaDB create an account with random password by default
# Doesn't need to start the script without having root permission by consequences ask the user to create an account 
# Ask to change the password with an script when the first remote connexion is done DeBootStrap 
# Change the name of web site and lets the user chose it
# in the readME need to presice to start the script with the commande bash


# THING TO DO BUT NO THE PRIORITIES 
# CONFIGURE THE NETWORK INTERFACE WITH ANOTHER WAY  
# Do the most importante script (the part of Elouen)
# Add the possibility to have an ssl certificat with lets encrypt for an web server
# MariaDB remote connexion
# Change the range in dhcp file in funcition of question or file.ini 
# Generate the grub.cfg

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
# Verify if the id of the user is anything other then 0 (0 = root id) 
if [ "$EUID" -ne 0 ];then
 echo "Start the script with root permission"
 exit 1
fi

# Verify if the user that start the script is in the openClone folder 
# to test if working when user is in another folder
cd "$(dirname $0)"  

# Get all the variables from config.ini file
source <(grep = config.ini)

# create a prefix before for the log according of the part where it come from
log_prefix() {
    local prefix=$1
    local script=$2
    {
        echo "[$prefix] Beginning of $script"
        source "$script"
        echo "[$prefix] End of $script"
    } 2>&1 | sed "s/^/[$prefix] /" >> "$log_file"
}

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

# Update & install of paquets needed
apt update && apt -y upgrade

# apt -y install wget
#wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso

log_prefix "interfaces" "interface/interface.sh" || { echo -e "something went wrong during the initialization of the interface\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationDHCP ] && log_prefix "dhcp" "dhcp/dhcp.sh" || { echo -e "something went wrong during the installation of the DHCP SERVER\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationDNS ] && log_prefix "dns" "dns/dns.sh" || { echo -e "something went wrong during the installation of the DNS SERVER\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationMariaDB ] && log_prefix "database" "database/database.sh" || { echo -e "something went wrong during the installation of the DATABASE\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationHTTP ] && log_prefix "http" "http/http.sh" || { echo -e "something went wrong during the installation of the WEB SERVER\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationNFS ] && log_prefix "nfs" "nfs/nfs.sh" || { echo -e "something went wrong during the installation of the NFS SERVER\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationDeBootStrap ] && log_prefix "debootstrap" "debootstrap/debootstrap.sh" || { echo -e "something went wrong during the installation of the DEBOOTSTRAP\nGo see the log on /var/log/openClone" && exit 1; }
[ $ActivationTFTP ] && log_prefix "tftp" "tftp/tftp.sh" || { echo -e "something went wrong during the installation of the TFTP SERVER\nGo see the log on /var/log/openClone" && exit 1; }
log_prefix "core" "core/core.sh" || { echo -e"something went wrong during the creation of the BOOT FILES for linux\nGo see the log on /var/log/openClone" && exit 1; }

system(){
  {
  echo "restarting serices ..."
  # Restart every services so they take into account there new configuration
  systemctl restart isc-dhcp-server bind9 atftpd nfs-kernel-server apache2 nftables mariadb 
  if [ "$Kea" = true ]; then
  systemctl restart kea-dhcp4-server
  elif [ "$isc-dhcp" = true ]; then
  systemctl restart isc-dhcp-server
  fi
  echo "services restart ..."
  }2>&1 | sed "s/^/[systemctl] /" >> "$log_file"
}

system || { echo -e "something went wrong during the restart of the services\nGo see the log on /var/log/openClone" && exit 1; }

echo "Done"