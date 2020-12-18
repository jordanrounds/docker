#!/bin/bash

echo
echo "Plex Container Init"
echo
echo "Creating link to Plex data"
echo
ln -sf $LOCAL_PERSIST/plex persist-data

if ! [[ -f .env ]]
then
echo "Creating .env file"
touch .env
read -p 'path to media: ' media_path
echo "MEDIA=$media_path" >> .env
echo "MEDIA=$media_path added to .env"
else
echo ".env file already exists, skipping creation"
fi
