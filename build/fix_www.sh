#!/usr/bin/env bash

set -e

chown root:www-data /var/www
chown -R www-data:www-data /var/www/*
chmod -R g+rwX /var/www

echo "Completed!"
