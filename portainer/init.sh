#!/bin/bash

source '../functions.sh'

APP="Portainer"
FOLDER="portainer"
PERSIST="${LOCAL_PERSIST}/${FOLDER}"

create_directory $PERSIST

echo
echo "${APP} Container Init"
echo
echo "Creating link to ${APP} data"
echo $LOCAL_PERSIST/${FOLDER}
echo "${LOCAL_PERSIST}/${FOLDER}"

if ! ln -sf "${LOCAL_PERSIST}/${FOLDER}" persist-data; then
  echo "Failed to create link"
  exit 1
fi
echo

