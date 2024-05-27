#!/bin/bash


output=$(fdisk -l | grep -E "^/dev|Périphérique|Disque")

echo -e  "\n$output\n"
