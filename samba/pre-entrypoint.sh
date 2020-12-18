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

file_env 'USER'
file_env 'SHARE'
file_env 'CHARMAP'
file_env 'GLOBAL'
file_env 'IMPORT'
file_env 'NMBD'
file_env 'PERMISSIONS'
file_env 'RECYCLE'
file_env 'SHARE'
file_env 'SMB'
file_env 'TZ'
file_env 'WIDELINKS'
file_env 'WORKGROUP'
file_env 'USERID'
file_env 'INCLUDE'
file_env 'TINI_SUBREAPER'

/sbin/tini -- /usr/bin/samba.sh
