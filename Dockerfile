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
RUN DEBIAN_FRONTEND="noninteractive" apt -y install php7.3
RUN DEBIAN_FRONTEND="noninteractive" apt -y install php7.3-fpm php7.3-common php7.3-cli php7.3-mysqlnd php7.3-curl php7.3-bcmath php7.3-mbstring php7.3-soap php7.3-xml php7.3-zip php7.3-json php7.3-imap php-xdebug php-pgsql php7.3-calendar php7.3-ctype php7.3-curl php7.3-dom php7.3-exif php7.3-fileinfo php7.3-ftp php7.3-gd php7.3-gettext php7.3-iconv php7.3-imagick php7.3-imap php7.3-intl php7.3-json php7.3-mbstring php7.3-mysqli php7.3-mysqlnd php7.3-OAuth php7.3-PDO php7.3-pgsql php7.3-Phar php7.3-posix php7.3-readline php7.3-shmop php7.3-SimpleXML php7.3-sockets php7.3-sysvmsg php7.3-sysvsem php7.3-sysvshm php7.3-tokenizer php7.3-wddx php7.3-xml php7.3-xmlreader php7.3-xmlwriter php7.3-xsl php7.3-zip

# install nginx (full)
RUN DEBIAN_FRONTEND="noninteractive" apt install -y nginx-full

# install latest version of git
RUN DEBIAN_FRONTEND="noninteractive" apt install -y git

# install latest version of nano
RUN DEBIAN_FRONTEND="noninteractive" apt install -y nano

# install php composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# add build script (also set timezone to UTC)
RUN mkdir -p /root/setup
ADD build/setup.sh /root/setup/setup.sh
RUN chmod +x /root/setup/setup.sh
RUN (cd /root/setup/; /root/setup/setup.sh)

# copy files from repo
ADD build/nginx.conf /etc/nginx/sites-available/default
ADD build/.bashrc /root/.bashrc

# disable services start
RUN update-rc.d -f apache2 remove
RUN update-rc.d -f nginx remove
RUN update-rc.d -f php7.3-fpm remove

# add startup scripts for nginx
ADD build/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# add startup scripts for php7.3-fpm
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

ADD build/fix_www.sh /usr/local/bin/fix_www
RUN chmod +x /usr/local/bin/fix_www

# set terminal environment
ENV TERM=xterm

# cleanup apt and lists
RUN apt clean
RUN apt autoclean

# port and settings
EXPOSE 22
EXPOSE 80

