#!/usr/bin/env bash
# you can create a file contains these config name as "config.sh"
# or use certbot-dns -f "the file" or cname -f "this file"

# === Certbot's options
BASE_DOMAIN="dynamic.example.com"
EMAIL="admin@example.com"

# === Config options
## use bind(9)
# NAMED_DB_FILE="${BIND_CONFIG_ROOT}/named/zones/db.dynamic.example.com"
# NAMED_SERVICE_CONTROL="systemctl reload named"

## use dnsmasq
# DNSMASQ_DIR="/var/lib/machines/homedns/etc/dnsmasq.d"
# DNSMASQ_SERVICE_CONTROL="systemctl restart dnsmasq"

## use PowerDNS
# PDNS_UTIL="/usr/bin/pdnsutil"
# PDNS_SERVICE_CONTROL="/usr/bin/pdns_control"

# cname command options
CNAME_TARGET="dispatcher.example.com."

## remote config
# use this if your name-server is running on another machine

##    NAMESPACE
# DNS_REMOTE_TYPE="ns"
# DNS_REMOTE="machine-name"

##    SSH
# DNS_REMOTE_TYPE="ssh"

#### remote user must able to:
# ** A. login with ssh
# ** B. run `sudo XXX_SERVICE_CONTROL` without password
# ** C. write to NAMED_DB_FILE or DNSMASQ_DIR or something

#### if you use a private key, then no "password"
# DNS_REMOTE="root:password@remote-server:22"

# the key to use (-i), if you not config it in .ssh/config
# DNS_REMOTE_KEYFILE=""
