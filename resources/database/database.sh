#!/bin/bash

# Install the package needed for the DataBase
apt-get -y install mariadb-server

# Create the user & the DataBase
mysql  << EOL

  CREATE DATABASE openclonedb;
  CREATE USER 'responsable' IDENTIFIED BY 'felix22';
  grant all privileges on openclone.* to 'responsable';
  CREATE USER 'consultant' IDENTIFIED BY 'felix22';
  GRANT SELECT ON openclone.* TO 'consultant';
  use openclonedb;
  CREATE TABLE clients(id INT PRIMARY KEY NOT NULL, MAC_Address VARCHAR(17), IP_Address VARCHAR(15),
  Hostname VARCHAR(30));

EOL