#!/bin/bash

apt -y install nfs-kernel-server

mkdir /srv/nfs

chown -R root:root /srv/nfs
chmod 744 /srv/nfs

sed -i \
  -e "s/{IP_LAN_SR}/$IP_LAN_SR/g" \
  -e "s/{Masque_LAN_CIDR}/$Masque_LAN_CIDR/g" \
  ressource/serveur_transfert/exports
mv ressource/serveur_transfert/exports /etc/exports

exportfs -a