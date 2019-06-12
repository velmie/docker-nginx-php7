#!/usr/bin/env bash

set -e

WWW_PATH=/var/www

chown root:www-data $WWW_PATH

shopt -s nullglob dotglob     # To include hidden files
files=("${WWW_PATH}"/*)

if [ ${#files[@]} -gt 0 ]; then
    chgrp -R www-data "${WWW_PATH}"/*
fi

chmod -R g+rwx $WWW_PATH
setfacl -R -d -m  g::rwx $WWW_PATH

echo "Completed!"
