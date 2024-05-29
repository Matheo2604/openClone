#!/bin/bash

# Install the package needed for the DeBootStrap
apt -y install debootstrap

# Create the folder that's well be used for the DeBootStrap
mkdir $PathNFS/debootstrap

# Creation of the actual tree structure of an debian
debootstrap --arch amd64 bookworm $PathNFS/debootstrap http://ftp.fr.debian.org/debian

# Mount the proc filesystem to access process information in the chroot
mount -t proc none $PathNFS/debootstrap/proc

# Mount the host system's device directory into the chroot
mount -o bind /dev $PathNFS/debootstrap/dev

# Install all the package needed and the actual kernel that's well be used to Boot in PXE mode
chroot $PathNFS/debootstrap /bin/bash << EOT

  apt-get update && apt-get full-upgrade
  apt-get install -y linux-image-amd64 partclone dialog sudo
  useradd -m "$UserDebootStrap" -s /bin/bash
  echo "$UserDebootStrap:$PasswordDeBootStrap" | chpasswd
  usermod -aG sudo "$UserDebootStrap"
  (crontab -l 2>/dev/null; echo "@reboot /srv/scripts/menu.sh") | crontab -

EOT

# Copied the files used for the auto-logging
cp resources/debootstrap/sudoers $PathNFS/debootstrap/etc/sudoers
cp resources/debootstrap/logind.conf $PathNFS/debootstrap/etc/systemd/logind.conf
mkdir $PathNFS/debootstrap/etc/systemd/system/getty@tty1.service.d/
cp resources/debootstrap/override.conf $PathNFS/debootstrap/etc/systemd/system/getty@tty1.service.d/override.conf

mkdir $PathNFS/debootstrap$PathNFS
cp resources/scripts/* $PathSCRIPTS

# if the option to skip question is active then the users will be asked to change the maintenance os password when the first connexion is made
if [ $SkipQuestion ]; then
  sed -i "s/{UserDebootStrap}/$UserDebootStrap/g" resources/debootstrap/first_logging.sh
  cp "/home/$UserDebootStrap/.bashrc" "/home/$UserDebootStrap/.bashrc.tmp"
  echo "bash FirstLogging" >> .bashrc
fi