#!/bin/bash

### User Variables, Edit these for your environment
# Country or Country code for reflector, to update Mirrors to the latest and fastest for your Country
reflector_country="Australia"
# User password for non root user
user_password="MyPassword"

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

printf "######   Installing yay   ######\n"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay-bin

# printf "######   Installing fonts   ######\n"
# sudo pacman -S --noconfirm ttf-roboto ttf-roboto-mono ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack noto-fonts ttf-fira-code ttf-fira-mono ttf-font-awesome noto-fonts-emoji ttf-hanazono

printf "######   Ricing bash   ######\n"
mv ~/.bashrc .bashrc_original
touch ~/.bashrc
tee -a ~/.bashrc << EOF
#
# ~/.bashrc
#

[[ $- != *i* ]] && return

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '

alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more=less

complete -cf sudo

EOF

printf "######   Installing Zsh   ######\n"
sudo pacman -S --noconfirm zsh zsh-completions

printf "######   Installing 'oh my zsh'   ######\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

printf "######   Making Zsh the default shell   ######\n"
echo $user_password | chsh -s /bin/zsh
while [ $? -eq 1 ]
do
	printf "You entered the incorrect password for user: $USER, try again!\n"
	chsh -s /bin/zsh
done

printf "######   Installing Custom Zsh plugins   ######\n"
## zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
## zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
## zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

printf "######   Enabling Custom Zsh plugins   ######\n" 
sudo sed -i 's/^plugins=(git)/plugins=(git archlinux zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search)/g' ~/.zshrc

printf "######   Changing Zsh default theme   ######\n"
sudo sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="lukerandall"/g' ~/.zshrc

printf "######   Adding Zsh key bindings for Keypad   ######\n"
tee -a ~/.zshrc << EOF

## Keypad Bindings

## The actual codes (for example ^[Oq) may be different on your system. 
## You can press Ctrl+v followed by the key in question to get the code for your terminal.

# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[On" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * /
bindkey -s "^[Ol" "+"
bindkey -s "^[OS" "-"
bindkey -s "^[OR" "*"
bindkey -s "^[OQ" "/"
EOF

# printf "######   Installing pamac   ######\n"
# yay -S --noconfirm pamac-aur

# printf "######   Reducing VM writeback time   ######\n"
# sudo touch /etc/sysctl.d/dirty.conf
# sudo tee -a /etc/sysctl.d/dirty.conf << EOF
# vm.dirty_writeback_centisecs = 1500
# EOF

# printf "######   Disabling root (still allows sudo)   ######\n"
# passwd --lock root

printf "######   All done with Post Installation   ######\n\n"
printf "######   Log out and in (or reboot), for shell change to Zsh   ######\n\n"

