#!/usr/bin/env bash

# fix vagrant 'default: stdin: is not a tty' bug (https://github.com/mitchellh/vagrant/issues/1673)
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

echo "Provisioning virtual machine..."

echo "Updating PHP repository"
apt-get install python-software-properties build-essential -y
add-apt-repository ppa:ondrej/php5 -y
apt-get update

echo "Installing Git"
apt-get install git -y

echo "Installing Nginx"
apt-get install nginx -y

echo "Installing PHP"
apt-get install php5-common php5-dev php5-cli php5-fpm -y

echo "Installing PHP extensions"
apt-get install curl php5-curl php5-gd php5-mcrypt php5-mysql -y

echo "Configure MySQL"
apt-get install debconf-utils -y
debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"

echo "Install MySQL"
apt-get install mysql-server -y

echo "Configuring Nginx"
cp /var/www/provision/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost
ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled
rm -rf /etc/nginx/sites-available/default
service nginx restart

# sulu-standard
cd /var/www
echo "Configure PHPCR (MySQL)"
cp app/config/phpcr_doctrine_dbal.yml.dist app/config/phpcr.yml

echo "Create Webspacefile"
cp app/Resources/webspaces/sulu.io.xml.dist app/Resources/webspaces/sulu.io.xml

echo "Create Pagetemplates"
cp app/Resources/pages/default.xml.dist app/Resources/pages/default.xml
cp app/Resources/pages/overview.xml.dist app/Resources/pages/overview.xml
cp app/Resources/pages/complex.xml.dist app/Resources/pages/complex.xml

echo "Create Snippettemplates"
cp app/Resources/snippets/default.xml.dist app/Resources/snippets/default.xml

echo "Compoer install"
composer install

echo "Set permissions"
rm -rf app/cache/*
rm -rf app/logs/*
mkdir app/data
mkdir uploads && mkdir uploads/media/
mkdir web/uploads && mkdir web/uploads/media/*
sudo setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx app/cache app/logs uploads/media web/uploads/media app/data
sudo setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx app/cache app/logs uploads/media web/uploads/media app/data

echo "Run build scripts"
app/console sulu:build dev
