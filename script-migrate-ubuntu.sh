#!/bin/sh
apt-get -y update
apt-get install -y apache2
apt-get install -y unzip
systemctl restart apache2.service
cd /var/www/html/
rm index.html
wget https://raw.githubusercontent.com/ahmadzahoory/az300template/master/az-300-website-migration-03.zip
unzip az-300-website-migration-03.zip