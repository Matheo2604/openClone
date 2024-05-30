#!/bin/bash

# Définir le chemin du fichier temporaire de configuration de BIND
dns_config="tests"

# Récupérer les données de la base de données MariaDB
DB_USER="responsable"
DB_PASSWORD="felix22"
DB_NAME="openclone"

# Créer le contenu du fichier de test
echo "; Fichier de configuration d'exemple pour BIND
;
; Configuration de la zone de recherche directe
zone \"site22.fr\" {
    type master;
    file \"/var/cache/bind/site22.fr.zone\";
};

; Configuration de la zone de recherche inverse
zone \"150.168.192.in-addr.arpa\" {
    type master;
    file \"/var/cache/bind/dns.fr.reverse\";
};" > "$dns_config"

# Récupérer les données de la base de données et les ajouter au fichier de test
mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SELECT Hostname, IP_Address FROM clients;" | \
awk -v dns_config="$dns_config" '{printf "%s    IN    A    %s;\n%s    PTR    site22.fr.;\n", $1, $2, $2}' >> "$dns_config"

# Déplacer le fichier temporaire vers le répertoire de configuration BIND
sudo mv "$dns_config" /etc/bind/

# Redémarrer le service BIND pour appliquer les modifications
sudo systemctl restart bind9.service
