#!/bin/bash

# Install the package needed for the TFTP
apt -y install atftpd

# Copied the config file
cp resources/tftp/atftpd /etc/default/atftpd

# Give it the good rights
chmod -R ugo+rw /srv/tftp/

