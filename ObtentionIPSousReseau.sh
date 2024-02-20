#!/bin/bash


# Fonction pour convertir une adresse IP en binaire
echo "test"

ip_en_binaire() {

 local ip="$1"

 IFS='.' read -r -a octets <<< "$ip"

    for octet in "${octets[@]}"; do

        printf "%08d" "$(echo "obase=2;$octet" | bc)"

    done

}


# Fonction pour calculer l'adresse du réseau

calcul_adresse_reseau() {

    local ip="$1"

    local masque="$2"

    local ip_binaire=$(ip_en_binaire "$ip")

    local masque_binaire=$(ip_en_binaire "$masque")


# Calculer l'adresse du réseau en binaire


local adresse_reseau_binaire=""

for ((i=0; i<${#ip_binaire}; i++)); do

if [ "${masque_binaire:$i:1}" == "1" ]; then

adresse_reseau_binaire="${adresse_reseau_binaire}${ip_binaire:$i:1}"

else

            adresse_reseau_binaire="${adresse_reseau_binaire}0"

        fi

    done


# Convertir l'adresse du réseau en décimal


    local adresse_reseau=""

    for ((i=0; i<${#adresse_reseau_binaire}; i+=8)); do

        adresse_reseau="${adresse_reseau}.$((2#${adresse_reseau_binaire:$i:8}))"

    done


    echo "${adresse_reseau:1}"

}


# Vérifier que deux arguments ont été fournis


if [ "$#" -ne 2 ]; then

    echo "Usage: $0 <adresse_ip> <masque_sous-reseau>"

    exit 1

fi


# Extraire les arguments


ip="$1"

masque="$2"


# Calculer et afficher l'adresse IP du réseau


adresse_reseau=$(calcul_adresse_reseau "$ip" "$masque")

echo "$adresse_reseau"
