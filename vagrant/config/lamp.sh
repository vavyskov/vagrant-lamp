#!/usr/bin/env bash

#DBHOST=localhost

## Variables
MARIADB_ROOT_PASSWORD=root
PHPMYADMIN_PASSWORD=phpmyadmin

MARIADB_DB=mariadb
MARIADB_USER=mariadb
MARIADB_PASSWORD=mariadb

POSTGRES_ROOT_PASSWORD=postgres

#POSTGRES_DB=postgresql
#POSTGRES_USER=postgresql
#POSTGRES_PASSWORD=postgresql



## Vagrant user
mkdir -p /home/vagrant/workspace/public
mkdir -p /home/vagrant/workspace/private

#echo "Public folder <a href='info.php'>PHP info</a> | <a href='db'>DB admin</a>" > /home/vagrant/workspace/public/index.html
#echo '<?php
#  $cmd = "cat /etc/*-release";
#  exec($cmd, $version);
#  echo "<center>" . $version[0] . "<center>";
#  phpinfo();
#  ' > /home/vagrant/workspace/public/info.php



## Add user (password: user)
useradd user -p user -m -s /bin/bash
mkdir -p /home/user/workspace/public
mkdir -p /home/user/workspace/private
chown -R user:user /home/user/workspace



## ?????????????????????
## Initialization mc
## use_internal_edit=1

#cp /vagrant/config/mc/.mc.ini /home/vagrant/
#chown vagrant:vagrant /home/vagrant/.mc.ini
#chmod -R -x /home/vagrant/.mc.ini

## Edit=%var{EDITOR:editor} %f
#cp -p /vagrant/config/mc/mc.ext /home/vagrant/.config/mc/
#chown vagrant:vagrant /home/vagrant/.config/mc/mc.ext
# chmod -R -x /home/vagrant/.config/mc/mc.ext

## -----------------------------------------------------------------------------

## Sources
apt-get update
apt-get upgrade -y

## Certificates
apt install -y ca-certificates openssl

## Language
apt install -y locales
locale-gen cs_CZ.UTF-8

## System tools
apt install -y mc curl zip unzip
#apt install -y wget vim nmon

## IPv6
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/ipv6.conf
sysctl -p

## VMware
apt install -y open-vm-tools

## SSH
sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
#sed -i 's/#PermitEmptyPasswords/PermitEmptyPasswords/' /etc/ssh/sshd_config

## -----------------------------------------------------------------------------

## Node.js
apt install -y nodejs

## Apache
apt install -y apache2
cp /vagrant/config/apache.conf /etc/apache2/sites-enabled/000-default.conf

## Apache website permissions
apt install -y libapache2-mpm-itk
a2enmod mpm_itk

## Apache clean URL and caching
a2enmod rewrite expires

## -----------------------------------------------------------------------------

## PHP
apt install -y php php-gd php-mbstring php-opcache php-xml php-curl
#apt install -y php-cli php-xdebug libpng-dev
cp /vagrant/config/php.ini /etc/php/7.0/apache2/conf.d/

## -----------------------------------------------------------------------------

## MongoDB (default port is 27017)
apt install -y mongodb php-mongodb
#apt install -y mongodb php-mongodb >> /vagrant/vm_build_mongodb.log 2>&1

## SQLite
apt install -y php-sqlite3

## Mariadb

## Mariadb - set root password (Secure)
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MARIADB_ROOT_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MARIADB_ROOT_PASSWORD"

## Mariadb - set root password (Dangerous)
#mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "SET PASSWORD FOR root@localhost=PASSWORD('$MARIADB_ROOT_PASSWORD');"

apt install -y mysql-server php-mysql

## Mariadb - set all permissions for root user (Optional)
#mysql -u root -e "GRANT ALL ON *.* TO root@localhost IDENTIFIED BY 'root'"

## Mariadb - security
#mysql_secure_installation >> /vagrant/vm_build_mysql.log 2>&1

cp /vagrant/config/mariadb.cnf /etc/mysql/conf.d/

## Mariadb - initialization (Dangerous)
mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "
  CREATE DATABASE $MARIADB_DB CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci;
  GRANT ALL ON $MARIADB_DB.* TO $MARIADB_USER@localhost IDENTIFIED BY '$MARIADB_PASSWORD';
"
#ALTER DATABASE $MARIADB_DB CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci;



## PostgreSQL
apt install -y postgresql php-pgsql

sudo -u postgres psql -c "ALTER ROLE postgres WITH PASSWORD '$POSTGRES_ROOT_PASSWORD'"

#sudo -u postgres createdb $POSTGRES_DB
#sudo -u postgres createuser $POSTGRES_USER
#sudo -u postgres psql -c "
#  ALTER ROLE $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';
#  GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
#"



## Notes:
##sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_DB WITH OWNER $POSTGRES_USER;"
##sudo -u postgres psql -c "CREATE DATABASE music ENCODING 'UTF8'  LC_COLLATE 'utf8mb4_czech_ci';"



## Enable password-base authentication
sed -i 's/local.*all.*postgres.*peer/local\tall\t\tpostgres\t\t\t\tmd5/' /etc/postgresql/9.6/main/pg_hba.conf
sed -i 's/local.*all.*all.*peer/local\tall\t\tall\t\t\t\t\tmd5/' /etc/postgresql/9.6/main/pg_hba.conf

## Init the database
#/etc/profile.d/profile.local.sh

## -----------------------------------------------------------------------------

## Adminer
apt install -y adminer

## Adminer - MongoDB
## ToDo: login ???
#apt install -y php-pear php-dev
#sudo pecl install mongodb

## PhpMyAdmin

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MARIADB_ROOT_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_PASSWORD"

sudo apt-get -y install phpmyadmin



## PhpMyAdmin - security
chown vagrant:vagrant /var/lib/phpmyadmin/blowfish_secret.inc.php

#randomBlowfishSecret=`openssl rand -base64 32`;
#sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php



## PhpPgAdmin
apt install -y phppgadmin
cp /vagrant/config/phppgadmin.conf /etc/apache2/conf-available/

## Enable postgres user login
sed -i "s/extra_login_security'] = true/extra_login_security'] = false/" /etc/phppgadmin/config.inc.php

## Custom HomePage
cp -r /vagrant/config/db /var/www/

## -----------------------------------------------------------------------------

## Development

## Composer
apt install -y git composer



## GLOBAL Drush (variant A)
apt install -y mysql-client
curl -fsSL -o /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar
chmod +x /usr/local/bin/drush

## GLOBAL Drush (variant B)
## apt install -y mysql-client
#COMPOSER_HOME=/opt/composer composer global require drush/drush:8
#ln -s /opt/composer/vendor/drush/drush/drush /usr/local/bin/drush

## Drupal console
curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal

## Setup XDebug
#cp xdebug-docker.ini /usr/local/etc/php/conf.d/
#echo "zend_extension = '$(find / -name xdebug.so 2> /dev/null)'\n$(cat /usr/local/etc/php/conf.d/xdebug-docker.ini)" > /usr/local/etc/php/conf.d/xdebug-docker.ini
#cp /usr/local/etc/php/conf.d/xdebug-docker.ini /etc/php5/cli/conf.d/

## Swap (variant A)
## Enble dynamic swap space to prevent "Out of memory" crashes
apt install -y swapspace

## Swap (variant B)
## https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04
#fallocate -l 4G /swapfile
#chmod 0600 /swapfile
#mkswap /swapfile
#swapon /swapfile
#echo '/swapfile none swap sw 0 0' >> /etc/fstab
#echo vm.swappiness = 10 >> /etc/sysctl.conf
#echo vm.vfs_cache_pressure = 50 >> /etc/sysctl.conf
#sysctl -p

## -----------------------------------------------------------------------------

## Image tools
#apt install -y libjpeg-progs optipng gifsicle php-imagick

## -----------------------------------------------------------------------------

## Services
service apache2 reload
service postgresql reload
service mongodb start
#service swapspace status

## -----------------------------------------------------------------------------

## Security




## -----------------------------------------------------------------------------

#mv /var/www/html/index.html /var/www/html/info.html
#rm -rf /var/www/html


#if ! [ -L /var/www ]; then
#  rm -rf /var/www
#  ln -fs /vagrant /var/www
#fi

## -----------------------------------------------------------------------------

## Cleaning
#apt-get clean
#apt-get autoclean
#apt-get -y autoremove
#rm -rf /var/lib/apt/lists/*
