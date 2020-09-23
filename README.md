# Arch Linux Automated Install Scripts

Inspired by: https://github.com/exah-io/minimal-arch-linux

## Install script (install.sh)

This script has been heavily modified to meet my needs. It is geared to host an Arch install in VM.  
See [Requirements](https://github.com/bchuter/arch-auto-install/blob/master/README.md#requirements) to make some custom choices for your installation.  

Packages installed via **Pacstrap** in this script:  

|||||||||
|-|-|-|-|-|-|-|-|
| [base](https://www.archlinux.org/packages/core/any/base/) | [base-devel](https://www.archlinux.org/groups/x86_64/base-devel/) | [linux](https://www.archlinux.org/packages/core/x86_64/linux/) | [linux-firmware](https://www.archlinux.org/packages/core/any/linux-firmware/) | [e2fsprogs](https://www.archlinux.org/packages/core/x86_64/e2fsprogs/) | [dosfstools](https://www.archlinux.org/packages/core/x86_64/dosfstools/) | [networkmanager](https://www.archlinux.org/packages/extra/x86_64/networkmanager/) | [wget](https://www.archlinux.org/packages/extra/x86_64/wget/) |
| [man-db](https://www.archlinux.org/packages/core/x86_64/man-db/) | [man-pages](https://www.archlinux.org/packages/core/any/man-pages/) | [nano](https://www.archlinux.org/packages/core/x86_64/nano/) | [vim](https://www.archlinux.org/packages/extra/x86_64/vim/) | [dhcpcd](https://www.archlinux.org/packages/core/x86_64/dhcpcd/) | [open-vm-tools](https://www.archlinux.org/packages/community/x86_64/open-vm-tools/) | [openssh](https://www.archlinux.org/packages/core/x86_64/openssh/) | [grub](https://www.archlinux.org/packages/core/x86_64/grub/) |
| [efibootmgr](https://www.archlinux.org/packages/core/x86_64/efibootmgr/) | [os-prober](https://www.archlinux.org/packages/community/x86_64/os-prober/) |||||||

### Requirements
- **UEFI mode**
- **Change the variables at the top of [install.sh](/install.sh)**

| Variable | Example | Comment |
|:-|:-|:-|
| **disk** | sda | Set the disk name to be used (To find your disk, run **`lsblk`**) |
| **boot** | 300M | Set your desired EFI boot partition size. Must be in the format "300M" or "1G" etc |
| **swap** | 16G | Set your desired SWAP partition size. Must be in the format "300M" or "1G" etc |
| **root_password** | MyPassword | Set your root password |
| **user_name** | johndoe | Set your non root username (will be auto added to SUDO) |
| **user_password** | MyPassword | Set your user password for the user created above |
| **hostname** | arch | Set the system hostname |
| **continent_city** | Australia/Sydney | Set your country timezone, must have the following format: Zone/SubZone |
| **reflector_country** | Australia | Set your country to be used by `reflector`. <BR> See [Reflector Country List](https://github.com/bchuter/arch-auto-install/blob/master/README.md#reflector-country-list) for valid entries. <BR> For further info on reflector, see: https://wiki.archlinux.org/index.php/Reflector |

### Partitions

| Name                                                  | Type  | Mountpoint |  Size       |
| ----------------------------------------------------- | :---: | :--------: |  :--:       |
| sda1                                                  | disk  |            |             |
| ├─sda1                                                | part  |   /boot    |  300M / Set custom via variables      |
| ├─sda2                                                | part  |    SWAP    |  16G  / Set custom via variables      |
| ├─sda3                                                | part  |      /     |  Remaining  |


## Post install script (post-install.sh)

- Gnome / KDE / Sway (separate scripts)
- UFW (deny incoming, allow outgoing)
- Automatic login
- Fonts
- Wallpapers
- Multilib
- yay (AUR helper)
- Plymouth
- Flatpak support (Firefox installed as Flatpak)
- Lutris with Wine support (commented)
- Sway only:
   - Base16 theme: alacritty, rofi, vim
   - Flatpak: automatic updates via systemd timer

### Requirements
 Variable | Example | Comment |
|:-|:-|:-|
| **reflector_country** | Australia | Set your country to be used by `reflector`. <BR> See [Reflector Country List](https://github.com/bchuter/arch-auto-install/blob/master/README.md#reflector-country-list) for valid entries. <BR> For further info on reflector, see: https://wiki.archlinux.org/index.php/Reflector |

<BR>
<BR>

## Installation guide

1. Download and boot into the latest [Arch Linux iso](https://www.archlinux.org/download/)
2. Connect to the internet. If using wifi, you can use `wictl` to connect to a network:
   - scan for networks: `station wlan0 scan`
   - list available networks: `station wlan0 get-networks`
   - connect to a network: `station wlan0 connect SSID`
3. Clear all existing partitions (see below: MISC - How to clear all partitions)
4. Give highest priority to the closest mirror to you on /etc/pacman.d/mirrorlist by moving it to the top
5. Sync repos: `pacman -Sy` and install wget `pacman -S wget`
6. `wget https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/1_install.sh`
7. Change the variables at the top of the file (lines 3 through 9)
   - continent_country must have the following format: Zone/SubZone . e.g. Europe/Berlin
   - run `timedatectl list-timezones` to see full list of zones and subzones
8. Make the script executable: `chmod +x 1_install.sh`
9. Run the script: `./1_install.sh`
10. Reboot into Arch Linux
11. Connect to wifi with `nmtui`
12. `wget https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/2_gnome.sh` or `2_plasma.sh` or `2_sway.sh`
13. Make the script executable: `chmod +x 2_gnome.sh` or `chmod +x 2_plasma.sh` or `chmod +x 2_sway.sh`
14. Run the script: `./2_gnome.sh` or `./2_plasma.sh` or `./2_sway.sh`

## Misc guides

### How to clear all partitions

```
gdisk /dev/nvme0n1
x
z
y
y
```

### How to setup Github with SSH Key

```
git config --global user.email "Github external email"
git config --global user.name "Github username"
ssh-keygen -t rsa -b 4096 -C "Github email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
copy SSH key and add to Github (eg. vim ~/.ssh/id_rsa.pub and copy content into github.com)
```

### How to chroot

```
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
cryptsetup luksOpen /dev/nvme0n1p2 cryptlvm
mount /dev/vg0/root /mnt
arch-chroot /mnt
```

### Reflector Country List

| Country                | Country Code |
| :--------------------- | :----------- |
| Australia              | AU |
| Austria                | AT |
| Bangladesh             | BD |
| Belarus                | BY |
| Belgium                | BE |
| Bosnia and Herzegovina | BA |
| Brazil                 | BR |
| Bulgaria               | BG |
| Canada                 | CA |
| Chile                  | CL |
| China                  | CN |
| Colombia               | CO |
| Croatia                | HR |
| Czechia                | CZ |
| Denmark                | DK |
| Ecuador                | EC |
| Finland                | FI |
| France                 | FR |
| Georgia                | GE |
| Germany                | DE |
| Greece                 | GR |
| Hong Kong              | HK |
| Hungary                | HU |
| Iceland                | IS |
| India                  | IN |
| Indonesia              | ID |
| Iran                   | IR |
| Ireland                | IE |
| Israel                 | IL |
| Italy                  | IT |
| Japan                  | JP |
| Kazakhstan             | KZ |
| Kenya                  | KE |
| Latvia                 | LV |
| Lithuania              | LT |
| Luxembourg             | LU |
| Netherlands            | NL |
| New Caledonia          | NC |
| New Zealand            | NZ |
| North Macedonia        | MK |
| Norway                 | NO |
| Pakistan               | PK |
| Paraguay               | PY |
| Philippines            | PH |
| Poland                 | PL |
| Portugal               | PT |
| Romania                | RO |
| Russia                 | RU |
| Serbia                 | RS |
| Singapore              | SG |
| Slovakia               | SK |
| Slovenia               | SI |
| South Africa           | ZA |
| South Korea            | KR |
| Spain                  | ES |
| Sweden                 | SE |
| Switzerland            | CH |
| Taiwan                 | TW |
| Thailand               | TH |
| Turkey                 | TR |
| Ukraine                | UA |
| United Kingdom         | GB |
| United States          | US |
| Vietnam                | VN |
