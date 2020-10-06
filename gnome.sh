#!/bin/bash

printf "######   Checking if post-install.sh has been run   ######\n"


printf "######   Installing vmware requirements   ######\n"
sudo pacman -S --noconfirm xf86-input-vmmouse xf86-video-vmware mesa

printf "######   Installing xorg   ######\n"
sudo pacman -S --noconfirm xorg xorg-server

printf "######   Installing Gnome and a few extra apps   ######\n"
sudo pacman -S --noconfirm gnome gnome-tweaks gnome-usage gnome-nettool gitg gvfs-goa dconf-editor

printf "######   Enabling GDM   ######\n"
sudo systemctl enable gdm.service

printf "######   Your setup is ready. You can reboot now!   ######\n"