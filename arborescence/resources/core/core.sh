#!/bin/bash

# To make sure this package is already installed
apt -y install grub-common

# Create Boot file for linux (core.0 or core.efi) and transfert the PXE grub.cfg already made
grub-mknetdir

# Basic config of the grub.cfg to Boot on the openClone OS
sed -i "s/{IP_LAN}/$IP_LAN/g" resources/core/grub.cfg
cp resources/core/grub.cfg $PathTFTP/boot/grub/grub.cfg