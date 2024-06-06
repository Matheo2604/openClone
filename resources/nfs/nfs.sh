#!/bin/bash

# Create the shared folder
mkdir $PathNFS

# Give it the good rights
chown -R root:root $PathNFS
chmod 744 $PathNFS

# Copied congif files
cp /etc/exports /etc/exports.old
cp resources/nfs/exports /etc/exports
sed -i \
  -e "s/{IP_LAN_Subnet}/$IP_LAN_Subnet/g" \
  -e "s/{Mask_LAN_CIDR}/$Mask_LAN_CIDR/g" \
  /etc/exports

exportfs -a