FROM phusion/baseimage:0.10.2

# ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# change resolv.conf
RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# setup
ENV HOME /root
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# nginx-php installation
RUN DEBIAN_FRONTEND="noninteractive" add-apt-repository ppa:ondrej/php
RUN DEBIAN_FRONTEND="noninteractive" apt update
RUN DEBIAN_FRONTEND="noninteractive" apt -y upgrade
RUN DEBIAN_FRONTEND="noninteractive" apt update --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt -y install php7.2
RUN DEBIAN_FRONTEND="noninteractive" apt -y install php7.2-fpm php7.2-common php7.2-cli php7.2-mysqlnd php7.2-curl php7.2-bcmath php7.2-mbstring php7.2-soap php7.2-xml php7.2-zip php7.2-json php7.2-imap php-xdebug php-pgsql php7.2-calendar php7.2-ctype php7.2-curl php7.2-dom php7.2-exif php7.2-fileinfo php7.2-ftp php7.2-gd php7.2-gettext php7.2-iconv php7.2-imagick php7.2-imap php7.2-intl php7.2-json php7.2-mbstring php7.2-mysqli php7.2-mysqlnd php7.2-OAuth php7.2-PDO php7.2-pgsql php7.2-Phar php7.2-posix php7.2-readline php7.2-shmop php7.2-SimpleXML php7.2-sockets php7.2-sysvmsg php7.2-sysvsem php7.2-sysvshm php7.2-tokenizer php7.2-wddx php7.2-xml php7.2-xmlreader php7.2-xmlwriter php7.2-xsl php7.2-zip

# install nginx (full)
RUN DEBIAN_FRONTEND="noninteractive" apt install -y nginx-full

# install latest version of git
RUN DEBIAN_FRONTEND="noninteractive" apt install -y git

# install latest version of nano
RUN DEBIAN_FRONTEND="noninteractive" apt install -y nano

# Install ACL (getfacl | setfacl)
RUN DEBIAN_FRONTEND="noninteractive" apt install -y acl

# Install zip & unzip
RUN DEBIAN_FRONTEND="noninteractive" apt install -y zip unzip

# install php composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# install nodejs
RUN DEBIAN_FRONTEND="noninteractive" apt update && apt -y install curl python-software-properties
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN DEBIAN_FRONTEND="noninteractive" apt -y install nodejs

# add build script (also set timezone to UTC)
RUN mkdir -p /root/setup
ADD build/setup.sh /root/setup/setup.sh
RUN chmod +x /root/setup/setup.sh
RUN (cd /root/setup/; /root/setup/setup.sh)

# copy files from repo
ADD build/nginx.ngx-conf /etc/nginx/sites-available/default
ADD build/.bashrc /root/.bashrc

# disable services start
RUN update-rc.d -f apache2 remove
RUN update-rc.d -f nginx remove
RUN update-rc.d -f php7.2-fpm remove

# add startup scripts for nginx
ADD build/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# add startup scripts for php7.2-fpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/phpfpm/run

# set WWW public folder
RUN mkdir -p /var/www/public
ADD build/index.php /var/www/public/index.php

RUN chown root:www-data /var/www
RUN chown -R www-data:www-data /var/www/*
RUN chmod -R g+rwX /var/www

ADD build/create_sftp_user.sh /usr/local/bin/create_sftp_user
RUN chmod +x /usr/local/bin/create_sftp_user

ADD build/fix_www_permissions.sh /usr/local/bin/fix_www_permissions
RUN chmod +x /usr/local/bin/fix_www_permissions
RUN /usr/local/bin/fix_www_permissions

ADD build/sshd_config /etc/ssh/sshd_config

# set terminal environment
ENV TERM xterm

# cleanup apt and lists
RUN apt clean
RUN apt autoclean

# port and settings
EXPOSE 22
EXPOSE 80

CMD ["/sbin/my_init"]
