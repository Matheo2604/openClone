#!/bin/bash

apt -y install debootstrap

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

cp ressource/linux_maintenance/sudoers /srv/nfs/debian/etc/sudoers
cp ressource/linux_maintenance/logind.conf /srv/nfs/debian/etc/systemd/logind.conf
mkdir /srv/nfs/debian/etc/systemd/system/getty@tty1.service.d/
cp ressource/linux_maintenance/override.conf /srv/nfs/debian/etc/systemd/system/getty@tty1.service.d/override.conf