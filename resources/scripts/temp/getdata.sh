#!/bin/bash


# Fonction pour vérifier l'état d'une adresse IP
check_ip() {

    ping -c 1 -W 1 $1 > /dev/null

}

# Plage d'adresses IP à vérifier
IP_RANGE="191.168.150."

# Boucle à travers les adresses IP
for i in {1..254}; do
    IP="$IP_RANGE$i"
    check_ip $IP &
done


# Variables pour la connexion à MariaDB
db_user="responsable"
db_password="felix22"
db_name="openclone"
table_name="clients"

# Récupérer les adresses MAC et IP des postes connectés au DHCP pour l'interface eno2
dhcp_clients_bond0=$(ip neigh show dev bond0 | awk '/lladdr/ {print $3, $1}' | grep -v "ERROR" | sort)

# Afficher les adresses MAC et IP des postes connectés au DHCP pour l'interface eno2
echo "Adresses MAC et IP  des postes connectés au DHCP sur bond0 :"
echo "$dhcp_clients_bond0"

# Connexion à MariaDB et suppression des données existantes dans la table client
mysql -u "$db_user" -p"$db_password" -D "$db_name" -e "DELETE FROM $table_name;"

# Réinitialisation de la valeur auto-incrémentée à zéro
mysql -u "$db_user" -p"$db_password" -D "$db_name" -e "ALTER TABLE $table_name AUTO_INCREMENT = 1;"

# Insertion des nouvelles données dans la table
id_counter=1
while read -r line; do
    mac_address=$(echo 'Mac : '"$line" | awk '{print $1}')
    ip_address=$(echo '| IP : ' "$line" | awk '{print $2}')

    # Insérer dans la table MariaDB avec incrémentation manuelle de l'id
    mysql -u "$db_user" -p"$db_password" -D "$db_name" -e "INSERT INTO $table_name (id, MAC_Address, IP_Address) VALUES ('$id_counter', '$mac_address', '$ip_address');"

    # Incrémentation du compteur d'id
    ((id_counter++))
done <<< "$dhcp_clients_bond0"
