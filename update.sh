#!/bin/bash

Black="\033[0;30m"
DarkGray="\033[1;30m"
Red="\033[0;31m"
LightRed="\033[1;31m"
Green="\033[0;32m"
LightGreen="\033[1;32m"
Brown="\033[0;33m"
Yellow="\033[1;33m"
Blue="\033[0;34m"
LightBlue="\033[1;34m"
Purple="\033[0;35m"
LightPurple="\033[1;35m"
Cyan="\033[0;36m"
LightCyan="\033[1;36m"
LightGray="\033[0;37m"
White="\033[1;37m"
NC="\033[0m" # No Color

echo -e "${LightPurple}Debian Distro System Update Utility v1.0.0-alpha.1${NC}"

if [[ $(whoami) != "root" ]]
    then
    echo -e "[${Red}-${NC}] ${LightRed}ERROR: This utility must be run as root (or sudo).${NC}"
    exit -1
fi


logger "Update Script: Starting..."

echo -e "[${Yellow}*${NC}] ${Yellow}Refreshing repository cache...${NC}"
apt-get update -y
echo -e "[${Yellow}*${NC}] ${Yellow}Repository cache refreshed.${NC}"

echo -e "[${Yellow}*${NC}] ${Yellow}Upgrading all existing packages...${NC}"
apt-get upgrade -y
echo -e "[${Yellow}*${NC}] ${Yellow}Existing packages upgraded.${NC}"

echo -e "[${Yellow}*${NC}] ${Yellow}Upgrading Linux distribution (if available)...${NC}"
apt-get dist-upgrade -y
echo -e "[${Yellow}*${NC}] ${Yellow}Linux distribution upgrade processed.${NC}"

echo -e "[${Yellow}*${NC}] ${Yellow}Clean up unused and cached packages...${NC}"
apt-get autoclean -y
apt-get autoremove -y
apt-get purge -y
echo -e "[${Yellow}*${NC}] ${Yellow}Package cleanup complete.${NC}"

if [ $(which raspi-config | wc -l) -gt 0 ]; then
        echo -e "[${Yellow}*${NC}] ${Yellow}Raspberry Pi Detected.${NC}"
        echo -e "[${Yellow}*${NC}] ${Yellow}Update the Raspberry Pi firmware to the latest (if available)...${NC}"
        rpi-update
        echo -e "[${Yellow}*${NC}] ${Yellow}Done updating firmware.${NC}"
fi

logger "Update Script: Done."

while true; do
        read -r -p "[${LightCyan}?${NC}] ${LightCyan}Do you wish to reboot? ${NC}" choice
        case "$choice" in
                y|Y ) echo -e "[${Yellow}*${NC}] ${Yellow}Rebooting...${NC}"; reboot; break;;
                n|N ) echo -e "[${Yellow}*${NC}] ${Yellow}Done.${NC}"; break;;
                * ) echo -e "[${LightRed}*${NC}] ${LightRed}Invalid response. Use "y" or "n".${NC}";;
        esac
done
