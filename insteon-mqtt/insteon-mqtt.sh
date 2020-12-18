#!/bin/bash
INSTANCE_NAME='insteon-mqtt'
CONFIG_FILE='/config/insteon_mqtt.yaml'
LINE='-------------------------------------'

echo 'Insteon MQTT Management'
echo
echo 'What would you like to do?'
echo $LINE
echo '1) Join Device'
echo '2) Pair Device'
echo '3) Refresh All Devices'
echo '4) Refresh Device'
echo $LINE

read -p 'Choose option: '
echo

if [ ${REPLY} -eq 1 ]; then
  echo "Joining Device"
  echo $LINE
  read -p 'Device Address (aa.bb.cc): ' address
  echo
  echo "Joining Device: $address"
  docker exec -d $INSTANCE_NAME insteon-mqtt $CONFIG_FILE join $address
  #docker exec -d $INSTANCE_NAME kill -HUP 1
elif [ ${REPLY} -eq 2 ]; then
  echo "Pairing Device"
  echo $LINE
  read -p 'Device Address (aa.bb.cc): ' address
  docker exec -d $INSTANCE_NAME insteon-mqtt $CONFIG_FILE pair $address
  #docker exec -d $INSTANCE_NAME kill -HUP 1
elif [ ${REPLY} -eq 3 ]; then
  echo "Refresh All Devices"
  echo $LINE
  docker exec -d $INSTANCE_NAME insteon-mqtt $CONFIG_FILE refresh-all
elif [ ${REPLY} -eq 4 ]; then
  echo "Refresh Device"
  echo $LINE
  read -p 'Device Address (aa.bb.cc): ' address
  echo
  echo "Refreshing Device: $address"
  docker exec -d $INSTANCE_NAME insteon-mqtt $CONFIG_FILE refresh $address
else
  echo "Please enter a valid option."
fi
exit 1
