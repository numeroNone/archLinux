#!/bin/bash
echo set keyboard layout
loadkeys de

echo --------------------------------------------------------------------
echo use 300M for kernelPartition
echo use remaining for systemPartition ... this will be the crypted partition
echo --------------------------------------------------------------------

PS3="Choose the device you wanna install arch linux on: "
select device in $(lsblk -p -o NAME,SIZE)
do
    sudo cfdisk $device
    break
done

echo enter wich partition you used for the efi /dev/sda1 or /dev/sdb1#
sleep 2
read efiPartition

echo enter wich partition you used for the kernelPartition /dev/sda2 or /dev/sdb2#
sleep 2
read kernelPartition

echo enter wich partition you used for the systemPartition /dev/sda3 or /dev/sdb3
sleep 2
read systemPartition

mkfs.ext4 $kernelPartition

cryptsetup -v -y --cipher aes-xts-plain64 --key-size 256 --hash sha256 --iter-time 2000 --use-urandom --verify-passphrase luksFormat $systemPartition

cryptsetup open $systemPartition SYSTEM
mkfs.ext4 /dev/mapper/SYSTEM

mount /dev/mapper/SYSTEM /mnt
mkdir /mnt/boot
mount $kernelPartition /mnt/boot
mkdir /mnt/boot/efi
mount $efiPartition /mnt/boot/efi

pacstrap -i /mnt base base-devel linux linux-firmware vim dhcpcd wpa_supplicant netctl dialog grub efibootmgr dosfstools gptfdisk

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

PS3="Choose the timzone you want: "
select zone in $(ls /usr/share/zoneinfo/ | more)
do
    PS3="Choose the timzone you want: "
    select zoneTown in $(ls /usr/share/zoneinfo/$zone | more)
    do
        ln -s /usr/share/zoneinfo/$zone/$zoneTown /etc/localtime
    break
    done
    break
done

hwclock --systohc

echo remove the "#" at the beginning from the line of the language you want for example "#"en_GB.UTF-8 
sleep 3
vim /etc/locale.gen

locale-gen

echo write LANG= the iso-code for your language for example LANG=en_GB.UTF-8
sleep 3
vim /etc/locale.conf

echo write your hostname
sleep 2
vim /etc/hostname

echo search for the line that begin with HOOKS=... and add between block and filesystem: encrypt
sleep 5
vim /etc/mkinitcpio.conf

mkinitcpio -P

echo enter password for the root
passwd

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archGrub --recheck
echo go to GRUB_CMDLINE_LINUX and add in """"cryptdevice=path/to/crypted/device:SYSTEM root=/dev/mapper/SYSTEM
sleep 5
vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


exit
umount -R /mnt
cryptsetup close SYSTEM
