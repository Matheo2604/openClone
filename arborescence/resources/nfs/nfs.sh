#!/bin/bash

function loginfo {
  echo -e "[nfs] $0"
}

loginfo "Started"

apt -y install nfs-kernel-server

mkdir /srv/nfs

chown -R root:root /srv/nfs
chmod 744 /srv/nfs

sed -i \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
  resources/nfs/exports
cp resources/nfs/exports /etc/exports

exportfs -a