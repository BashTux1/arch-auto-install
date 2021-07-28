#!/usr/bin/env bash

### User Variables, Edit these for your environment
### Depricated. Script now reads input (see below) from user. 
# disk="sda"
# boot="300M"
# swap="16G"
# root_password="MyPassword"
# user_name="bchuter"
# user_password="MyPassword"
# hostname="arch"
# continent_city="Australia/Sydney"
# reflector_country="Australia"

### Read input from user for required variables

printf "\n>>>   Listing all Disk Devices\n\n"
lsblk

printf "\n>>>   This sets the [Disk Device] to use\n\n"
read -r -p "Enter Disk Device to Use [sda]: " disk
disk=${disk:-sda}

printf "\n>>>   This sets the desired [EFI boot partition size]\n"
printf ">>>   Must be in the format [300M] or [1G] etc\n\n"
read -r -p "Enter Boot Partition Size [300M]: " boot
boot=${boot:-300M}

printf "\n>>>   This sets the desired [SWAP partition size]\n"
printf ">>>   Must be in the format [300M] or [1G] etc\n\n"
read -r -p "Enter Swap Partition Size [16G]: " swap
swap=${swap:-16G}

printf "\n>>>   This sets the desired [root password] for this new Arch install\n\n"
while true; do
	read -r -s -p "Enter the Root Password: " root_password1
	printf "\n"
	read -r -s -p "Confirm the Root Password: " root_password
	printf "\n"

	[ "${root_password1}" = "${root_password}" ] && break
	printf "\nPasswords DO NOT match, Please try again\n"
done

printf "\n>>>   This sets the desired non-root [username] for this new Arch install.\n"
printf ">>>   Note: The user will automatically be added to SUDOers\n\n"
read -r -p "Enter the User Name: " user_name

while true; do
	read -r -s -p "Enter the User Password for [${user_name}]: " user_password1
	printf "\n"
	read -r -s -p "Confirm the User Password for [${user_name}]: " user_password
	printf "\n"

	[ "${user_password1}" = "${user_password}" ] && break
	printf "\nPasswords DO NOT match, Please try again\n"
done

printf "\n>>>   This sets the system hostname\n\n"
read -r -p "Enter Hostname [arch]: " hostname
hostname=${hostname:-arch}

printf "\n>>>   This sets the system Timezone\n"
printf ">>>   Must have the following format: Zone/SubZone\n"
printf ">>>   See: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones\n\n"
read -r -p "Enter the system Timezone [Australia/Sydney]: " continent_city
continent_city=${continent_city:-Australia/Sydney}

printf "\n>>>   This sets the country to be used by the [reflector] script\n"
printf ">>>   Reflector is a Python script which can retrieve the most up-to-date package mirrors\n"
printf ">>>   See: https://github.com/BashTux1/arch-auto-install/blob/master/README.md#reflector-country-list\n\n"
read -r -p "Enter Reflector Country [Australia]: " reflector_country
reflector_country=${reflector_country:-Australia}

### End of Input Read 

printf "######   Updating system clock   ######\n"
timedatectl set-ntp true

printf "######   Applying Country Mirrors via reflector   ######\n"
reflector --country "${reflector_country}" --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

printf "######   Syncing packages database   ######\n"
pacman -Sy --noconfirm

printf "######   Creating partition tables   ######\n"
printf "n\n1\n\n+%s\nef00\nw\ny\n" "${boot}" | gdisk /dev/"${disk}"
printf "n\n2\n\n+%s\n8200\nw\ny\n" "${swap}" | gdisk /dev/"${disk}"
printf "n\n3\n\n\n8300\nw\ny\n" | gdisk /dev/"${disk}"

printf "######   Formatting / partition and Mounting   ######\n"
yes | mkfs.ext4 /dev/"${disk}"3
mount /dev/"${disk}"3 /mnt

printf "######   Formatting /boot partition   ######\n"
yes | mkfs.fat -F32 /dev/"${disk}"1

printf "######   Enabling swap   ######\n"
yes | mkswap /dev/"${disk}"2
swapon /dev/"${disk}"2

printf "######   Installing Arch Linux   ######\n"
yes '' | pacstrap /mnt base base-devel linux linux-firmware e2fsprogs dosfstools networkmanager wget man-db man-pages nano vim dhcpcd open-vm-tools openssh grub efibootmgr os-prober git

printf "######   Generating fstab   ######\n"
genfstab -U /mnt >> /mnt/etc/fstab

printf "######   Configuring new system   ######\n"
arch-chroot /mnt /bin/bash <<EOF
printf "######   Setting Time Zone   ######\n"
ln -sf /usr/share/zoneinfo/"${continent_city}" /etc/localtime
hwclock --systohc --localtime
printf "######   Setting locales   ######\n"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen
printf "######   Setting hostname   ######\n"
echo "${hostname}" > /etc/hostname
printf "######   Setting root password   ######\n"
echo -en "${root_password}\n${root_password}" | passwd
printf "######   Creating new user   ######\n"
useradd -m -G wheel,video "${user_name}"
echo -en "${user_password}\n${user_password}" | passwd "${user_name}"
printf "######   Enabling DHCP   ######\n"
systemctl enable dhcpcd
printf "######   Enabling NetworkManager   ######\n"
systemctl enable NetworkManager
printf "######   Enabling Open VM Tools   ######\n"
systemctl enable vmtoolsd
printf "######   Enabling OpenSSH   ######\n"
systemctl enable sshd
printf "######   Adding user as a sudoer   ######\n"
echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo
printf "######   Installing GRUB Bootloader   ######\n"
mkdir /boot/EFI
mount /dev/"${disk}"1 /boot/EFI
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

printf "######   Generating Hosts File   ######\n"
tee -a /mnt/etc/hosts <<EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	"${hostname}".localdomain	"${hostname}"
EOF

printf "######   Unmount Partions   ######\n"
umount -R /mnt

printf "\n\n######   Arch Linux is ready. You can reboot now!   ######\n"

### This asks if you want to reboot
printf "\n-------------------------------------\n"
while true; do
	read -r -p ">>>   Would you like to Reboot [Y]: " reboot
	reboot=${reboot:-Y}

	case $reboot in
		[yY][eE][sS]|[yY])
			break
		;;
		[nN][oO]|[nN])
			break
		;;
		*)
			echo ">>>   Invalid input... Valid entries are E.g. [Y / N] or [y / n] or [Yes / No]"
		;;
	esac
done

if [[ "${reboot}" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	reboot
fi
