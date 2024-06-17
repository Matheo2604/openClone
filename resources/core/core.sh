#!/bin/bash

# Create Boot file for linux (core.0 or core.efi) and transfert the PXE grub.cfg already made
grub-mknetdir

# Basic config of the grub.cfg to Boot on the openClone OS
cp $path_tftp/boot/grub/grub.cfg $path_tftp/boot/grub/grub.cfg.old
cp resources/core/grub.cfg $PathTFTP/boot/grub/grub.cfg
sed -i \
    -e "s/{ip_lan}/$ip_lan/g" \ 
    -e "s/{path_nfs}/$path_nfs/g" \
    $path_tftp/boot/grub/grub.cfg

