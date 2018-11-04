#!/usr/bin/env bash
set -e

if false ; then
	NAMED_DB_FILE=
	NAMED_SERVICE_CONTROL=
	RECORD_NAME=
	RECORD_TYPE=
	CONTENT_FROM=
	RECORD_VALUE=
fi

function execute() {
	declare -p NAMED_DB_FILE NAMED_SERVICE_CONTROL
	local F="${NAMED_DB_FILE}"
	if [ ! -e "${F}" ]; then
		die "Error: no database file: ${F}"
	fi
	
	local DNS_RECORD_DATA="${RECORD_NAME} IN ${RECORD_TYPE} ${RECORD_VALUE}"
	local REG="/^${RECORD_NAME//./\\.}/d"
	cat << REMOTE_SCRIPT
	set -x
	set -e
	touch '${F}'
	sed -i '${REG}' '${F}'
	echo -n '${DNS_RECORD_DATA}' >> ${F}
	
	if ! ${NAMED_SERVICE_CONTROL} ; then
		sed -i '${REG}' '${F}'
		${NAMED_SERVICE_CONTROL}
		exit 1
	fi
	sleep 5
REMOTE_SCRIPT
}
