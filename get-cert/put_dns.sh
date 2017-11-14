#!/usr/bin/env bash

set -e

source base.sh

CONTENT="$*"
if [ -z "${CONTENT}" ]; then
	die "Error: not able to parse request output"
fi

if false ; then
	DOMAIN=
	EMAIL=
	DNSMASQ_CONFIG_DIR=
	DNSMASQ_SERVICE_CONTROL=
	DNS_REMOTE=
	DNS_REMOTE_KEYFILE=
fi

DNSMASQ_CONFIG_DIR="${DNSMASQ_CONFIG_DIR%/}"

# .${RANDOM}
TMP=/tmp/certbot-dns-remote-run.sh

cat << InputComesFromHERE > ${TMP}
set -e
mkdir -p "${DNSMASQ_CONFIG_DIR}"
echo "# GENERATED FILE DO NOT MODIFY
txt-record=_acme-challenge.${DOMAIN},"${CONTENT}"
" > "${DNSMASQ_CONFIG_DIR}/${DOMAIN}.conf"
sudo ${DNSMASQ_SERVICE_CONTROL} || {
	rm -f "${DNSMASQ_CONFIG_DIR}/${DOMAIN}.conf"
	sudo ${DNSMASQ_SERVICE_CONTROL}
	exit 1
}
exit 0
InputComesFromHERE


if [ -z "$DNS_REMOTE" ]; then
	bash ${TMP} || die "not able to apply dns config"
else
	ARGS=("${DNS_REMOTE}")
	if [ -n "${DNS_REMOTE_KEYFILE}" ]; then
		ARGS+=(-i "${DNS_REMOTE_KEYFILE}")
	fi
	set -x
	cat "${TMP}" | expect auto_ssh.expect "${ARGS[@]}" bash || die "not able to apply dns config"
	set +x
fi
