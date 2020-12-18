#!/bin/bash

echo
echo "Starting DNSimple Dynamic DNS Container"
docker-compose up --force-recreate --build -d
echo 
echo "Cleaning up old images"
docker image prune -f