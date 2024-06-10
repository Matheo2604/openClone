#!/bin/bash

# Verify if the user that start the script is in the openClone folder
cd "$(dirname $0)"

# Verify that the parameter has been given
if [ $# -ne 1 ]; then
  echo "Usage: $0 <number_partitions>"
  exit 1
fi

number_partitions=$1

# Call of an other script to know the disk and the lenght of user partitions
output=$(./partition_data.sh "$number_partitions")

# Extract the data needed
read disk_name lenght <<< "$output"

# Delete table of partitions 
wipefs -a "/dev/$disk_name"
dd if=/dev/zero of="/dev/$disk_name" bs=1M count=10

# To destroy every data but way longer
#dd if=/dev/random of="/dev/$disk_name" bs=512 count=1


# Creation of an gpt partitions table 
parted -s "/dev/$disk_name" mklabel gpt

# Creation of fat32 partition for EFI that go from 1 MiO to 1GiO
parted -s "/dev/$disk_name" mkpart primary fat32 2048s 2050047s
parted -s "/dev/$disk_name" set 1 esp on
yes | mkfs.fat -F32 "/dev/${disk_name}1"

# Creation of EXT partition for GRUB that go from 1GiO to 2GiO
parted -s "/dev/$disk_name" mkpart primary ext4 2050048s 4098047s
yes | mkfs.ext4 "/dev/${disk_name}2"

# Beginning sector for every user partitions 
start_byte=4098048  

# Loop to create partition in EXT4 format
for (( i=1; i<=number_partitions; i++ ))
do
  index=$((i + 2))
  end_byte=$((start_byte + lenght - 1)) 
  parted -s "/dev/$disk_name" mkpart primary ext4 "${start_byte}s" "${end_byte}s"
  yes | mkfs.ext4 "/dev/${disk_name}${index}"
  start_byte=$((end_byte + 1))
done
