#!/bin/bash

# TO DO
# In DeBootStrap need to install console-data for azerty but post-install
# MariaDB possibility to create an account with random password by default
# Ask to change the password with an script when the first remote connexion is done DeBootStrap
# Change the name of web site and lets the user chose it
# in the readME need to presice to start the script with the commande bash


# THING TO DO BUT NO THE PRIORITIES
# CONFIGURE THE NETWORK INTERFACE WITH ANOTHER WAY
# Add the possibility to have an ssl certificat with lets encrypt for the web server
# MariaDB remote connexion
# Change the range in dhcp file in funcition of question or file.ini
# Generate the grub.cfg
# Dropbox iso + wget iso url via the web interface

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

Recuperer_IP_LAN(){

read -p "Quelle est son interface pour son sous réseaux LAN (exemple: eth0):" Interface_LAN
read -p "Quelle sera son addresse IP cote LAN (exemple: 192.168.1.15):" IP_LAN
read -p "Quelle est le masque du sous réseaux LAN aux format CIDR (24):" Masque_LAN_CIDR
read -p "Quelle est son masque de son sous réseaux LAN (exemple: 255.255.255.0):" Masque_LAN
read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_LAN_SR

}

read -p "What will be the username for maintenance OS" $UserDebootStrap
read -p "What will be is password" $PasswordDeBootStrap
read -p "Voulez-vous mettre en place de l'aggregation de liens ? [y|n] " choice_aggregation

if [ "$choice_aggregation" == "y" ]; then

  ActivationAggregation=true
  apt-get -y install ifenslave
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

    ip a && ip r
    Recuperer_IP_LAN
    ActivationNftables=true

    read -p "Quelle est son interface pour son sous réseaux NAT (exemple: eth0):" Interface_NAT
    read -p "Quelle sera son addresse IP cote NAT (exemple: 192.168.1.15):" IP_NAT
    read -p "Quelle est le masque du sous réseaux NAT aux format CIDR (24):" Masque_NAT_CIDR
    read -p "Quelle est son masque de son sous réseaux NAT (exemple: 255.255.255.0):" Masque_NAT
    read -p "Quelle est l'IP du sous résaux LAN (exemple: 192.168.1.0):" IP_NAT_SR
    read -p "Quelle est l'IP du routeur du réseaux NAT (exemple: 192.168.1.254):" Routeur

    # Configure Nftables
    sed -i \
      -e "s/{Interface_NAT}/$Interface_NAT/g" \
      -e "s/{IP_NAT_SR}/$IP_NAT_SR/g" \
      -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
      -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
      -e "s/{Interface_LAN}/$Interface_LAN/g" \
      -e "s/{IP_NAT_SR}/$IP_NAT_SR/g" \
      -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
      -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
      -e "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" \
      resources/nftables/nftables.conf
    apt-get -y install nftables
    cp resources/nftables/nftables.conf /etc/nftables.conf
    systemctl enable nftables

else

    echo ""
    ip a && ip r
    echo ""
    Recuperer_IP_LA
    read -p "Quelle est l'IP du routeur du réseaux :" Routeur

fi

case "$ActivationAggregation$ActivationNftables" in
  "truetrue")

    #source bash aggregation/aggregation.sh || { echo -e "something went wrong during the installation of the aggregation\nGo see the log on /var/log/openClone" && exit 1; }
    #source bash nftables/nftables.sh || { echo -e "something went wrong during the installation of the nftable\nGo see the log on /var/log/openClone" && exit 1; }
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

    #source bash nftables/nftables.sh || { echo -e "something went wrong during the installation of the nftables\nGo see the log on /var/log/openClone" && exit 1; }
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

    #source bash aggregation/aggregation.sh || { echo -e "something went wrong during the installation of the aggregation\nGo see the log on /var/log/openClone" && exit 1; }
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
apt-get update && apt-get -y upgrade

# apt-get -y install wget
#wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso


echo -e "\nInstallation of the DHCP server . . . \n"

[ $ActivationDHCP ] && log_prefix "dhcp" "resources/dhcp/dhcp.sh" || { echo -e "something went wrong during the installation of the DHCP SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "DHCP installed & configure correctly\n\nInstallation of the DNS server . . . \n"

[ $ActivationDNS ] && log_prefix "dns" "resources/dns/dns.sh" || { echo -e "something went wrong during the installation of the DNS SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "DNS installed & configure correctly\n\nInstallation of the DataBase server . . . \n"

[ $ActivationMariaDB ] && log_prefix "database" "resources/database/database.sh" || { echo -e "something went wrong during the installation of the DATABASE\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Database installed & configure correctly\n\nInstallation of the Web Server . . .\n"

[ $ActivationHTTP ] && log_prefix "http" "resources/http/http.sh" || { echo -e "something went wrong during the installation of the WEB SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Web Server installed & configure correctly\n\nInstallation of the NFS server . . . \n"

[ $ActivationNFS ] && log_prefix "nfs" "resources/nfs/nfs.sh" || { echo -e "something went wrong during the installation of the NFS SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "NFS installed & configure correctly\n\nInstallation of the DeBootStrap service (this can take a will) . . . \n"

[ $ActivationDeBootStrap ] && log_prefix "debootstrap" "resources/debootstrap/debootstrap.sh" || { echo -e "something went wrong during the installation of the DEBOOTSTRAP\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "DeBootStrap installed & configure correctly\n\nInstallation of the TFTP server . . . \n"

[ $ActivationTFTP ] && log_prefix "tftp" "resources/tftp/tftp.sh" || { echo -e "something went wrong during the installation of the TFTP SERVER\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "TFTP installed & configure correctly\n\nCreation of the Boot files for the  maintenace OS . . . \n"

log_prefix "core" "resources/core/core.sh" || { echo -e "something went wrong during the creation of the BOOT FILES for linux\nGo see the log on /var/log/openClone" && exit 1; }

echo -e "Core files create & configure correctly\n\n"


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

echo -e "\nAs a reminder, for the maintenance OS:\nusername : $UserDebootStrap \npassword : $PasswordDeBootStrap\nINSTALLATION FINISHED"