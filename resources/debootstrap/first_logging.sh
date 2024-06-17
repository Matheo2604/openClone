#!/bin/bash

echo " Welcome\nThis is your first time logging in with {user_debootstrap} \n"
passwd

mv "/home/{user_debootstrap}/.bashrc.tmp" "/home/{user_debootstrap}/.bashrc"
rm first_logging.sh ".bashrc.tmp"