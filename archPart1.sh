#!/bin/bash

loadkeys de
echo ----------------------------------------
echo if you want to connect wifi 
echo device list
echo station DEVICE scan
echo station DEVICE get-networks
echo station DEVICE connect SSID
echo exit
echo ----------------------------------------
iwctl 

echo ----------------------------------------
echo 300M - efi, 300M - kernel, rest - SYSTEM
echo ----------------------------------------
PS3="Choose the device you wanna install arch linux on: "
select device in $(lsblk -p -o NAME,SIZE)
do
	cfdisk $device
	break
done

echo enter wich partition you wanna use as efi-Partition: /dev/sda1
read efiPartition
echo enter wich partition you wanna use as kernel-Partition: /dev/sda2
read kernelPartition
echo enter wich partition you wanna use as system-Partition: /dev/sda3
read systemPartition

mkfs.msdos -F 32 $efiPartition
mkfs.ext4 $kernelPartition

cryptsetup -v -y --cipher aes-xts-plain64 --key-size 256 --hash sha256 --iter-time 2000 --use-urandom --verify-passphrase luksFormat $systemPartition

cryptsetup open $systemPartition SYSTEM
mkfs.ext4 /dev/mapper/SYSTEM

mount /dev/mapper/SYSTEM /mnt
mkdir /mnt/boot
mount $kernelPartition /mnt/boot
mkdir /mnt/boot/efi
mount $efiPartition /mnt/boot/efi

pacstrap -i /mnt base base-devel linux linux-firmware vim dhcpcd wpa_supplicant netctl dialog grub efibootmgr dosfstools gptfdisk bash-completion git
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt