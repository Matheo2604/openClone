#!/bin/bash

# Create Boot file for linux (core.0 or core.efi) and transfert the PXE grub.cfg already made

grub-mknetdir
sed -i "s/{IP_LAN}/$IP_LAN/g" ressource/grub.cfg
mv ressource/grub.cfg /srv/tftp/boot/grub/grub.cfg