#!/bin/bash

source '../functions.sh'

APP="Jackett"
FOLDER="jackett"
PERSIST="${LOCAL_PERSIST}/${FOLDER}"
CONFIG="${PERSIST}/config"
DOWNLOADS="${PERSIST}/downloads"

create_directory $PERSIST
create_directory $CONFIG
create_directory $DOWNLOADS

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

if [[ ! -f .env ]]; then
  echo "Creating .env file"
  touch .env
  read -p 'Path to downloads: ' download_path
  echo "DOWNLOAD=$download_path" >> .env
else
  echo ".env file already exists, skipping creation"
  # Optionally check if DOWNLOAD variable is set
  if grep -q 'DOWNLOAD=' .env; then
    echo "DOWNLOAD variable is set."
  else
    echo "DOWNLOAD variable is not set. Consider adding it."
  fi
fi

