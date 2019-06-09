#!/usr/bin/env bash

set -e

chown root:www-data /var/www
chgrp -R www-data /var/www/*
chmod -R g+rwx /var/www
setfacl -R -d -m  g::rwx /var/www

echo "Completed!"
