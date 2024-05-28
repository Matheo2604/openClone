#!/bin/bash
    
    apt -y install ifenslave
    echo ""
    ip a && ip r
    echo ""
    read -p "Entrez le nom de la première interface pour l'agrégation : " interface1
    read -p "Entrez le nom de la deuxième interface pour l'agrégation : " interface2
    echo "Interfaces sélectionnées pour l'agrégation : $interface1 et $interface2"
    echo -e "\nune nouvelle interface nommer bond0 vient d'etre creer\n" 

echo -e "[aggregation]\n"

