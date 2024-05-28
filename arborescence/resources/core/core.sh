#!/bin/bash

echo -e "[core]\n"

# Create Boot file for linux (core.0 or core.efi) and transfert the PXE grub.cfg already made
apt -y install grub-common
grub-mknetdir
sed -i "s/{IP_LAN}/$IP_LAN/g" resources/core/grub.cfg
cp resources/core/grub.cfg /srv/tftp/boot/grub/grub.cfg