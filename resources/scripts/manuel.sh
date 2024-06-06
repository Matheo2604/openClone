#!/bin/bash


HEIGHT=12

WIDTH=45

CHOICE_HEIGHT=4

BACKTITLE="Menu du projet OpenClone"

TITLE="OpenClone"

MENU="Selectionner une des options suivante :"


OPTIONS=(1 "Lister les disques & partitions"

         2 "Restaurer une image"

         3 "Cloner une image"

         4 "Creer une image"

         5 "Quitter")


CHOICE=$(dialog --clear \

                --backtitle "$BACKTITLE" \

                --title "$TITLE" \

                --menu "$MENU" \

                $HEIGHT $WIDTH $CHOICE_HEIGHT \

                "${OPTIONS[@]}" \

                2>&1 >/dev/tty)


clear

case $CHOICE in

        "1")


            dialog --title "Disque(s) & partition(s) :" --msgbox "$(sudo ./lister_disque.>

            ;;

        "2")

            dialog --title "Restauration du la partition :" --msgbox "$(sudo ./restaurer.>

            ;;

        "3")

            dialog --title "Clonage de(s) partion(s) :" --msgbox "$(sudo ./cloner.sh)" 35>

            ;;

        "4")

            dialog --title "Creation d'une imgae :" --msgbox "$(sudo ./creer_image.sh)" 3>

            ;;

        "5")

            exit 0

            ;;

esac
