#!/bin/bash

### User Variables, Edit these for your environment
disk="sda"
boot="300M"
swap="16G"
root_password="MyPassword"
user_name="bchuter"
user_password="MyPassword"
hostname="arch"
continent_city="Australia/Sydney"
reflector_country="Australia"

printf "######   Updating system clock   ######\n"
timedatectl set-ntp true

printf "######   Applying Country Mirrors via reflector   ######\n"
reflector --country $reflector_country --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

printf "######   Syncing packages database   ######\n"
pacman -Sy --noconfirm

printf "######   Creating partition tables   ######\n"
printf "n\n1\n\n+$boot\nef00\nw\ny\n" | gdisk /dev/$disk
printf "n\n2\n\n+$swap\n8200\nw\ny\n" | gdisk /dev/$disk
printf "n\n3\n\n\n8300\nw\ny\n" | gdisk /dev/$disk

printf "######   Formatting / partition and Mounting   ######\n"
yes | mkfs.ext4 /dev/"$disk"3
mount /dev/"$disk"3 /mnt

printf "######   Formatting /boot partition   ######\n"
yes | mkfs.fat -F32 /dev/"$disk"1

printf "######   Enabling swap   ######\n"
yes | mkswap /dev/"$disk"2
swapon /dev/"$disk"2

printf "######   Installing Arch Linux   ######\n"
yes '' | pacstrap /mnt base base-devel linux linux-firmware e2fsprogs dosfstools networkmanager wget man-db man-pages nano vim dhcpcd open-vm-tools openssh grub efibootmgr os-prober

printf "######   Generating fstab   ######\n"
genfstab -U /mnt >> /mnt/etc/fstab

printf "######   Configuring new system   ######\n"
arch-chroot /mnt /bin/bash <<EOF
printf "######   Setting system clock   ######\n"
ln -sf /usr/share/zoneinfo/$continent_city /etc/localtime
hwclock --systohc --localtime
printf "######   Setting locales   ######\n"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen
printf "######   Setting hostname   ######\n"
echo $hostname > /etc/hostname
printf "######   Setting root password   ######\n"
echo -en "$root_password\n$root_password" | passwd
printf "######   Creating new user   ######\n"
useradd -m -G wheel $user_name
usermod -a -G video $user_name
echo -en "$user_password\n$user_password" | passwd $user_name
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
mount /dev/"$disk"1 /boot/EFI
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

printf "######   Generating Hosts File   ######\n"
tee -a /mnt/etc/hosts << EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname
EOF

printf "######   Unmount Partions   ######\n"
umount -R /mnt

printf "######   Arch Linux is ready. You can reboot now!   ######\n\n\n"

