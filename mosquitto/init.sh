#!/bin/bash

echo
echo "Mosquitto Container Init"
echo
echo "Creating link to Mosquitto data"
echo
ln -sf $LOCAL_PERSIST/mosquitto persist-data

if ! [[ -f .env ]]
then
echo "Creating .env file"
touch .env
echo "MOSQUITTO_USERNAME=mos" >> .env
echo "MOSQUITTO_USERNAME=mos added to .env"
else
echo ".env file already exists, skipping creation"
fi

echo
echo "Creating empty secret files"
echo

if ! [[ -f $SECRETS/mosquitto.password.mos ]]
then
touch $SECRETS/mosquitto.password.mos
read -sp 'mos user password: ' password
echo $password >> $SECRETS/mosquitto.password.mos
echo "Added $SECRETS/mosquitto.password.mos and populated with the password"
else
echo "$SECRETS/mosquitto.password.mos already exists, skipping creation"
fi