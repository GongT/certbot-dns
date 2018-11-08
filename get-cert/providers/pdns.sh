#!/usr/bin/env bash

set -e

if false ; then
	PDNS_SERVICE_CONTROL=
	BASE_DOMAIN=
	RECORD_NAME=
	RECORD_TTL=
	RECORD_TYPE=
	RECORD_VALUE=
	PDNS_UTIL=
fi

function execute() {
	local RECORD_CONTENT="${RECORD_NAME}.${BASE_DOMAIN} ${RECORD_TTL} IN ${RECORD_TYPE} \"${RECORD_VALUE}\""
	declare -p PDNS_UTIL
	declare -p RECORD_CONTENT
	declare -p RECORD_NAME
	declare -p BASE_DOMAIN
	declare -p RECORD_TYPE
	declare -p PDNS_SERVICE_CONTROL
	declare -pf die
	declare -pf program_content
	echoo ""
	echoo "# run"
	echoo "program_content"
}

function program_content() {
	function P() {
		"$PDNS_UTIL" "$@" 2>/dev/null
	}
	function PR() {
		(set -x ; "$PDNS_UTIL" "$@" 2>/dev/null) || (set -x ; "$PDNS_UTIL" "$@") || die "Failed to $1"
	}
	if ! P list-zone "${BASE_DOMAIN}" >/dev/null ; then
		echo "creating zone: "
		PR create-zone "${BASE_DOMAIN}"
		echo "creating zone: Ok"
	fi
	
	if P list-zone "${BASE_DOMAIN}" | grep -qE "^${RECORD_NAME}\.${BASE_DOMAIN}" ; then
		echo "deleting record: "
		export EDITOR="sed -i -e '/^${RECORD_NAME}\.${BASE_DOMAIN}/d'"
		yes a | PR edit-zone "${BASE_DOMAIN}" || die "Failed to delete original record."
		echo "deleting record: Ok"
	fi
	echo "creating record: ${RECORD_CONTENT}"
	echo '#!/bin/bash
echo "" >> "$1"
echo "${RECORD_CONTENT}" >> "$1"
' > /tmp/editor
	chmod a+x /tmp/editor
	export EDITOR="/tmp/editor"
	yes a | PR edit-zone "${BASE_DOMAIN}" || die "Failed to create ${RECORD_TYPE}<${RECORD_NAME}> record."
	echo "creating record: Ok"
	
	echo "reloading service: "
	PR increase-serial "${BASE_DOMAIN}" || die "Failed to increase-serial"
	"$PDNS_SERVICE_CONTROL" notify "${BASE_DOMAIN}" || systemctl restart pdns || die "Failed to notify pdns service"
	echo "reloading service: Ok"
}
