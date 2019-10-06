#!/bin/sh
sudo yum -y update
sudo yum install -y httpd
sudo yum install -y unzip
sudo service httpd start
sudo systemctl enable httpd.service
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload
cd /var/www/html/
sudo wget https://raw.githubusercontent.com/ahmadzahoory/az300template/master/az-300-website-migration-03.zip
sudo unzip az-300-website-migration-03.zip