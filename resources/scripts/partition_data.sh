#!/bin/bash

# Get the number of user partition needed
if [ $# -ne 1 ]; then
    echo "Usage: $0 <number_partitions>"
    exit 1
fi

number_partitions=$1

# Find the biggest disk usable on the device
disk=$(lsblk -b -d | grep disk | sort -k 4 -nr | head -n 1)

# Exctrat the name and the lenght of the biggest disk 
name_disk=$(echo $disk | awk '{print $1}')
lenght_disk=$(echo $disk | awk '{print $4}')

# Converted from octets to sector
lenght_disk=$((lenght_disk / 512))
# Take in charge grub and efi partition plus 1 Mio of security
lenght_disk=$((lenght_disk - 4100096))

# Find the lenght for every user partition
disk_partitionner=$((lenght_disk / number_partitions))

if [ $disk_partitionner -lt 4100096 ]; then
    echo "Error : The final lenght of the disk is lower than 4100096 sector"
    exit 1
fi

echo "$name_disk $disk_partitionner"
