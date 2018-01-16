#!/usr/bin/env bash

sleep 1
if [ -e /tmp/put-dns-status-error ]; then
	exit 1
fi
