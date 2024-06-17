#!/bin/bash

# Generat password for admin account 
if [ $generate_password_admin_mariadb ]; then
  apt -y install pwgen
  password_admin_mariadb=$(pwgen -c -n -s 24 1)
fi

# Change root password fo security
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${password_admin_mariadb}';"

# Create the actual DataBase
mysql -u root -p"${password_admin_mariadb}" -e "CREATE DATABASE ${database};"

# Create the user & give it rights
mysql -u root -p"${password_admin_mariadb}" -e "CREATE USER '${user_mariadb}'@'localhost' IDENTIFIED BY '${password_user_mariadb}';"
mysql -u root -p"${password_admin_mariadb}" -e "GRANT ALL PRIVILEGES ON ${database}.* TO '${user_mariadb}'@'localhost';"
mysql -u root -p"${password_admin_mariadb}" -e "FLUSH PRIVILEGES;"

# Create tables
mysql -u root -p"${password_admin_mariadb}" -D "${database}" -e "
CREATE TABLE class (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE workstations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT,
    mac_adresse VARCHAR(17),
    ip_adresse VARCHAR(15),
    hostname VARCHAR(30),
    FOREIGN KEY (class_id) REFERENCES class(id)
);"