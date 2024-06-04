#!/bin/bash


# Install the package needed for the Web Server
apt-get -y install apache2 php 

# Copied the files for the web interface
cp resources/http/www $PathHTTP
# sed
cp resources/http/opencloneWebSite.conf /etc/apache2/sites-available/

# Start the new site
a2dissite 000-default.conf
a2ensite opencloneWebSite.conf

# Give the Web Server acces to a folder
chown www-data:www-data $PathHTTP -Rf
