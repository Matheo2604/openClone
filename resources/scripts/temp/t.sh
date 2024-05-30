#!/bin/bash

# Fonction pour vérifier l'état d'une adresse IP
check_ip() {
    ping -c 1 -W 1 $1 > /dev/null
    if [ $? -eq 0 ]; then
        echo "$1 est actif"
    fi
}

# Plage d'adresses IP à vérifier
IP_RANGE="192.168.150."

# Boucle à travers les adresses IP
for i in {1..254}; do
    IP="$IP_RANGE$i"
    check_ip $IP &
done

wait
