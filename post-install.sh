#!/bin/bash

### User Variables, Edit these for your environment
# Country or Country code for reflector, to update Mirrors to the latest and fastest for your Country
reflector_country="Australia"

# Check if user is root / sudo and if true, exit. "yay" install needs to run as normal user. 
if [[ $(id -u) = 0 ]]
  then printf "\nPlease run as non-root / sudo, ie. normal user\n\n"
  exit 1
 fi

printf "######   Syncing repos and updating packages   ######\n"
sudo pacman -Syu --noconfirm

printf "######   Installing reflector and Applying Custom Mirrors   ######\n"
sudo pacman -S --noconfirm reflector 

sudo sed -i 's/^--/# --/g' /etc/xdg/reflector/reflector.conf
sudo tee -a /etc/xdg/reflector/reflector.conf << EOF


##### Config Added via post-install.sh #####

--save /etc/pacman.d/mirrorlist
--country $reflector_country
--protocol http,https
--latest 10
--sort rate
EOF

sudo systemctl enable reflector.service
sudo systemctl start reflector.service

printf "######   Installing and configuring UFW   ######\n"
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh
sudo ufw allow 80
sudo ufw allow 443
echo "y" | sudo ufw enable

printf "######   Installing common applications   ######\n"
sudo pacman -S --noconfirm htop p7zip ripgrep unzip unrar

printf "######   Creating user's folders   ######\n"
sudo pacman -S --noconfirm xdg-user-dirs

printf "######   Installing fonts   ######\n"
sudo pacman -S --noconfirm ttf-roboto ttf-roboto-mono ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack noto-fonts ttf-fira-code ttf-fira-mono ttf-font-awesome noto-fonts-emoji ttf-hanazono

# printf "######   Ricing bash   ######\n"
# touch ~/.bashrc
# tee -a ~/.bashrc << EOF
# export PS1="\w \\$  "
# PROMPT_COMMAND='PROMPT_COMMAND='\''PS1="\n\w \\$  "'\'

# EOF

printf "######   Installing yay   ######\n"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay-bin

# printf "######   Installing pamac   ######\n"
# yay -S --noconfirm pamac-aur

# printf "######   Reducing VM writeback time   ######\n"
# sudo touch /etc/sysctl.d/dirty.conf
# sudo tee -a /etc/sysctl.d/dirty.conf << EOF
# vm.dirty_writeback_centisecs = 1500
# EOF

# printf "######   Disabling root (still allows sudo)   ######\n"
# passwd --lock root

printf "######   All done with Post Installation   ######\n"

