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
	local P="$PDNS_UTIL"
	cat << REMOTE_SCRIPT
	function P() {
		$P "\$@" 2>/dev/null
	}
	function PR() {
		$P "\$@" 2>/dev/null || $P "\$@" || die "Failed to \$1"
	}
	$(declare -f -p die)
	if ! P list-zone '${BASE_DOMAIN}' >/dev/null ; then
		echo "creating zone: "
		PR create-zone '${BASE_DOMAIN}'
		echo "creating zone: Ok"
	fi
	
	if P list-zone service.gongt.me | grep -qE '^${RECORD_NAME}\\.${BASE_DOMAIN}' ; then
		echo "deleting record: "
		export EDITOR="sed -i -e '/^${RECORD_NAME}\\.${BASE_DOMAIN}/d'"
		yes a | PR edit-zone '${BASE_DOMAIN}' || die "Failed to delete original record."
		echo "deleting record: Ok"
	fi
	echo "creating record: "
	PR add-record '${BASE_DOMAIN}' '${RECORD_NAME}' '${RECORD_TYPE}' '${RECORD_TTL}' '${RECORD_VALUE}' || die "Failed to create ${RECORD_TYPE} Record."
	echo "creating record: Ok"
	
	echo "reloading service: "
	PR increase-serial '${BASE_DOMAIN}' || die "Failed to increase-serial"
	'$PDNS_SERVICE_CONTROL' notify '${BASE_DOMAIN}' || systemctl restart pdns || die "Failed to notify pdns service"
	echo "reloading service: Ok"
REMOTE_SCRIPT
}
