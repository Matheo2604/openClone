#!/bin/bash

echo -e "[tftp]\n"

apt -y install atftpd

mkdir /srv/tftp

cp ressource/serveur_transfert/atftpd /etc/default/atftpd

chmod -R ugo+rw /srv/tftp/

