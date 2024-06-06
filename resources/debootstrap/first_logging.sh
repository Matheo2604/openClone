#!/bin/bash

echo " Welcome\nThis is your first time logging in with {UserDebootStrap} \n"
passwd

mv "/home/{UserDebootStrap}/.bashrc.tmp" "/home/{UserDebootStrap}/.bashrc"
rm first_logging.sh ".bashrc.tmp"