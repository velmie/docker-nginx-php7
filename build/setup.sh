#!/usr/bin/env bash

##-------------------------------------------------------
# UPDATE CONFIG FILES
##-------------------------------------------------------

# set timezone machine to UTC
cp /usr/share/zoneinfo/UTC /etc/localtime

# set UTF-8 environment
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LC_CTYPE=en_US.UTF-8' >> /etc/environment


# disable xdebug
rm /etc/php/7.2/mods-available/xdebug.ini

# enable xdebug
# echo 'xdebug.remote_enable=1' >> /etc/php/7.2/mods-available/xdebug.ini
# echo 'xdebug.remote_connect_back=1' >> /etc/php/7.2/mods-available/xdebug.ini
# echo 'xdebug.show_error_trace=1' >> /etc/php/7.2/mods-available/xdebug.ini
# echo 'xdebug.remote_port=9000' >> /etc/php/7.2/mods-available/xdebug.ini
# echo 'xdebug.scream=0' >> /etc/php/7.2/mods-available/xdebug.ini
# echo 'xdebug.show_local_vars=1' >> /etc/php/7.2/mods-available/xdebug.ini
# echo 'xdebug.idekey=PHPSTORM' >> /etc/php/7.2/mods-available/xdebug.ini

# set PHP7 timezone to America/Sao_Paulo
sed -i "s/;date.timezone =*/date.timezone = UTC" /etc/php/7.2/fpm/php.ini
sed -i "s/;date.timezone =*/date.timezone = UTC" /etc/php/7.2/cli/php.ini

# setup php7.2-fpm to not run as daemon (allow my_init to control)
sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini

# create run directories
mkdir -p /var/run/php
chown -R www-data:www-data /var/run/php

# Setup ssh keys
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys


# Add fix_www_permissions to corn
echo '0 * * * * root fix_www_permissions >/dev/null 2>&1' >> /etc/crontab
