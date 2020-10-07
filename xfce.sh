#!/bin/bash

printf "######   Installing vmware requirements   ######\n"
sudo pacman -S --noconfirm xf86-input-vmmouse xf86-video-vmware mesa

printf "######   Installing xorg   ######\n"
sudo pacman -S --noconfirm xorg xorg-server

printf "######   Installing xfce and a few extra apps   ######\n"
sudo pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter-settings xarchiver network-manager-applet pavucontrol gvfs flameshot

printf "######   Enabling lightdm   ######\n"
sudo systemctl enable lightdm 

printf "######   Installing tkpacman   ######\n"
yay -S --noconfirm tkpacman

##### Theme ##### 

printf "######   Optimising volume icon size   ######\n"
touch ~/.config/gtk-3.0/gtk.css
tee -a ~/.config/gtk-3.0/gtk.css << EOF
#pulseaudio-button * {
    -gtk-icon-transform: scale(.75);
}
EOF

printf "######   Create theme directories and staging folder   ######\n"
mkdir ~/temp-staging ~/.icons ~/.themes

printf "######   Downloading, Installing and Setting Cursors   ######\n"
yay -S xcursor-breeze
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Breeze"

printf "######   Downloading, Installing and Setting Theme   ######\n"
yay -S --noconfirm matcha-gtk-theme
xfconf-query -c xsettings -p /Net/ThemeName  -s "Matcha-dark-azul"



printf "######   Your setup is ready. You can reboot now!   ######\n"
