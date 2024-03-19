#!/bin/bash

### Assigner les paramètres à des variables ###

cd "$(dirname $0)"

# Vérifie si l'utilisateur est root
if [ "$(id -u)" -eq 0 ]; then
 echo "Ce script ne doit pas être exécuté en tant que root."
    exit 1
fi

# Utilise le nom de l'utilisateur actuel pour celui du Debootstrap
username="$(whoami)"

# Librairie pour semi-graphique
sudo apt -y install dialog

ip link show | grep -o '^[0-9]*:' | wc -l

#read -p "Quelle sera l'addresse IP de son sous réseaux LAN :" IP_LAN
#IP_LAN_TABLEAU=( $(echo $IP_LAN | tr "." "\n") )
#read -p "Quelle est son masque de son sous réseaux LAN :" Masque_LAN
#read -p "Quelle est son interface pour son sous réseaux LAN :" Interface_LAN
#read -p "Quelle sera l'addresse IP de son sous réseaux NAT :" IP_NAT
#IP_NAT_TABLEAU=( $(echo $IP_NAT | tr "." "\n") )
#read -p "Quelle est son masque de son sous réseaux NAT :" Masque_NAT
#read -p "Quelle est son interface pour son sous réseaux NAT :" Interface_NAT
#read -p "Quelle est l'IP du routeur du réseaux NAT :" Routeur_NAT
#sudo apt install -y bc
#IP_LAN_SR="$(./ObtentionIPSousReseau.sh $IP_LAN $Masque_LAN)"
#echo $IP_LAN_SR
#Masque_LAN_CIDR="$(./ObtentionMasqueCIDR.sh $IP_LAN $Masque_LAN)"
#echo $Masque_LAN_CIDR
#IP_NAT_SR="$(./ObtentionIPSousReseau.sh $IP_NAT $Masque_NAT)"
#echo $IP_NAT_SR
#Masque_NAT_CIDR="$(./ObtentionMasqueCIDR.sh $IP_NAT $Masque_NAT)"
#echo $Masque_NAT_CIDR*/

# A refaire
# echo >> 
sudo sed -i "s/{Interface_NAT}/$Interface_NAT/g" ressource/interfaces
sudo sed -i "s/{IP_Nat}/$IP_Nat/g" ressource/interfaces
sudo sed -i "s/{Routeur_NAT}/$Routeur_NAT/g" ressource/interfaces
sudo sed -i "s/{Interface_LAN}/$Interface_LAN/g" ressource/interfaces
sudo sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/interfaces
sudo sed -i "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" ressource/interfaces
sudo sed -i "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" ressource/interfaces
sudo mv ressource/interfaces /etc/network/interfaces


#auto eno1
#iface eno1 inet static
#        address 172.20.15.153/16
#        gateway 172.20.255.251
#        dns-nameservers 1.1.1.1
#auto bond0
#iface bond0 inet static
#        address 192.168.150.153/24
#        bond-slaves ens1 eno2


# Mise a jour et installation des paquets
sudo apt update && sudo apt upgrade

sudo apt -y install apache2 atftpd nfs-kernel-server debootstrap php bind9 isc-dhcp-server wget nftables
#alternative du dhcp et dns non obsolete avec "kea"

# A décommenter a fin du script !!!
#wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-live-amd64.iso

# Configuration du serveur TFTP
sudo sudo mkdir /srv/tftp

sudo mv ressource/atftpd /etc/default/atftpd

sudo systemctl restart atftpd.service

sudo chmod -R ugo+rw /srv/tftp/



# Ajouts des fichiers de boot linux (vmlinuz & initrd & grub.cfg & core.0 & core.efi)
sudo grub-mknetdir

sudo sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/grub.cfg

sudo mv ressource/grub.cfg /srv/tftp/boot/grub/grub.cfg



#Configuration du serveur NFS
sudo mkdir /srv/nfs

sudo chown -R root:root /srv/nfs

sudo chmod 777 /srv/nfs

sudo sed -i "s/{IP_LAN_SR}/$IP_LAN_SR/g" ressource/exports 

sudo sed -i "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" ressource/exports

sudo sudo mv ressource/exports /etc/exports

sudo exportfs -a

sudo systemctl restart nfs-kernel-server



# Configuration du Debootstrap
sudo sudo mkdir /srv/nfs/debian

sudo debootstrap --arch amd64 bookworm /srv/nfs/debian http://ftp.fr.debian.org/debian

sudo mount -t proc none /srv/nfs/debian/proc

sudo mount -o bind /dev /srv/nfs/debian/dev

sudo chroot /srv/nfs/debian /bin/bash << EOT


apt update && apt full-upgrade

apt install -y linux-image-amd64 partclone dialog sudo


sudo useradd -m "$username" -s /bin/bash

echo "$username:password" | sudo chpasswd

sudo usermod -aG sudo "$username"

EOT


sudo sed -i "s/{username}/$username/g" ressource/profile

sudo mv ressource/profile /srv/nfs/debian/home/$username/.profile

sudo sudo mv ressource/sudoers /srv/nfs/debian/ect/sudoers

sudo sudo mv ressource/logind.conf /srv/nfs/debian/etc/systemd/logind.conf

sudo mkdir /srv/nfs/debian/etc/systemd/system/getty@tty1.service.d/

sudo sudo mv ressource/override.conf /srv/nfs/debian/etc/systemd/system/getty@tty1.service.d/override.conf



# Configuration du serveur WEB / HTTP
sudo sudo mv ressource/www /srv/www

sudo sudo mv ressource/site.conf /etc/apache2/site-available/

sudo a2dissite 000-default.conf

sudo a2ensite site.conf

sudo chown www-data /srv/www/ -Rf

sudo systemctl restart apache2.service


# Configuration MariaDB 
#couille dans le paté ouverture mariadb
use mariadb << EOT

CREATE DATABASE openclone;

use openclone;

CREATE USER 'responsable' IDENTIFIED BY 'felix22';

grant all privileges on openclone.* to 'responsable';

CREATE USER 'consultant' IDENTIFIED BY 'felix22';

GRANT SELECT ON openclone.* TO 'consultant';

CREATE TABLE clients(id INT PRIMARY KEY NOT NULL, MAC_Address VARCHAR(17), IP_Address VARCHAR(15),

Hostname VARCHAR(30));

EOT


# Configuration du DHCP
sudo sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/dhcpd.conf

sudo sed -i "s/{Masque_LAN}/$Masque_LAN/g" ressource/dhcpd.conf

sudo sed -i "s/{IP_LAN_SR}/$IP_LAN_SR/g" ressource/dhcpd.conf

sudo sudo mv ressource/dhcpd.conf /etc/dhcp/dhcpd.conf

sudo systemctl restart isc-dhcp-server.service



# Configuration DNS
sudo sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/dns/site22.fr.zone

sudo sudo mv ressource/dns/site22.fr.zone /var/cache/bind/site22.fr.zone

sudo sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/dns/dns.fr.reverse

sudo sudo mv ressource/dns/dns.fr.reverse /var/cache/bind/dns.fr.reverse

sudo sed -i "s/{IP_LAN_TABLEAU[0]}/$IP_LAN_TABLEAU[0]/g" ressource/dns/dns.fr.reverse

sudo sed -i "s/{IP_LAN_TABLEAU[1]}/$IP_LAN_TABLEAU[1]/g" ressource/dns/dns.fr.reverse

sudo sed -i "s/{IP_LAN_TABLEAU[2]}/$IP_LAN_TABLEAU[2]/g" ressource/dns/dns.fr.reverse

sudo sudo mv ressource/dns/named.conf.local /etc/bind/named.conf.local

sudo systmeclt restart bind9.service



# Configuration Nftables
sudo sed -i "s/{Interface_NAT}/$Interface_NAT/g" ressource/nftables.conf

sudo sed -i "s/{IP_NAT_SR}/$IP_NAT_SR/g" ressource/nftables.conf

sudo sed -i "s/{IP_LAN_SR}/$IP_LAN_SR/g" ressource/nftables.conf

sudo sed -i "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" ressource/nftables.conf

sudo sed -i "s/{Interface_LAN}/$Interface_LAN/g" ressource/nftables.conf

sudo sed -i "s/{IP_NAT_SR}/$IP_NAT_SR/g" ressource/nftables.conf

sudo sed -i "s/{IP_LAN_SR}/$IP_LAN_SR/g" ressource/nftables.conf

sudo sed -i "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" ressource/nftables.conf

sudo sed -i "s/{Masque_NAT_CIDR}/$Masque_NAT_CIDR/g" ressource/nftables.conf

sudo sudo mv ressource/nftables.conf /etc/nftables.conf

sudo systemctl restart nftables.service


echo "Installation terminee "