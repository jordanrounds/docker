#!/bin/bash

ENVIRONMENT="/etc/environment"
DOCKER_ROOT="/home/jordan/Docker"
LOCAL_PERSIST="$DOCKER_ROOT/.local-persist"
SECRETS="$DOCKER_ROOT/.secrets"
TIMEZONE="America/Los_Angeles"

echo 'Docker Initialization'
echo
echo 'This script will setup and configure your environment for the docker containers in this repo.'
echo 'Would you like to continue?'
read -p 'y/n: '

if [ ${REPLY} = 'n' ]
then
  echo 'Aborting'
  exit 1
fi

echo "Adding $DOCKER_ROOT"
echo
mkdir -p $DOCKER_ROOT

echo "Adding $LOCAL_PERSIST"
echo
mkdir -p $LOCAL_PERSIST

echo "Adding $SECRETS"
echo
mkdir -p $SECRETS

echo "Would you like to add the environment variables to $ENVIRONMENT?"
read -p 'y/n: '

if [ ${REPLY} = 'y' ]
then
  echo "LOCAL_PERSIST=\"$LOCAL_PERSIST\"" >> $ENVIRONMENT
  echo "SECRETS=\"$SECRETS\"" >> $ENVIRONMENT
  echo "TZ=\"$TIMEZONE\"" >> $ENVIRONMENT
fi

#Docker Group Setup
echo
echo 'Would you like to add the group docker and add it to your user?'
read -p 'y/n: '

if [ ${REPLY} = 'y' ]
then
  groupadd docker
  usermod -aG docker $USER
fi

#Docker Start on Boot
echo
echo 'Would you like to enable Docker to start on boot?'
read -p 'y/n: '

if [ ${REPLY} = 'y' ]
then
  systemctl enable docker
fi

#Docker Plugin - Local Persist
#https://github.com/MatchbookLab/local-persist
echo
echo 'Would you like to install the Local Persist Docker plugin?'
read -p 'y/n: '

if [ ${REPLY} = 'y' ]
then
  curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
fi

echo
echo "Docker Initialization Complete"
#Optionally add $DOCKER to .profile to make it easier to get to
#ie: cd $DOCKER
#DOCKER=/home/docker

exit 1
