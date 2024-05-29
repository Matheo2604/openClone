#!/bin/bash

# Install the package needed for the DataBase
apt-get -y install mariadb-server

# Generat password for admin account 
if [ $GeneratePasswordMariaDBAdmin ]; then
  apt -y install pwgen
  PasswordMariaDBAdmin=$(pwgen -c -n -s 24 1)
fi

# Change root password fo security
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${PasswordMariaDBAdmin}';"

# Create the actual DataBase
mysql -u root -p"${PasswordMariaDBAdmin}" -e "CREATE DATABASE ${DataBase};"

# Create the user & give it rights
mysql -u root -p"${PasswordMariaDBAdmin}" -e "CREATE USER '${userMariaDB}'@'localhost' IDENTIFIED BY '${PasswordMariaDBUser}';"
mysql -u root -p"${PasswordMariaDBAdmin}" -e "GRANT ALL PRIVILEGES ON ${DataBase}.* TO '${userMariaDB}'@'localhost';"
mysql -u root -p"${PasswordMariaDBAdmin}" -e "FLUSH PRIVILEGES;"

# Create tables
mysql -u root -p"${PasswordMariaDBAdmin}" -D "${DataBase}" -e "
CREATE TABLE class (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE workstations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT,
    mac_adresse VARCHAR(17),
    ip_adresse VARCHAR(15),
    hostname VARCHAR(255),
    FOREIGN KEY (class_id) REFERENCES class(id)
);"