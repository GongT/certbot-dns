#!/usr/bin/env bash

set -e

trap "echo GOT HUP" SIGHUP
trap "
if [ \$? -eq 0 ]; then
	rm -f /tmp/put-dns-status-error
else
	touch /tmp/put-dns-status-error
fi
" EXIT

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/base.sh"

export SUB_DOMAIN="$1"
if [ -z "${SUB_DOMAIN}" ] ; then
	die "Error: no sub domain name"
fi
export RECORD_TYPE="$2"
if [ -z "${RECORD_TYPE}" ] ; then
	die "Error: no record type"
fi
export CONTENT_FROM="$3"
if [ -n "${CONTENT_FROM}" ] && ! [ -e "${CONTENT_FROM}" ]; then
	die "Error: no source file: ${CONTENT_FROM}"
fi

if false ; then
	NAMED_DB_FILE=
	NAMED_SERVICE_CONTROL=
	DNS_REMOTE=
	DNS_REMOTE_KEYFILE=
fi

# .${RANDOM}
TMP=/tmp/certbot-dns-remote-run.sh

function export_var() {
	for i ; do
		echo "$i=${!i}" 
	done
}

export FULL_CHALLENGE="_acme-challenge.${SUB_DOMAIN}"

export_var NAMED_DB_FILE SUB_DOMAIN FULL_CHALLENGE RECORD_TYPE > "${TMP}"
cat >> "${TMP}" << 'InputComesFromHERE'
set -e

F="${NAMED_DB_FILE}"
function die() {
	if [ -n "$*" ]; then
		echo "\e[38;5;9m""$@""\e[0m" >&2
	fi
	exit 1
}
if [ ! -e "${F}" ]; then
	die "Error: no database file: ${F}"
fi
sed -i "/^${FULL_CHALLENGE//./\\.}/d" "${F}"
echo -n "${FULL_CHALLENGE} IN ${RECORD_TYPE} " > /tmp/get-cert-challenge.txt
cat >> "/tmp/get-cert-challenge.txt"

cat /tmp/get-cert-challenge.txt | tee -a ${F}

if [ "$(id -u)" -ne 0 ]; then
	export sudo="sudo"
fi
$sudo ${NAMED_SERVICE_CONTROL} || {
	// cat "${F}"
	sed -i "/^${FULL_CHALLENGE//./\\.}/d" "${F}"
	$sudo ${NAMED_SERVICE_CONTROL}
	exit 1
}
sleep 5
exit 0
InputComesFromHERE

function stdin() {
	if [ -z "${CONTENT_FROM}" ]; then
		cat
	else
		cat "${CONTENT_FROM}"
	fi
}

if [ -z "$DNS_REMOTE" ]; then
	stdin | bash ${TMP} || die "not able to apply dns config"
else
	ARGS=("${DNS_REMOTE}")
	if [ -n "${DNS_REMOTE_KEYFILE}" ]; then
		ARGS+=(-i "${DNS_REMOTE_KEYFILE}")
	fi
	stdin | expect auto_ssh.expect "${ARGS[@]}" bash -c "$(<"${TMP}")" || die "not able to apply dns config"
fi
