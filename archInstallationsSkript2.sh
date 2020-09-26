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

echo enter wich partition you wanna use as efi-Partition: (/dev/sda1) 
read efiPartition
echo enter wich partition you wanna use as kernel-Partition: (/dev/sda2)
read kernelPartition
echo enter wich partition you wanna use as system-Partition: (/dev/sda3)
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
genfsrab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

PS3="Choose a timezone: "
select zone in $(ls /usr/share/zoneinfo/ | more)
do
	PS3="Choose a town: "
	select zoneTown in $(ls /usr/share/zoneinfo/$zone | more)
	do
		ln -s /usr/share/zoneinfo/$zone/$zoneTown /etc/localtime
		break
	done
	break
done

hwclock --systohc 

echo remove the first char from the line of the language you want: de_DE.UTF-8 UTF-8
sleep 3
vim /etc/locale.gen
locale-gen

echo write LANG= and the iso-code for your language: LANG=de_DE.UTF-8
sleep 3
vim /etc/locale.conf

echo write your hostname
sleep 3
vim /etc/hostname

echo go to line 52 it beginns with HOOKS... and add between block and filesystem: encrypt
sleep 6
vim /etc/mkinitcpio.conf
mkinitcpio -P

echo enter a root password
passwd

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archGrub --recheck
echo go to GRUB_CMDLINE_LINUX and add cryptdevice=/path/to/crypted/device:SYSTEM root=/dev/mapper/SYSTEM
sleep 6
vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -R /mnt
cryptsetup close SYSTEM

reboot
