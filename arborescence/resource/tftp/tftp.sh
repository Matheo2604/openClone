#!/bin/bash

apt -y install atftpd

mkdir /srv/tftp

mv ressource/serveur_transfert/atftpd /etc/default/atftpd

chmod -R ugo+rw /srv/tftp/

