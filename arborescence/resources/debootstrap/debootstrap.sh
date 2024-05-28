#!/bin/bash

# Install the package needed for the DeBootStrap
apt -y install debootstrap

# Create the folder that's well be used for the DeBootStrap
mkdir $PathNFS/debian

# Creation of the actual tree structure of an debian
debootstrap --arch amd64 bookworm /srv/nfs/debian http://ftp.fr.debian.org/debian

# Mount the proc filesystem to access process information in the chroot
mount -t proc none $PathNFS/debian/proc

# Mount the host system's device directory into the chroot
mount -o bind /dev $PathNFS/debian/dev

# Install all the package needed and the actual kernel that's well be used to Boot in PXE mode
chroot $PathNFS/debian /bin/bash << EOT

  apt update && apt full-upgrade
  apt install -y linux-image-amd64 partclone dialog sudo
  useradd -m "$username" -s /bin/bash
  echo "$username:password" | chpasswd
  usermod -aG sudo "$username"
  (crontab -l 2>/dev/null; echo "@reboot /srv/scripts/ACHANGER.sh") | crontab -

EOT

# Copied the files used for the auto-logging
cp resources/debootstrap/sudoers $PathNFS/debian/etc/sudoers
cp resources/debootstrap/logind.conf $PathNFS/debian/etc/systemd/logind.conf
mkdir $PathNFS/debian/etc/systemd/system/getty@tty1.service.d/
cp resources/debootstrap/override.conf $PathNFS/debian/etc/systemd/system/getty@tty1.service.d/override.conf