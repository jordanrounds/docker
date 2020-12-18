#!/bin/bash

echo
echo "Flexget Container Init"
echo
echo "Creating link to Flexget data"
ln -sf $LOCAL_PERSIST/flexget persist-data
echo

if ! [[ -f .env ]]
then
echo "Creating .env file"
touch .env
read -p 'Path to store downloads: ' download_path
echo "DOWNLOAD=$download_path" >> .env
else
echo ".env file already exists, skipping creation"
fi