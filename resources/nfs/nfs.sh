#!/bin/bash

# Create the shared folder
mkdir $path_nfs

# Give it the good rights
chown -R root:root $path_nfs
chmod 744 $path_nfs

# Copied congif files
cp /etc/exports /etc/exports.old
cp resources/nfs/exports /etc/exports
sed -i \
  -e "s/{ip_lan_subnet}/$ip_lan_subnet/g" \
  -e "s/{mask_lan_cidr}/$mask_lan_cidr/g" \
  /etc/exports

exportfs -a