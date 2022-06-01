#!/usr/bin/env bash

printf ">>>   Installing vmware requirements\n"
sudo pacman -S --noconfirm xf86-input-vmmouse xf86-video-vmware mesa

printf ">>>   Installing xorg\n"
sudo pacman -S --noconfirm xorg xorg-server

printf ">>>   Installing KDE\n"
sudo pacman -S --noconfirm plasma kde-applications sddm

printf ">>>   Enabling SDDM\n"
sudo systemctl enable sddm

printf ">>>   Your setup is ready. You can reboot now!\n"
