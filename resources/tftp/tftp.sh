#!/bin/bash

# Copied the config file
cp /etc/default/atftpd /etc/default/atftpd.old
cp resources/tftp/atftpd /etc/default/atftpd

# Give it the good rights
chmod -R ugo+rw $path_tftp

