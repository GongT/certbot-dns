# you can create a file contains these config
# and save to /etc/profile.d
# or use certbot-dns -f "the file"

# certbot options
BASE_DOMAIN="service.gongt.me"
EMAIL="admin@gongt.me"

# config options
NAMED_DB_FILE="/etc/named/zones/db.service.gongt.me"
NAMED_SERVICE_CONTROL="systemctl restart named"
# eg: docker restart named

# cname command options
CNAME_TARGET="home.gongt.me"

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

