# you can create a file contains these config
# and save to /etc/profile.d
# or use certbot-dns -f "the file"

# certbot options
BASE_DOMAIN="service.gongt.me"
EMAIL="admin@gongt.me"

# config options
DNSMASQ_CONFIG_DIR="/var/lib/machines/homedns/etc/dnsmasq.d/"
DNSMASQ_SERVICE_CONTROL="systemctl -M homedns restart dnsmasq"
# eg: docker exec dnsmasq kill -SIGUSR2 1

# remote config
# use this if your dnsmasq is running on another machine
# this user must able to:
#   A. login with ssh
# 	B. run `sudo DNSMASQ_SERVICE_CONTROL` without password
#   C. able to write file to DNSMASQ_CONFIG_DIR
# or you can simply use root
#
# if you use a private key, then no "password" is required in DNS_REMOTE
# if you have configured ssh private key (eg: ~/.ssh/config), nothing is required.


# DNS_REMOTE="root:password@remote-server:22"
# DNS_REMOTE_KEYFILE=""
