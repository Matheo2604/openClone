#!/bin/bash

# Create the folder that's well be used for the DeBootStrap
mkdir $path_nfs/debootstrap

# Creation of the actual tree structure of an debian
debootstrap --arch amd64 bookworm $path_nfs/debootstrap http://ftp.fr.debian.org/debian

# Mount the proc filesystem to access process information in the chroot
mount -t proc none $path_nfs/debootstrap/proc

# Mount the host system's device directory into the chroot
mount -o bind /dev $path_nfs/debootstrap/dev

# Install all the package needed and the actual kernel that's well be used to Boot in PXE mode
chroot $path_nfs/debootstrap /bin/bash << EOT

  apt-get update && apt-get full-upgrade

  # Install the kernel for this  debian tree structure
  apt-get -y install linux-image-amd64 partclone dialog sudo

  # Only install going to /dev/null because it has an post-install semi-graphic interaction
  apt-get -y install console-data >> /dev/null

  # Creation off the user
  useradd -m "$user_debootstrap" -s /bin/bash
  echo "$user_debootstrap:$password_debootstrap" | chpasswd
  usermod -aG sudo "$user_debootstrap"

  (crontab -l 2>/dev/null; echo "@reboot /srv/scripts/menu.sh") | crontab -

EOT

# Copied the files used to logging, start script and change the keyboard layout automatically
cp resources/debootstrap/sudoers $path_nfs/debootstrap/etc/sudoers
cp resources/debootstrap/logind.conf $path_nfs/debootstrap/etc/systemd/logind.conf
mkdir $path_nfs/debootstrap/etc/systemd/system/getty@tty1.service.d/
cp resources/debootstrap/override.conf $path_nfs/debootstrap/etc/systemd/system/getty@tty1.service.d/override.conf

# !!! Not valid at all
#mkdir $path_nfs/debootstrap$path_nfs
#cp resources/scripts/* $path_scripts

# Start script automatically
# the script has to be change
echo "sudo $path_scripts/MENU.sh >> $path_nfs/debootstrap/home/felix/.bashrc 
echo "$user_debootstrap ALL=(ALL) NOPASSWD: $path_scripts/MENU.sh" >> /etc/sudoers 

# if the option to skip question is active then the users will be asked to change the maintenance os password when the first connexion is made
if [ $SkipQuestion ]; then

  sed -i "s/{user_debootstrap}/$user_debootstrap/g" resources/debootstrap/first_logging.sh
  
  cp "/home/$user_debootstrap/.bashrc" "/home/$user_debootstrap/.bashrc.tmp"

  echo "bash FirstLogging" >> .bashrc

fi