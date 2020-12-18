#!/bin/bash

echo
echo "Ring MQTT Container Init"
echo
echo "Creating link to Ring MQTT data"
ln -sf $LOCAL_PERSIST/ring-mqtt persist-data
echo

if ! [[ -f .env ]]
then
echo "Creating .env file"
touch .env
read -p 'MQTT host address: ' host_address
echo "MQTTHOST=$host_address" >> .env
echo "MQTTHOST=$host_address added to .env"
read -p 'MQTT username: ' username
echo "MQTTUSER=$username" >> .env
echo "MQTTUSER=$username added to .env"
else
echo ".env file already exists, skipping creation"
fi

echo
echo "Creating secret files"
echo

if ! [[ -f $SECRETS/mosquitto.password.ring ]]
then
touch $SECRETS/mosquitto.password.ring
read -sp 'mqtt user password: ' password
echo $password >> $SECRETS/mosquitto.password.ring
echo "Added $SECRETS/mosquitto.password.ring and populated with the password"
else
echo "$SECRETS/mosquitto.password.ring already exists, skipping creation"
fi

if ! [[ -f $SECRETS/ring-mqtt.token ]]
then
touch $SECRETS/ring-mqtt.token
read -p 'ring refresh token: ' token
echo $token >> $SECRETS/ring-mqtt.token
echo "Added $SECRETS/ring-mqtt.token and populated with $token"
else
echo "$SECRETS/ring-mqtt.token already exists, skipping creation"
fi