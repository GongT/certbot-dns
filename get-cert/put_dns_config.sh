#!/usr/bin/env bash

cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source base.sh

if false ; then # fix some highlight
	NAMED_DB_FILE=
	NAMED_SERVICE_CONTROL=
	DNSMASQ_DIR=
	DNSMASQ_SERVICE_CONTROL=
	PDNS_SERVICE_CONTROL=
	DNS_REMOTE_TYPE=
	DNS_REMOTE=
	DNS_REMOTE_KEYFILE=
fi

set -e

TMP_SCRIPT_FILE="/tmp/dns-remote-run.${RANDOM}.sh"
trap "
RET=\$?
set +e
trap - EXIT
if [ \$RET -eq 0 ]; then
	unlink '$TMP_SCRIPT_FILE'
	rm -f /tmp/put-dns-status-error
	exit 0
else
	echo 'Failed script: $TMP_SCRIPT_FILE'
	touch /tmp/put-dns-status-error
	exit 1
fi
" EXIT

export RECORD_NAME="$1"
if [ -z "${RECORD_NAME}" ] ; then
	die "Error: no sub domain name"
fi
export RECORD_TYPE="$2"
if [ -z "${RECORD_TYPE}" ] ; then
	die "Error: no record type"
fi
export RECORD_VALUE="$3"
export RECORD_TTL="${4-86400}"

TYPE=
if [ -n "$NAMED_SERVICE_CONTROL" ]; then
	TYPE="named"
elif [ -n "$DNSMASQ_SERVICE_CONTROL" ]; then
	TYPE="dnsmasq"
elif [ -n "$PDNS_SERVICE_CONTROL" ]; then
	TYPE="pdns"
else
	die "Config fail, no service type detected. you must use named or pdns or dnsmasq."
fi

echo "Put DNS record:
	Service: ${TYPE}
	Type: $RECORD_TYPE
	Record: $RECORD_NAME
	Value: $RECORD_VALUE
	TTL: $RECORD_TTL
"

(
	echoo '#!/bin/bash'
	echoo 'set -e'
	declare -p RECORD_NAME RECORD_TYPE RECORD_VALUE
	source "$ROOT/get-cert/providers/${TYPE}.sh"
	execute
) > "${TMP_SCRIPT_FILE}"

if [ -z "$DNS_REMOTE" ]; then
	sudo bash "${TMP_SCRIPT_FILE}" || die "not able to apply dns config"
else
	if [ "$DNS_REMOTE_TYPE" = "ssh" ] || [ -z "$DNS_REMOTE_TYPE" ]; then
		ARGS=("${DNS_REMOTE}")
		if [ -n "${DNS_REMOTE_KEYFILE}" ]; then
			ARGS+=(-i "${DNS_REMOTE_KEYFILE}")
		fi
		expect auto_ssh.expect "${ARGS[@]}" sudo bash -c "$(<"${TMP_SCRIPT_FILE}")" || die "not able to apply dns config"
	elif [ "$DNS_REMOTE_TYPE" = "ns" ]; then
		systemd-run -q -M "$DNS_REMOTE" --wait -P -G /bin/bash -c "cat > '${TMP_SCRIPT_FILE}' " <"${TMP_SCRIPT_FILE}" || die "not able to apply dns config"
		systemd-run -q -M "$DNS_REMOTE" --wait -P -G /bin/bash "${TMP_SCRIPT_FILE}" || die "not able to apply dns config"
	else
		die "Unknown remote type: $DNS_REMOTE_TYPE"
	fi
fi
