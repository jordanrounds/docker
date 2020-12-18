#!/bin/bash

#file_env function from: https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh

set -e

error() {
  printf '%s [%s] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "ERROR" "$*"
}

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		error "Both $var and $fileVar are set (but are exclusive)"
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

file_env "MOSQUITTO_USERNAME"
file_env 'MOSQUITTO_PASSWORD'

if ( [ -z "${MOSQUITTO_USERNAME}" ] || [ -z "${MOSQUITTO_PASSWORD}" ] ); then
  echo "MOSQUITTO_USERNAME or MOSQUITTO_PASSWORD not defined"
  exit 1
fi

# create mosquitto passwordfile
touch /mosquitto/config/mosquitto.passwd
mosquitto_passwd -b /mosquitto/config/mosquitto.passwd $MOSQUITTO_USERNAME $MOSQUITTO_PASSWORD

. /docker-entrypoint.sh