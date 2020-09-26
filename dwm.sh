#!/bin/bash

sudo pacman -Syy
sudo pacman -S xorg-server xorg-xinit xorg-xrandr xorg-xsetroot firefox
cp /etc/X11/xinit/xinitrc ~/.xinitrc
echo remove the last 5 lines 
sleep 3
vim ~/.xinitrc
echo "# Keybord Layout" >> ~/.xinitrc
echo "setxkbmap de &" >> ~/.xinitrc
echo "# Loop" >> ~/.xinitrc
echo "while true; do" >> ~/.xinitrc
echo "dwm >/dev/null 2>&1" >> ~/.xinitrc
echo "done" >> ~/.xinitrc
echo "# Execute dwm" >> ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc

sudo pacman -S wget

wget https://dl.suckless.org/dwm/dwm-6.2.tar.gz
tar -xzvf dwm-6.2.tar.gz

cd dwm-6.2
sudo make clean install

cd ..
wget https://dl.suckless.org/st/st-0.8.3.tar.gz
tar -xzvf st-0.8.3.tar.gz

cd st-0.8.3
sudo make clean install

cd ..
wget https://dl.suckless.org/tools/dmenu-4.9.tar.gz
tar -xzvf dmenu-4.9.tar.gz

cd dmenu-4.9
sudo make clean install

cd ..

startx
