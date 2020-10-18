#!/bin/bash

# Bash script to install WordPress on Ubuntu 18.04
## Check if running as root
if [ "$(id -u)" != "0" ]; then
  echo "Script harus dijalankan oleh user Root" 1>&2
  exit 1
fi

## Check Current directory
pwd=$(pwd)

## Read user input value for mysql root password
read -p 'nama database untuk wordpress [wp_db]: ' wordpress_db_name
read -p 'password database [only-alphanumeric]: ' db_root_password
echo

## Update 
apt update -y

## Install & Configure Apache
sudo apt install apache2 apache2-utils -y
sudo ufw allow in "Apache Full"
systemctl start apache2
systemctl enable apache2

## Install PHP
apt install php libapache2-mod-php php-mysql -y

## Install MySQL database server
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"
apt install mysql-server mysql-client -y

## Install WordPress
rm /var/www/html/index.*
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rsync -av wordpress/* /var/www/html/

## Change Permissions
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

## Configure Database
mysql -u root -p$db_root_password <<QUERY_INPUT
CREATE DATABASE $wordpress_db_name;
GRANT ALL PRIVILEGES ON $wordpress_db_name.* TO 'root'@'localhost' IDENTIFIED BY '$db_root_password';
FLUSH PRIVILEGES;
EXIT
QUERY_INPUT

## Add Database Credentias in wordpress
cd /var/www/html/
sudo mv wp-config-sample.php wp-config.php
perl -pi -e "s/database_name_here/$wordpress_db_name/g" wp-config.php
perl -pi -e "s/username_here/root/g" wp-config.php
perl -pi -e "s/password_here/$db_root_password/g" wp-config.php

## Enabling Mod Rewrite
a2enmod rewrite
php5enmod mcrypt

## Install PhpMyAdmin
apt install phpmyadmin -y

## Configure PhpMyAdmin
echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf

## Restart Apache and Mysql
service apache2 restart
service mysql restart

## Remove Previous Donwloaded Files
cd $pwd
rm -rf latest.tar.gz wordpress

echo "WordPress installation is complete."
echo "You can access it on your public ip address port 80."