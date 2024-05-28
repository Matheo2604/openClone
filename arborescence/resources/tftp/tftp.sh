#!/bin/bash

echo -e "[tftp]\n"

apt -y install atftpd

# verify if downloading the paquets atftpd
mkdir /srv/tftp

cp resources/tftp/atftpd /etc/default/atftpd

chmod -R ugo+rw /srv/tftp/

