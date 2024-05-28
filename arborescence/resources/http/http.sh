#!/bin/bash

echo -e "[http]\n"

apt -y install apache2 php mariadb-server

cp resources/http/www /srv/www
cp resources/http/site.conf /etc/apache2/sites-available/

a2dissite 000-default.conf
a2ensite site.conf

chown www-data /srv/www/ -Rf
