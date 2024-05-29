#!/bin/bash

# Install the package needed for the NFS
apt-get -y install nfs-kernel-server

# Create the shared folder
mkdir $PathNFS

# Give it the good rights
chown -R root:root $PathNFS
chmod 744 $PathNFS

# Copied congif files
sed -i \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
  resources/nfs/exports
cp resources/nfs/exports /etc/exports

exportfs -a