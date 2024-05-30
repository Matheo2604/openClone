#!/bin/bash

# Récupérer le nom d'hôte
hostname=$(hostname)

# Récupérer l'adresse MAC et l'adresse IP
mac=$(ip link | awk '/ether/ {print $2; exit}')
ip=$(hostname -I | awk '{print $1}')

echo -e "# dhcpd.conf
# Fichier de configuration d'exemple pour ISC dhcpd
#
# Option pour l'architecture
#  Définitions communes à tous les réseaux pris en charge...
option arch-type code 93 = unsigned integer 16;

subnet 192.168.150.0 netmask 255.255.255.0 {
  range 192.168.150.10 192.168.150.50;
  option routers 192.168.150.1;
  option domain-name-servers 192.168.150.153;
  option subnet-mask 255.255.255.0;
  option broadcast-address 192.168.150.255;
  default-lease-time 600;
  max-lease-time 7200;

  next-server 192.168.150.153;

  # Configuration pour arm64-efi
  if option arch-type = 00:0e {
    filename "/srv/tftp/boot/grub/arm64/core.efi";
  }
  # Configuration pour x86_64-efi
  else if option arch-type = 00:07 {
    filename "/srv/tftp/boot/grub/x86_64-efi/core.efi";
  }
  # Configuration pour bios i386 & amd64 par défaut
  else {
    filename "/srv/tftp/boot/grub/i386-pc/core.0";
  }
}" > temp

# Afficher les informations réseau
echo "host $hostname {" >> temp
echo "    hardware ethernet $mac;" >>temp
echo "    fixed-address $ip;" >> temp
echo "}" >> temp
echo "" >> temp # Ajouter une ligne vide pour séparer les entrées

# Récupérer les données de la base de données MariaDB
DB_USER="responsable"
DB_PASSWORD="felix22"
DB_NAME="openclone"

# Exécuter la requête SQL pour récupérer les données de la table clients
results=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SELECT MAC_Address, IP_Address, Hostname FROM clients;")

# Initialiser un compteur
counter=1

# Afficher les données de chaque client avec un nom d'hôte unique
echo "$results" | awk -v counter="$counter" 'NR>1 {printf "host exemple_hôte%s {\n    hardware ethernet %s;\n    fixed-address %s;\n}\n\n", counter++, $1, $2}' >> temp

echo -e "\n}" >> temp
sudo systemctl restart isc-dhcp-server.service
