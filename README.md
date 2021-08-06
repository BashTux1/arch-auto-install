# Arch Linux Automated Install Scripts

Attribution: https://github.com/exah-io/minimal-arch-linux

These scripts has been modified to meet my needs.
Take care to read through the scripts if you intend to make use of them. 

## Install script (install.sh)

See [Requirements](https://github.com/BashTux1/arch-auto-install/blob/master/README.md#requirements).  

Packages installed via **Pacstrap** in this script:  

|||||||||
|-|-|-|-|-|-|-|-|
| [base](https://www.archlinux.org/packages/core/any/base/) | [base-devel](https://www.archlinux.org/groups/x86_64/base-devel/) | [linux](https://www.archlinux.org/packages/core/x86_64/linux/) | [linux-firmware](https://www.archlinux.org/packages/core/any/linux-firmware/) | [e2fsprogs](https://www.archlinux.org/packages/core/x86_64/e2fsprogs/) | [dosfstools](https://www.archlinux.org/packages/core/x86_64/dosfstools/) | [networkmanager](https://www.archlinux.org/packages/extra/x86_64/networkmanager/) | [wget](https://www.archlinux.org/packages/extra/x86_64/wget/) |
| [man-db](https://www.archlinux.org/packages/core/x86_64/man-db/) | [man-pages](https://www.archlinux.org/packages/core/any/man-pages/) | [nano](https://www.archlinux.org/packages/core/x86_64/nano/) | [vim](https://www.archlinux.org/packages/extra/x86_64/vim/) | [dhcpcd](https://www.archlinux.org/packages/core/x86_64/dhcpcd/) | [open-vm-tools](https://www.archlinux.org/packages/community/x86_64/open-vm-tools/) | [openssh](https://www.archlinux.org/packages/core/x86_64/openssh/) | [grub](https://www.archlinux.org/packages/core/x86_64/grub/) |
| [efibootmgr](https://www.archlinux.org/packages/core/x86_64/efibootmgr/) | [os-prober](https://www.archlinux.org/packages/community/x86_64/os-prober/) | [git](https://www.archlinux.org/packages/extra/x86_64/git/) ||||||

### Requirements
- **UEFI mode** must be used, this script is not written to work with legacy BIOS

### User Read Input

| Value | Example/Default | Comment |
|:-|:-|:-|
| **Disk** | sda | Set the disk name to be used (To find your disk, run **`lsblk`**) |
| **Boot Partition** | 300M | Set your desired EFI boot partition size. Must be in the format "300M" or "1G" etc |
| **SWAP Partition** | 16G | Set your desired SWAP partition size. Must be in the format "300M" or "1G" etc |
| **root Password** | MyPassword | Set your root password |
| **User Name** | johndoe | Set your non root username (will be auto added to SUDOers) |
| **User Password** | MyPassword | Set your user password for the user created above |
| **Hostname** | arch | Set the system hostname |
| **Timezone** | Australia/Sydney | Set your country timezone, must have the following format: Zone/SubZone |
| **Reflector Country** | Australia | This sets the country to be used by the [reflector](https://wiki.archlinux.org/index.php/Reflector) script. <BR>  Reflector is a Python script which can retrieve the most up-to-date package mirrors <BR> See [Reflector Country List](https://github.com/BashTux1/arch-auto-install/blob/master/README.md#reflector-country-list) for valid entires |

### Partitions

| Name                                                  | Type  | Mountpoint |  Size       |
| ----------------------------------------------------- | :---: | :--------: |  :--:       |
| sda1                                                  | disk  |            |             |
| ├─sda1                                                | part  |   /boot    |  300M / Set custom via variables      |
| ├─sda2                                                | part  |    SWAP    |  16G  / Set custom via variables      |
| └─sda3                                                | part  |      /     |  Remaining  |

### Overview of Script Functions

- Read User Input for required information
- Update system clock
- Apply country mirrors via reflector
- Sync package database
- Create partition tables
- Format / partition and Mount it
- Format /boot partition
- Enable swap
- Install Arch Linux
- Generate fstab
- Configure new system
   - Set Time Zone
   - Set locales
   - Set hostname
   - Set root password
   - Create new user
   - Enable DHCP (dhcpcd)
   - Enable NetworkManager
   - Enable Open VM Tools
   - Enable OpenSSH
   - Add user as a sudoer
   - Install GRUB Bootloader
   - Generate Hosts File
- Unmount Partions
- Arch Linux is ready

## Post install script (post-install.sh)

### Overview of Script Functions

- Read User Input for required information and optional tasks
- Sync package database
- reflector - Install and configure mirrors for country set in variable
- "**Optional**" [UFW](https://wiki.archlinux.org/index.php/Uncomplicated_Firewall) (Uncomplicated Firewall)
- Install common apps: git, htop, p7zip, ripgrep, unzip, unrar
- "**Optional**" Install yay (AUR helper)
- Ricing bash
- "**Optional**" Install Zsh and Oh My Zsh
- Create user folders (xdg-user-dirs)
- Fonts

### User Read Input
 Value | Example/Default | Comment |
|:-|:-|:-|
| **User Password** | MyPassword | The non-root user password is required for SUDO |
| **Reflector Country** | Australia | This sets the country to be used by the [reflector](https://wiki.archlinux.org/index.php/Reflector) script. <BR>  Reflector is a Python script which can retrieve the most up-to-date package mirrors <BR> See [Reflector Country List](https://github.com/BashTux1/arch-auto-install/blob/master/README.md#reflector-country-list) for valid entires |
| **ufw** "Optional" | "Y" / N | "UFW" (Uncomplicated Firewall), Optional Installation |
| **yay** "Optional" | "Y" / N | "yay" AUR Helper, Optional Installation |
| **zsh** "Optional" | "Y" / N | "Zsh" along with "Oh My Zsh", Optional Installation |

<BR>
<BR>

## Installation Guide

1. Download and boot into the latest [Arch Linux iso](https://www.archlinux.org/download/)
2. Connect to the internet. Assuming the use of DHCP, in which case this should be automatically done.
3. Sync repos: `pacman -Sy` and install **wget** `pacman -S wget`
4. `wget -O install.sh https://git.io/JLyzt` - VM Install
5. `wget -O install.sh https://git.io/JBNxW` - XPS Install
6. Make the script executable: `chmod +x install.sh`
7. Run the script: `./install.sh`
8. Shutdown and unmount boot Arch Linux ISO.
9. Boot into your new install of Arch Linux
10. Login as non root user
11. Clone the Arch Auto Install Scripts: `git clone https://github.com/BashTux1/arch-auto-install.git`
12. Change into the dir: `cd arch-auto-install/`
13. Make the scripts executable: `chmod +x *.sh`
14. Run post-install script: `./post-install.sh`
15. **Optionally**, chose a Desktop Environment to install by running the required script.
16. **Optionally**, setup a Static IP by running `nmtui` (Network Manager Text User Interface)

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
