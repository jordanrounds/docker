#!/bin/bash

echo
echo "MariaDB Container Init"
echo
echo "Creating link to MariaDB data"
echo
ln -sf ${LOCAL_PERSIST}/mariadb persist-data

if ! [[ -f .env ]]
then
echo "Creating .env file"
touch .env
echo "MYSQL_DATABASE=hass" >> .env
echo "MYSQL_USER=hass" >> .env
echo "The database name has been set to hass and the username has been set to hass"
else
echo ".env file already exists, skipping creation"
fi

echo
echo "Creating secret files"
echo

if ! [[ -f $SECRETS/mariadb.password.root ]]
then
touch $SECRETS/mariadb.password.root
read -sp 'root user password: ' password
echo $password >> $SECRETS/mariadb.password.root
echo "Added $SECRETS/mariadb.password.root and populated with the password"
else
echo "$SECRETS/mariadb.password.root already exists, skipping creation"
fi

if ! [[ -f $SECRETS/mariadb.password.hass ]]
then
touch $SECRETS/mariadb.password.hass
read -sp 'hass user password: ' password
echo $password >> $SECRETS/mariadb.password.hass
echo "Added $SECRETS/mariadb.password.hass and populated with the password"
else
echo "$SECRETS/mariadb.password.hass already exists, skipping creation"
fi