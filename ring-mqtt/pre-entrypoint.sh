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

file_env 'MQTTPASSWORD'
file_env 'RINGTOKEN'

if ( [ -z "${MQTTPASSWORD}" ] || [ -z "${RINGTOKEN}" ] ); then
  echo "MQTTPASSWORD or RINGTOKEN not defined"
  exit 1
fi

node /ring-mqtt/ring-mqtt.js
