#!/bin/bash

Black='\033[0;30m'
DarkGray='\033[1;30m'
Red='\033[0;31m'
LightRed='\033[1;31m'
Green='\033[0;32m'
LightGreen='\033[1;32m'
Brown='\033[0;33m'
Yellow='\033[1;33m'
Blue='\033[0;34m'
LightBlue='\033[1;34m'
Purple='\033[0;35m'
LightPurple='\033[1;35m'
Cyan='\033[0;36m'
LightCyan='\033[1;36m'
LightGray='\033[0;37m'
White='\033[1;37m'
NC='\033[0m' # No Color


echo -e "${LightPurple}Encrypted USB Utility v1.0.0-alpha.1${NC}"

if [[ $(whoami) != 'root' ]]
    then
    echo -e "[${Red}-${NC}] ${LightRed}ERROR: This utility must be run as root (or sudo).${NC}"
    exit -1
fi

if [ -z "$1" ]
    then
    echo -e "[${LightRed}-${NC}] ${LightRed}ERROR: Argument missing. Include device to partition. (e.g. /dev/sdb).${NC}"

    device=$(tail /var/log/syslog | grep GB | cut -f 3 -d '[' | cut -f 1 -d ']')
    if [ -z "$device" ]
    then
        echo -e "[${LightRed}-${NC}] ${LightRed}No USB device recently plugged in.${NC}"
    else
        echo -e "[${Green}+${NC}] ${Green}Last USB device plugged in: ${LightCyan}/dev/$device${NC}"
    fi

    exit -2
fi


echo -e "[${Yellow}*${NC}] ${Yellow}Creating primary partition...${NC}"
echo "o\nn\np\n1\n\n\nw\n\n" | /sbin/fdisk $1

echo ""
echo -e "[${Yellow}*${NC}] ${Yellow}Creating LUKS setup...${NC}"
cryptsetup luksFormat --hash=sha512 --key-size=512 --cipher=aes-xts-plain64 --verify-passphrase $1

echo -e "[${Yellow}*${NC}] ${Yellow}Open the encrypted device (on '/dev/mapper/usb_crypt')...${NC}"
cryptsetup luksOpen $1 usb_crypt

echo -e "[${Yellow}*${NC}] ${Yellow}You can fill the partition with empty data${NC}"
echo -e -n "    ${LightPurple}Format partition with zeros? ${NC}"
while true; do
        read -r -p "> " choice
        case "$choice" in
                y|Y ) echo -e "[${Yellow}*${NC}] ${Yellow}Formatting mapped partition with random data...${NC}"; \
                                $(pv -tpreb /dev/zero | dd of=/dev/mapper/usb_crypt bs=128M); \
                                break;;
                n|N ) echo -e "[${Yellow}*${NC}] ${Yellow}Skipping...${NC}"; break;;
                * ) echo -e "[${LightRed}-${NC}] ${LightRed}Invalid response. Use 'y' or 'n'.${NC}";;
        esac
done

echo -e "[${Yellow}*${NC}] ${Yellow}Formatting encrypted partition ($11)...${NC}"
mkfs.ext4 /dev/mapper/usb_crypt 
echo ""

echo -e "[${Yellow}*${NC}] ${Yellow}Setting permissions and ownership...${NC}"
chmod -R 777 /dev/mapper/usb_crypt/*
chown -R root:sudo /dev/mapper/usb_crypt/*

echo -e "[${Yellow}*${NC}] ${Yellow}Closing the encrypted device (on '/dev/mapper/usb_crypt')${NC}"
cryptsetup luksClose usb_crypt

echo -e "[${Yellow}*${NC}] ${Yellow}Done.${NC}"
