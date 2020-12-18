#!/bin/bash

echo
echo "Starting MariaDB Container"
docker-compose up --force-recreate --build -d
echo 
echo "Cleaning up old images"
docker image prune -f
