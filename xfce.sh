#!/bin/bash

printf "######   Installing vmware requirements   ######\n"
sudo pacman -S --noconfirm xf86-input-vmmouse xf86-video-vmware mesa

printf "######   Installing xorg   ######\n"
sudo pacman -S --noconfirm xorg xorg-server

printf "######   Installing xfce and a few extra apps   ######\n"
sudo pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter-settings xarchiver network-manager-applet pavucontrol gvfs flameshot

printf "######   Enabling lightdm   ######\n"
sudo systemctl enable lightdm 

printf "######   Update yay   ######\n"
yay -Syu --noconfirm

printf "######   Installing tkpacman   ######\n"
yay -S --noconfirm tkpacman

##### Theme ##### 

printf "######   Optimising volume icon size   ######\n"
mkdir ~/.config/gtk-3.0/
touch ~/.config/gtk-3.0/gtk.css
tee -a ~/.config/gtk-3.0/gtk.css << EOF
#pulseaudio-button * {
    -gtk-icon-transform: scale(.75);
}
#xfce4-notification-plugin* {
    -gtk-icon-transform: scale(.75);
}
EOF

printf "######   Downloading, Installing and Setting Cursors   ######\n"
yay -S --noconfirm xcursor-breeze
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Breeze"

printf "######   Downloading, Installing and Setting Theme   ######\n"
yay -S --noconfirm matcha-gtk-theme
xfconf-query -c xsettings -p /Net/ThemeName  -s "Matcha-dark-azul"

printf "######   Downloading, Installing and Setting Icons   ######\n"
sudo pacman -S --noconfirm community/papirus-icon-theme
xfconf-query -c xsettings -p /Net/IconThemeName  -s "Papirus-Dark"

printf "######   Downloading, Installing and Setting Fonts   ######\n"
sudo pacman -S --noconfirm extra/noto-fonts
xfconf-query -c xsettings -p /Gtk/FontName  -s "Noto Sans 10"

# printf "######   Changing Panel Properties   ######\n"
# xfconf-query -c xfce4-panel -p /panels/panel-1/position -s "p=10;x=0;y=0"
# xfconf-query -c xfce4-panel -p /panels/panel-2/position -s "p=9;x=0;y=0"
# xfconf-query -c xfce4-panel -p /panels/panel-1/size -s "36" 
# xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s "28"


printf "######   Your setup is ready. You can reboot now!   ######\n"
