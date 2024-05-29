#!/bin/bash

# TO DO
# Copied all the scripts needed in the DeBootStrap
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
# Dropbox iso + wget iso url via the web interface

echo -e "
                                          ______   __                               \n
                                         /      \ /  |                              \n
  ______    ______    ______   _______  /&&&&&&  |&& |  ______   _______    ______  \n
 /      \  /      \  /      \ /       \ && |  &&/ && | /      \ /       \  /      \ \n
/&&&&&&  |/&&&&&&  |/&&&&&&  |&&&&&&&  |&& |      && |/&&&&&&  |&&&&&&&  |/&&&&&&  |\n
&& |  && |&& |  && |&&    && |&& |  && |&& |   __ && |&& |  && |&& |  && |&&    && |\n
&& \__&& |&& |__&& |&&&&&&&&/ && |  && |&& \__/  |&& |&& \__&& |&& |  && |&&&&&&&&/ \n
&&    &&/ &&    &&/ &&       |&& |  && |&&    &&/ && |&&    &&/ && |  && |&&       |\n
 &&&&&&/  &&&&&&&/   &&&&&&&/ &&/   &&/  &&&&&&/  &&/  &&&&&&/  &&/   &&/  &&&&&&&/ \n
          && |                                                                      \n
          && |                                                                      \n
          &&/                                                                       \n
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

source bash interface/interface.sh

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