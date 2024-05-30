#!/bin/bash

# TO DO
# Network part to redo
# Change the name of web site and lets the user chose it
# THREAD !!! debootstrap is way to long
# check errors like to dhcp enabled


# THING TO DO BUT NO THE PRIORITIES
# CONFIGURE THE NETWORK INTERFACE WITH ANOTHER WAY
# Add the possibility to have an ssl certificat with lets encrypt for the web server
# MariaDB remote connexion
# Change the range in dhcp file in funcition of question or file.ini
# Generate the grub.cfg
# Dropbox iso + wget iso url via the web interface
# link to debootstrap only for FR 

clear
echo -e '
                                          ______   __
                                         /      \ /  |
  ______    ______    ______   _______  /$$$$$$  |$$ |  ______   _______    ______
 /      \  /      \  /      \ /       \ $$ |  $$/ $$ | /      \ /       \  /      \
/$$$$$$  |/$$$$$$  |/$$$$$$  |$$$$$$$  |$$ |      $$ |/$$$$$$  |$$$$$$$  |/$$$$$$  |
$$ |  $$ |$$ |  $$ |$$    $$ |$$ |  $$ |$$ |   __ $$ |$$ |  $$ |$$ |  $$ |$$    $$ |
$$ \__$$ |$$ |__$$ |$$$$$$$$/ $$ |  $$ |$$ \__/  |$$ |$$ \__$$ |$$ |  $$ |$$$$$$$$/
$$    $$/ $$    $$/ $$       |$$ |  $$ |$$    $$/ $$ |$$    $$/ $$ |  $$ |$$       |
 $$$$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$/  $$/  $$$$$$/  $$/   $$/  $$$$$$$/
          $$ |
          $$ |
          $$/
'

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

        echo "Beginning of $script"
        source "$script"
        echo "End of $script"

    } 2>&1 | sed "s/^/[$prefix] /" >> "$log_file"

}

if [ $SkipQuestion ]; then

  Recuperer_IP_LAN(){

    read -p "Quelle est son interface pour son sous réseaux LAN (exemple: eth0):" Interface_LAN
    read -p "Quelle sera son addresse IP cote LAN (exemple: 192.168.1.15):" IP_LAN
    read -p "Quelle est le masque du sous réseaux LAN aux format CIDR (24):" Masque_LAN_CIDR
    read -p "Quelle est son masque de son sous réseaux LAN (exemple: 255.255.255.0):" Masque_LAN
    read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_LAN_SR

  }

  read -p "What will be the username for maintenance OS : " UserDebootStrap
  read -p "and what will be is password : " PasswordDeBootStrap
  read -p "For the database what will be the username : " userMariaDB
  read -p "And what will be is password : " PasswordMariaDBUser
  
  read -p "Voulez-vous mettre en place de l'aggregation de liens ? [y|n] " choice_aggregation
  [ "$choice_aggregation" == "y" ] && ActivationAggregation=true

  read -p "Voulez-vous mettre en place le système nftables ? [y|n] " choice_nftables
  if [ "$choice_nftables" == "y" ]; then 
  
    ActivationNftables=true

    ip a && ip r
    read -p "Quelle est son interface pour son sous réseaux NAT (exemple: eth0):" Interface_NAT
    read -p "Quelle sera son addresse IP cote NAT (exemple: 192.168.1.15):" IP_NAT
    read -p "Quelle est le masque du sous réseaux NAT aux format CIDR (24):" Masque_NAT_CIDR
    read -p "Quelle est son masque de son sous réseaux NAT (exemple: 255.255.255.0):" Masque_NAT
    read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR
    read -p "Quelle est l'IP du routeur du réseaux NAT (exemple: 192.168.1.254):" Routeur

  fi

  ip a && ip r
  Recuperer_IP_LAN

fi

case "$ActivationAggregation$ActivationNftables" in
  "truetrue")

    log_prefix "aggregation" aggregation/aggregation.sh || { echo -e "something went wrong during the installation of the aggregation\nGo see the log on /var/log/openClone" && exit 1; }
    log_prefix "nftables" nftables/nftables.sh || { echo -e "something went wrong during the installation of the nftable\nGo see the log on /var/log/openClone" && exit 1; }

    sed -i \
      -e "s/{Interface_NAT}/$Interface_NAT/g" \
      -e "s/{IP_NAT}/$IP_NAT/g" \
      -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
      -e "s/{Routeur}/$Routeur/g" \
      -e "s/{IP_LAN}/$IP_LAN/g" \
      -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
      -e "s/{interface1}/$interface1/g" \
      -e "s/{interface2}/$interface2/g" \
    resources/network_interfaces/interfacesAggregationNftables
    cp resources/network_interfaces/interfacesAggregationNftables /etc/network/interfaces
    ;;

  "falsetrue")
    
    log_prefix "nftables" nftables/nftables.sh || { echo -e "something went wrong during the installation of the nftables\nGo see the log on /var/log/openClone" && exit 1; }
    sed -i \
      -e "s/{Interface_LAN}/$Interface_LAN/g" \
      -e "s/{IP_LAN}/$IP_LAN/g" \
      -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
      -e "s/{Interface_NAT}/$Interface_NAT/g" \
      -e "s/{IP_NAT}/$IP_NAT/g" \
      -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
      -e "s/{Routeur}/$Routeur/g" \
    resources/network_interfaces/interfacesNftables
    cp resources/network_interfaces/interfacesNftables /etc/network/interfaces
    ;;

  "truefalse")
    
    log_prefix "aggregation" aggregation/aggregation.sh || { echo -e "something went wrong during the installation of the aggregation\nGo see the log on /var/log/openClone" && exit 1; }
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

    read -p "Quelle est l'IP du routeur du réseaux :" Routeur

    sed -i \
      -e "s/{Interface_LAN}/$Interface_LAN/g" \
      -e "s/{IP_LAN}/$IP_LAN/g" \
      -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
      -e "s/{Routeur}/$Routeur/g" \
    resources/network_interfaces/interfaces

    cp resources/network_interfaces/interfaces /etc/network/interfaces
    ;;

  *)
    echo "something went wrong"
    exit 1
    ;;
esac

systemctl restart networking
ip r add default via $Routeur


# Update & install of paquets needed
apt-get update && apt-get -y upgrade

# apt-get -y install wget
#wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso


echo -e "\nInstallation of the DHCP server . . . \n"

[ $ActivationDHCP ] && log_prefix "dhcp" "resources/dhcp/dhcp.sh" && echo -e "DHCP installed & configure correctly\n" || { echo -e "something went wrong during the installation of the DHCP SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Installation of the DNS server . . . \n"

[ $ActivationDNS ] && log_prefix "dns" "resources/dns/dns.sh" && echo -e "DNS installed & configure correctly\n" || { echo -e "something went wrong during the installation of the DNS SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Installation of the DataBase server . . . \n"

[ $ActivationMariaDB ] && log_prefix "database" "resources/database/database.sh" && echo -e "Database installed & configure correctly\n" || { echo -e "something went wrong during the installation of the DATABASE\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Installation of the Web Server . . .\n"

[ $ActivationHTTP ] && log_prefix "http" "resources/http/http.sh" && echo -e "Web Server installed & configure correctly\n" || { echo -e "something went wrong during the installation of the WEB SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Installation of the NFS server . . . \n"

[ $ActivationNFS ] && log_prefix "nfs" "resources/nfs/nfs.sh" && echo -e "NFS installed & configure correctly\n" || { echo -e "something went wrong during the installation of the NFS SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Installation of the DeBootStrap service (this can take a will) . . . \n"

[ $ActivationDeBootStrap ] && log_prefix "debootstrap" "resources/debootstrap/debootstrap.sh" && echo -e "DeBootStrap installed & configure correctly\n" || { echo -e "something went wrong during the installation of the DEBOOTSTRAP\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Installation of the TFTP server . . . \n"

[ $ActivationTFTP ] && log_prefix "tftp" "resources/tftp/tftp.sh" && echo -e "TFTP installed & configure correctly\n" || { echo -e "something went wrong during the installation of the TFTP SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Creation of the Boot files for the  maintenace OS . . . \n"

log_prefix "core" "resources/core/core.sh" || && echo -e "Core files create & configure correctly\n" { echo -e "something went wrong during the creation of the BOOT FILES for linux\nGo see the log on /var/log/openClone" && exit 1; }

wait


system(){
  {

    echo "restarting services ..."

    # Restart every service so they take into account their new configuration
    systemctl restart bind9 atftpd nfs-kernel-server apache2 nftables mariadb

    if [ $Kea ]; then
      systemctl restart kea-dhcp4-server
    elif [ $Isc ]; then
      systemctl restart isc-dhcp-server
    fi

    echo "services restarted ..."

  } 2>&1 | sed "s/^/[systemctl] /" >> "$log_file"
}

system || { echo -e "something went wrong during the restart of the services\nGo see the log on /var/log/openClone" && exit 1; }

if [ $Kea ]; then
  services=("kea-dhcp4-server" "bind9" "atftpd" "nfs-kernel-server" "apache2" "nftables" "mariadb.service")
elif [ $Isc ]; then
  services=("isc-dhcp-server" "bind9" "atftpd" "nfs-kernel-server" "apache2" "nftables" "mariadb.service")
fi

for service in "${services[@]}"; do
  echo "[$service]"
  systemctl status "$service" | grep -E 'Loaded:|Active:'
  echo
done

sleep 1 && clear

echo -e "\nAs a reminder, for the maintenance OS:\nusername : $UserDebootStrap \npassword : $PasswordDeBootStrap\n\nINSTALLATION FINISHED"