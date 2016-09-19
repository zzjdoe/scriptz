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

echo -e "${LightPurple}AirCrack Monitor Mode Helper Utility v1.0.0-alpha.1${NC}"

if [[ $(whoami) != "root" ]]
    then
    echo -e "[${Red}-${NC}] ${LightRed}ERROR: This utility must be run as root (or sudo).${NC}"
    exit -1
fi

if [ -z $1 ]
  then
    interfaces=$(ls /sys/class/net/ | tr \\n " ")
    echo -e "[${Red}-${NC}] ${LightRed}ERROR: Please specify a network interface. (e.g. eth0, wlan0, etc)${NC}"
    echo -e "    Known interfaces: $interfaces"
    exit 1
fi

airodump-ng $1
