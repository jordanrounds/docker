#!/bin/bash

set -e

log() {
  printf '%s [%s] [Entrypoint]: %s\n' "$(date -R)" "$1" "$2"
}

error() {
  log "ERROR" "$*"
  exit 1
}

# if [ "${OVERWRITE_CONFIG}" = "true" ]; then
#   log "OVERWRITE_CONFIG is set to true. Overwriting config..."
#   cp /mosquitto/tmp/mosquitto.conf /mosquitto/config/mosquitto.conf
# fi

# Function to handle _FILE environment variables
get_env_or_file() {
  local var="$1"
  local fileVar="${var}_FILE"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    error "Both $var and $fileVar are set (but are exclusive)"
  elif [ "${!fileVar:-}" ]; then
    export "$var"="$(< "${!fileVar}")"
  fi
}

# Load username and password from environment variables or files
get_env_or_file "MOSQUITTO_USERNAME"
get_env_or_file "MOSQUITTO_PASSWORD"

# Set default username if not provided
MOSQUITTO_USERNAME=${MOSQUITTO_USERNAME:-"mos"}

# Create password file if password is provided, else allow anonymous for the user
if [ -n "$MOSQUITTO_PASSWORD" ]; then
  touch /mosquitto/data/mosquitto.passwd
  mosquitto_passwd -b /mosquitto/data/mosquitto.passwd "$MOSQUITTO_USERNAME" "$MOSQUITTO_PASSWORD"
  log "INFO" "Password set for user $MOSQUITTO_USERNAME"
else
  # If no password is set, allow anonymous access for the user
  sed -i '/password_file/d' /mosquitto/config/mosquitto.conf
  log "INFO" "No password set for user $MOSQUITTO_USERNAME, allowing anonymous access"
fi

log "INFO" "Starting mosquitto with provided configuration..."

# Execute the original Docker entrypoint script
. /docker-entrypoint.sh