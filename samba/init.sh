#!/bin/bash

echo
echo "Samba Container Init"
echo
echo "Creating link to Samba data"
ln -sf $LOCAL_PERSIST/samba persist-data
echo
echo 'Creating user and setting password for Samba'
read -p 'Username: ' username
read -sp 'Password: ' password
echo

if ! [[ -f .env ]]
then
echo "Creating .env file"
echo
touch .env
echo "NMBD=true" >> .env
echo "NMBD=true added to .env"
echo "USERID=0" >> .env
echo "USERID=0 added to .env"
echo "GROUPID=0" >> .env
echo "GROUPID=0 added to .env"
echo "WORKGROUP=WORKGROUP" >> .env
echo "WORKGROUP=WORKGROUP added to .env"
echo "SHARE=Docker;/home/shares/docker;yes;no;no;$username;$username;$username;" >> .env
echo "SHARE=Docker;/home/shares/docker;yes;no;no;$username;$username;$username; added to .env"
else
echo ".env file already exists, skipping creation"
fi

echo
echo "Creating secret files"
echo

if ! [[ -f $SECRETS/samba.user ]]
then
touch $SECRETS/samba.user
echo "$username;$password" >> $SECRETS/samba.user
echo "Added $SECRETS/samba.user and populated with the password"
else
echo "$SECRETS/samba.user already exists, skipping creation"
fi