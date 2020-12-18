#!/bin/bash

echo
echo "NGINX Container Init"
echo
echo "Creating link to NGINX data"
echo
ln -sf $LOCAL_PERSIST/nginx persist-data

if ! [[ -f .env ]]
then
echo "Creating .env file"
touch .env
echo "SUBDOMAINS=wildcard" >> .env
echo "SUBDOMAINS=wildcard added to .env"
echo "VALIDATION=dns" >> .env
echo "VALIDATION=dns added to .env"
echo "DNSPLUGIN=dnsimple" >> .env
echo "DNSPLUGIN=dnsimple added to .env"
else
echo ".env file already exists, skipping creation"
fi

echo
echo "Creating empty secret files"
echo

if ! [[ -f $SECRETS/nginx.url ]]
then
touch $SECRETS/nginx.url
read -p 'url: ' url
echo $url >> $SECRETS/nginx.url
echo "Added $SECRETS/nginx.url and populated with $url"
else
echo "$SECRETS/nginx.url already exists, skipping creation"
fi

if ! [[ -f $SECRETS/nginx.email ]]
then
touch $SECRETS/nginx.email
read -p 'email: ' email
echo $email >> $SECRETS/nginx.email
echo "Added $SECRETS/nginx.email and populated with $email"
else
echo "$SECRETS/nginx.email already exists, skipping creation"
fi