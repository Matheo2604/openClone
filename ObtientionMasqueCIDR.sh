#!/bin/bash


masque="$1"
cidr=0

    IFS='.' read -r -a octets <<< "$masque"

    for octet in "${octets[@]}"; do

        while [ $octet -gt 0 ]; do

            cidr=$((cidr + (octet & 1)))

            octet=$((octet >> 1))

        done

    done

    echo $cidr

