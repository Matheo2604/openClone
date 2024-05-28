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
        apt -y install ifenslave
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
          ressource/network/nftables.conf
        apt -y install nftables
        mv ressource/network/nftables.conf /etc/nftables.conf
        systemctl restart nftables

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
ip r add default via $Routeur


# Update & install of paquets needed
apt update && apt -y upgrade
apt -y install apache2 atftpd nfs-kernel-server debootstrap php bind9 isc-dhcp-server wget mariadb-server grub-common


#!!!!!!!!!!!wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso

# alternative for dhcp & dns non-deprecated with "kea"


# Configure TFTP server

mkdir /srv/tftp
mv ressource/serveur_transfert/atftpd /etc/default/atftpd
systemctl restart atftpd.service
chmod -R ugo+rw /srv/tftp/


# Add Boot file for linux (vmlinuz & initrd & grub.cfg)

grub-mknetdir
sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/grub.cfg
mv ressource/grub.cfg /srv/tftp/boot/grub/grub.cfg



#Configure NFS server


mkdir /srv/nfs
chown -R root:root /srv/nfs
chmod 744 /srv/nfs
sed -i \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
  ressource/serveur_transfert/exports
mv ressource/serveur_transfert/exports /etc/exports
exportfs -a
 systemctl restart nfs-kernel-server


# Configure Debootstrap


mkdir /srv/nfs/debian
debootstrap --arch amd64 bookworm /srv/nfs/debian http://ftp.fr.debian.org/debian
mount -t proc none /srv/nfs/debian/proc
mount -o bind /dev /srv/nfs/debian/dev
chroot /srv/nfs/debian /bin/bash << EOT

  apt update && apt full-upgrade
  apt install -y linux-image-amd64 partclone dialog sudo
  useradd -m "$username" -s /bin/bash
  echo "$username:password" | chpasswd
  usermod -aG sudo "$username"
  (crontab -l 2>/dev/null; echo "@reboot /srv/scripts/ACHANGER.sh") | crontab -

EOT
# PASSWORD AND PATH TO SCRIPT HAVE TO CHANGE

mv ressource/linux_maintenance/sudoers /srv/nfs/debian/etc/sudoers
mv ressource/linux_maintenance/logind.conf /srv/nfs/debian/etc/systemd/logind.conf
mkdir /srv/nfs/debian/etc/systemd/system/getty@tty1.service.d/
mv ressource/linux_maintenance/override.conf /srv/nfs/debian/etc/systemd/system/getty@tty1.service.d/override.conf


# Configure WEB server / HTTP

mv ressource/www /srv/www
mv ressource/serveur_transfert/site.conf /etc/apache2/sites-available/
a2dissite 000-default.conf
a2ensite site.conf
chown www-data /srv/www/ -Rf
systemctl restart apache2.service


#PB
mysql  << EOL

  CREATE DATABASE openclonedb;
  CREATE USER 'responsable' IDENTIFIED BY 'felix22';
  grant all privileges on openclone.* to 'responsable';
  CREATE USER 'consultant' IDENTIFIED BY 'felix22';
  GRANT SELECT ON openclone.* TO 'consultant';
  use openclonedb;
  CREATE TABLE clients(id INT PRIMARY KEY NOT NULL, MAC_Address VARCHAR(17), IP_Address VARCHAR(15),
  Hostname VARCHAR(30));

EOL
systemctl restart mariadb

#mysql --password=1234 --user=root --host=localhost << eof
#create database ownclouddb;
#grant all privileges on ownclouddb.* to root@localhost identified by "1234";
#flush privileges;
#exit;
#eof
#cd /srv/www/openClone
#sudo -u www-data php occ maintenance:install \
#   --database "mysql" \
#   --database-name "openclonedb" \
#   --database-user "root"\
#   --database-pass "1234" \
#   --admin-user "root" \
#   --admin-pass "1234"


# Configuration du DHCP
#!!!! if no nftables routeur needed

IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." " ") )
sed -i \
  -e "s/{IP_LAN}/$IP_LAN/g" \
  -e "s/{Masque_LAN}/$Masque_LAN/g" \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
  -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
  -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
  ressource/dhcpd.conf
mv ressource/dhcpd.conf /etc/dhcp/dhcpd.conf
chmod 666 /etc/default/isc-dhcp-server 
echo -e "INTERFACESv4=\""$Interface_LAN"\"\nINTERFACESv6=\"\"" > /etc/default/isc-dhcp-server 
chmod 644 /etc/default/isc-dhcp-server 
systemctl restart isc-dhcp-server.service



# Configuration DNS

#PB
sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/dns/site22.fr.zone
mv ressource/dns/site22.fr.zone /var/cache/bind/site22.fr.zone
sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/dns/dns.fr.reverse
mv ressource/dns/dns.fr.reverse /var/cache/bind/dns.fr.reverse
sed -i \
  -e "s/{ip0}/${IP_LAN_TABLEAU[0]}/g" \
  -e "s/{ip1}/${IP_LAN_TABLEAU[1]}/g" \
  -e "s/{ip2}/${IP_LAN_TABLEAU[2]}/g" \
  ressource/dns/named.conf.local
mv ressource/dns/named.conf.local /etc/bind/named.conf.local
systemctl restart bind9.service

echo "Fini "