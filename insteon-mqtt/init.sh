#!/bin/bash

echo
echo "Insteon MQTT Container Init"
echo
echo "Creating link to Insteon MQTT data"
echo
ln -sf ${LOCAL_PERSIST}/insteon-mqtt persist-data

if ! [[ -f .env ]]
then
echo "Creating .env file"
echo
touch .env
read -p 'Path to PLM /dev/serial/... : ' device_path
echo "DEVICE=$device_path" >> .file_env
else
echo ".env file already exists, skipping creation"
fi