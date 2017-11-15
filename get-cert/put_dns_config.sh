#!/usr/bin/env bash

set -e

trap "echo GOT HUP" SIGHUP

source base.sh

export FILE_NAME="$1"
if [ -z "${FILE_NAME}" ]; then
	die "Error: no file name"
fi
export CONTENT_FROM="$2"
if [ -n "${CONTENT_FROM}" ] && ! [ -e "${CONTENT_FROM}" ]; then
        die "Error: no source file: ${CONTENT_FROM}"
fi

if false ; then
	DNSMASQ_CONFIG_DIR=
	DNSMASQ_SERVICE_CONTROL=
	DNS_REMOTE=
	DNS_REMOTE_KEYFILE=
fi

DNSMASQ_CONFIG_DIR="${DNSMASQ_CONFIG_DIR%/}"

# .${RANDOM}
TMP=/tmp/certbot-dns-remote-run.sh

function export_var() {
	for i ; do
		echo "$i=${!i}" 
	done
}


# export_var DNSMASQ_CONFIG_DIR FILE_NAME DNSMASQ_SERVICE_CONTROL > ${TMP}
cat > ${TMP} << 'InputComesFromHERE'
set -e
F="${DNSMASQ_CONFIG_DIR}/${FILE_NAME}.conf"
mkdir -p "${DNSMASQ_CONFIG_DIR}"
echo "# GENERATED FILE DO NOT MODIFY" > "${F}"
tee >> "${F}"
if [ "$(id -u)" -ne 0 ]; then
	export sudo="sudo"
fi
$sudo ${DNSMASQ_SERVICE_CONTROL} || {
	rm -f "${F}"
	$sudo ${DNSMASQ_SERVICE_CONTROL}
	exit 1
}
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
	stdin | tee /dev/stderr | bash ${TMP} || die "not able to apply dns config"
else
	ARGS=("${DNS_REMOTE}")
	if [ -n "${DNS_REMOTE_KEYFILE}" ]; then
		ARGS+=(-i "${DNS_REMOTE_KEYFILE}")
	fi
	stdin | tee /dev/stderr | expect auto_ssh.expect "${ARGS[@]}" bash -c "$(<"${TMP}")" || die "not able to apply dns config"
fi

