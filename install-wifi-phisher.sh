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

#Make www folder
mkdir /WWW
chown www-data:www-data -R /WWW

#Make folder to hold the things
mkdir /Wifi-Attack
cd /Wifi-Attack

#Write the interface to file
echo "$WIFI_INTERFACE" > WifiInterface
echo "return 302 http://$WIFI_DOMAIN/;" > WifiDomain.conf

#Upgrade and update
apt update
apt upgrade -y

#Download neccessary things
apt install -y curl build-essential make gcc libpcre3 libpcre3-dev libpcre++-dev zlib1g-dev libbz2-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev libssl-dev libcurl4-openssl-dev

#Download/Intall nginx
wget -O nginx.tar.gz http://nginx.org/download/nginx-1.13.9.tar.gz
tar -xvf nginx.tar.gz

cd nginx

./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib/nginx/modules \
            --conf-path=/Wifi-Attack/NginxConfig/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/run/nginx.pid \
            --lock-path=/var/lock/nginx.lock \
            --user=www-data \
            --group=www-data \
            --build=Ubuntu \
            --http-client-body-temp-path=/var/lib/nginx/body \
            --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
            --http-proxy-temp-path=/var/lib/nginx/proxy \
            --http-scgi-temp-path=/var/lib/nginx/scgi \
            --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
            --with-openssl=../openssl-1.1.0f \
            --with-openssl-opt=enable-ec_nistp_64_gcc_128 \
            --with-openssl-opt=no-nextprotoneg \
            --with-openssl-opt=no-weak-ssl-ciphers \
            --with-openssl-opt=no-ssl3 \
            --with-pcre=../pcre-8.40 \
            --with-pcre-jit \
            --with-zlib=../zlib-1.2.11 \
            --with-compat \
            --with-file-aio \
            --with-threads \
            --with-http_addition_module \
            --with-http_auth_request_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_mp4_module \
            --with-http_random_index_module \
            --with-http_realip_module \
            --with-http_slice_module \
            --with-http_ssl_module \
            --with-http_sub_module \
            --with-http_stub_status_module \
            --with-http_v2_module \
            --with-http_secure_link_module \
            --with-mail \
            --with-mail_ssl_module \
            --with-stream \
            --with-stream_realip_module \
            --with-stream_ssl_module \
            --with-stream_ssl_preread_module \
            --with-debug \
            --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' \
            --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now'

make
make install

cd ..

# NGINX INSTALLED --> install PHP
add-apt-repository ppa:ondrej/php -y
apt update
apt install php7.0* -y

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

#TODO: DOwnload the Example PORTAL
