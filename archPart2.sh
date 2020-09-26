#!/bin/bash

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
