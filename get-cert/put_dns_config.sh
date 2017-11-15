#!/usr/bin/env bash

set -e

source base.sh

export FILE_NAME="$1"
if [ -z "${FILE_NAME}" ]; then
	die "Error: no file name"
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
set -x
F="${DNSMASQ_CONFIG_DIR}/${FILE_NAME}.conf"
mkdir -p "${DNSMASQ_CONFIG_DIR}"
echo "# GENERATED FILE DO NOT MODIFY" > "${F}"
cat /dev/stdin > "${F}"
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



if [ -z "$DNS_REMOTE" ]; then
	cat /dev/stdin | bash ${TMP} || die "not able to apply dns config"
else
	ARGS=("${DNS_REMOTE}")
	if [ -n "${DNS_REMOTE_KEYFILE}" ]; then
		ARGS+=(-i "${DNS_REMOTE_KEYFILE}")
	fi
	set -x
	cat /dev/stdin | expect auto_ssh.expect "${ARGS[@]}" bash -c "$(<"${TMP}")" || die "not able to apply dns config"
	set +x
fi

