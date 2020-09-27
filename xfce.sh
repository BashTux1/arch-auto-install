#!/bin/bash

printf "######   Installing vmware requirements   ######\n"
sudo pacman -S --noconfirm xf86-input-vmmouse xf86-video-vmware mesa

printf "######   Installing xorg   ######\n"
sudo pacman -S --noconfirm xorg xorg-server

printf "######   Installing xfce and a few extra apps   ######\n"
sudo pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter

printf "######   Enabling lightdm   ######\n"
sudo systemctl enable lightdm

printf "######   Installing pamac   ######\n"
yay -S --noconfirm pamac-aur

printf "######   Your setup is ready. You can reboot now!   ######\n"
