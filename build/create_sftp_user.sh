#!/usr/bin/env bash

function usage_error () {
    echo "Usage: $0 [-u USER] [-p PASSWORD]" 1>&2;
    exit 1
}

if [ $# -lt 4 ];
then
    usage_error
fi

while getopts "u:p:" opt; do
  case ${opt} in
    u )
      USER=$OPTARG
      ;;
    p )
      PASSWORD=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))


USER_HOME="/home/$USER"
WEB_GROUP=www-data

# Exit on any failure
set -e

echo "Creating a user: $USER"

useradd $USER -m -d $USER_HOME -s /bin/bash

#sleep 1

echo "$USER:$PASSWORD"|chpasswd

echo "The user: $USER is successfully created!"

#sleep 1

echo "Attaching the user: $USER to the group: $WEB_GROUP"

usermod -a -G $WEB_GROUP $USER

#sleep 1

echo "Creating a symlink to the web folder."

ln -s /var/www "$USER_HOME/www"

echo "Completed!"
