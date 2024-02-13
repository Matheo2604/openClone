#!/bin/bash


# Assigner les paramètres à des variables

read -p "Quelle nom d'utilisateur voudrez vous pour votre linux de mainteantce :"username

read -p "Entrer son mot de passe :"password

read -p "Quelle sera l'addresse IP du serveur :"IP

read -p "Quelle est son masque de réseau :"masque

read -p "Quelle est son interface :"interface

read -p "Quelle sera le sous réseau dans le quel il operera en CIDR(192.168.1.0/24):"IPSRCIDR

read -p "Quelle est sa \"Gateaway\" :" gateaway


# Mise a jour et installation des paquets

sudo apt update && sudo apt upgrade

sudo apt install apache2 atftpd nfs-kernel-server debootstrap php bind9 isc-dhcp-server

#sudo apt install apache2 atftpd nfs-kernel-server debootstrap php isc-kea

# Mise en place du serveur TFTP

sudo mkdir /srv/tftp

sudo echo -e "allow-hotplug $interface\inface $interface inet static\naddress $IP\nnetmask $masque\ngateway $gateaway\ndns-nameservers $IP ">> /etc/network/interfaces

sudo echo "USE_INETD=true" >>/etc/default/atftpd

sudo systemctl restart atftpd.service

sudo chmod -R ugo+rw /srv/tftp/


# Ajouts des fichiers de boot linux (vmlinuz & initrd & grub.cfg)

sudo grub-mknetdir

sudo echo -e "insmod http\n\nmenuentry 'Boot OpenClone' {\n\n\tset root=(http,$IP)\n\n\techo 'Chargement de vmlinuz ...'\n\tlinux /download/vmlinuz root=/dev/nfs nfsroot=$IP:/srv/nfs/debian rw\n\n\techo 'Chargement de initrd.img ...'\n\tinitrd /download/initrd.img\n\n}\n\nmenuentry 'reboot' {\n\n\techo 'Au revoir !'\n\treboot\n\n}" > /srv/tftp/boot/grub/grub.cfg


#Mise en place du serveur NFS

sudo chown -R root:root /srv/nfs

sudo chmod 777 /srv/nfs

sudo echo "/srv/nfs/amd64 $IPSRCIDR(rw,no_subtree_check,no_root_squash) //ro pour read-only" > /etc/exports

sudo exportfs -a

sudo systemctl restart nfs-kernel-server

sudo grub-mknetdir


# Mise en place du Debootstrap

sudo mkdir /srv/nfs/debian

sudo debootstrap --arch amd64 bookworm /srv/nfs/debian http://ftp.fr.debian.org/debian

sudo mount -t proc none /srv/nfs/debian/proc

sudo mount -o bind /dev /srv/nfs/debian/dev

sudo chroot /srv/nfs/debian /bin/bash


# Créer l'utilisateur avec le mot de passe fourni

sudo useradd -m "$username" -s /bin/bash

echo "$username:$password" | sudo chpasswd


# Ajouter l'utilisateur au groupe sudo

sudo usermod -aG sudo "$username"


# Vérifier si l'ajout au groupe sudo a réussi

if id "$username" &>/dev/null; then

 echo "L'utilisateur $username a été créé avec succès et ajouté au groupe sudo."

else

 echo "Erreur : Impossible de créer l'utilisateur $username ou de l'ajouter au groupe sudo."

fi

echo "root:$password" | chpasswd

apt update &&  apt full-upgrade

apt install linux-image-amd64 partclone dialog

echo "sudo loadkeys fr-pc && cd /home/felix && sudo ./manuel.sh" >> /home/felix/.profile

echo "$(username) ALL=(ALL) NOPASSWD: /home/felix/.profile" >> /etc/sudoers

echo "NAutoVTs=6\nReserveVT=7">> /etc/systemd/logind.conf

mkdir /etc/systemd/system/getty@tty1.service.d/

echo "[Service]

ExecStart=

ExecStart=-/sbin/agetty --noissue --autologin ostechnix %I $TERM

Type=idle" > /etc/systemd/system/getty@tty1.service.d/override.conf

exit


