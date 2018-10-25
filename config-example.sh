#!/usr/bin/env bash
# you can create a file contains these config
# and save to /etc/profile.d
# or use certbot-dns -f "the file"

# certbot options
BASE_DOMAIN="dynamic.example.com"
EMAIL="admin@example.com"

BIND_CONFIG_ROOT="/data/AppData/config/homedns"
# config options
NAMED_DB_FILE="${BIND_CONFIG_ROOT}/named/zones/db.dynamic.example.com"
NAMED_SERVICE_CONTROL="systemctl reload named -M homedns"
# DNSMASQ_DIR="/var/lib/machines/homedns/etc/dnsmasq.d"
# DNSMASQ_SERVICE_CONTROL="systemctl restart dnsmasq -M homedns"

# cname command options
CNAME_TARGET="dispatcher.example.com."

# remote config
# use this if your named is running on another machine
# this user must able to:
#   A. login with ssh
# 	B. run `sudo NAMED_SERVICE_CONTROL` without password
#   C. able to write to NAMED_DB_FILE
# or you can simply use root
#
# if you use a private key, then no "password" is required in DNS_REMOTE
# if you have configured ssh private key (eg: ~/.ssh/config), nothing is required.


# DNS_REMOTE="root:password@remote-server:22"
# DNS_REMOTE_KEYFILE=""

