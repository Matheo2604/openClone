#!/bin/bash

echo -e "[tftp]\n"

apt -y install atftpd

cp resources/tftp/atftpd /etc/default/atftpd

chmod -R ugo+rw /srv/tftp/

