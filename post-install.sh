#!/bin/bash

### User Variables, Edit these for your environment
# Country or Country code for reflector, to update Mirrors to the latest and fastest for your Country
reflector_country="Australia"

# Check if user is root / sudo << Cant use this due to "yay" needing to run as normal user. 
# if [[ $(id -u) -ne 0 ]]
#  then printf "\nPlease run as root or with sudo\n\n"
#  exit 1
# fi

printf "######   Syncing repos and updating packages   ######\n"
sudo pacman -Syu --noconfirm

printf "######   Installing reflector and Applying Custom Mirrors   ######\n"
pacman -S --noconfirm reflector 

sed -i 's/^--/# --/g' /etc/xdg/reflector/reflector.conf
tee -a /etc/xdg/reflector/reflector.conf << EOF


##### Config Added via base.sh #####

--save /etc/pacman.d/mirrorlist
--country $reflector_country
--protocol http,https
--latest 10
--sort rate
EOF

systemctl enable reflector.service
systemctl start reflector.service

printf "######   Installing and configuring UFW   ######\n"
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

printf "######   Installing common applications   ######\n"
sudo pacman -S --noconfirm git htop p7zip ripgrep unzip unrar

printf "######   Installing chromium with GPU acceleration   ######\n"
sudo pacman -S --noconfirm chromium
mkdir -p ~/.config/
touch ~/.config/chromium-flags.conf
tee -a ~/.config/chromium-flags.conf << EOF
--ignore-gpu-blacklist
--enable-gpu-rasterization
--enable-zero-copy
EOF

printf "######   Creating user's folders   ######\n"
sudo pacman -S --noconfirm xdg-user-dirs

printf "######   Installing fonts   ######\n"
sudo pacman -S --noconfirm ttf-roboto ttf-roboto-mono ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack noto-fonts ttf-fira-code ttf-fira-mono ttf-font-awesome noto-fonts-emoji ttf-hanazono

printf "######   Ricing bash   ######\n"
touch ~/.bashrc
tee -a ~/.bashrc << EOF
export PS1="\w \\$  "
PROMPT_COMMAND='PROMPT_COMMAND='\''PS1="\n\w \\$  "'\'

alias upa="sudo rm -f /var/lib/pacman/db.lck && sudo pacman -Syu && yay -Syu --aur && flatpak update && fwupdmgr refresh && fwupdmgr update"
EOF

printf "######   Installing yay   ######\n"
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin

printf "######   Installing pamac   ######\n"
yay -S --noconfirm pamac-aur

# printf "######   Installing and configuring Plymouth   ######\n"
# yay -S --noconfirm plymouth-git
# sudo sed -i 's/base systemd autodetect/base systemd sd-plymouth autodetect/g' /etc/mkinitcpio.conf
# sudo sed -i 's/quiet rw/quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 rw/g' /boot/loader/entries/arch.conf
# sudo sed -i 's/quiet rw/quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 rw/g' /boot/loader/entries/archlts.conf
# sudo mkinitcpio -p linux
# sudo mkinitcpio -p linux-lts
# sudo plymouth-set-default-theme -R bgrt


# printf "######   Reducing VM writeback time   ######\n"
# sudo touch /etc/sysctl.d/dirty.conf
# sudo tee -a /etc/sysctl.d/dirty.conf << EOF
# vm.dirty_writeback_centisecs = 1500
# EOF

# printf "######   Disabling root (still allows sudo)   ######\n"
# passwd --lock root

printf "######   All Done With Base Config   ######\n"

#1
