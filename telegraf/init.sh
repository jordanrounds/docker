#!/bin/bash
source ../functions.sh

init "Telegraf"

# Check if InfluxDB token exists, prompt if not
if [ ! -f "${SECRETS}/telegraf.token.influx" ]; then
  echo ""
  echo "Telegraf needs an InfluxDB2 token with write access to the 'docker' bucket."
  echo ""
  echo "You can either:"
  echo "  1. Create a new token in InfluxDB2 UI (influxdb.in.rounds.house)"
  echo "  2. Use the existing admin token: ln -s influxdb2.token ${SECRETS}/telegraf.token.influx"
  echo ""
  create_secret_file "$SECRETS" "telegraf.token.influx" "Enter InfluxDB2 token for Telegraf:"
fi

# Write the token to .env file for docker-compose
if [ -f "${SECRETS}/telegraf.token.influx" ]; then
  INFLUX_TOKEN=$(cat "${SECRETS}/telegraf.token.influx")
  write_env "INFLUX_TOKEN" "$INFLUX_TOKEN"
else
  echo "Warning: No InfluxDB token found. Please create ${SECRETS}/telegraf.token.influx"
fi

echo ""
echo "Note: You may need to create the 'docker' bucket in InfluxDB2 if it doesn't exist."
echo "      Go to: influxdb.in.rounds.house -> Load Data -> Buckets -> Create Bucket"
echo ""

start_container "Telegraf"
cleanup_old_images
