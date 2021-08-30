#!/bin/sh

cert_path=/etc/letsencrypt/live/$(echo "$HOSTNAMES" | awk '{print $1}')
mkdir -p $cert_path

# if there is no certificate yet, get one
email="--email $CERT_EMAIL"
if [ -z "$CERT_EMAIL" ]
then
    email='--register-unsafely-without-email'
fi
if [ ! -e "$cert_path/privkey.pem" ]
then
    names=""
    for h in $HOSTNAMES
    do
        names="$names -d $h"
    done
    echo "Getting new certificate..."
    /usr/bin/curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > /etc/letsencrypt/options-ssl-nginx.conf
    /usr/bin/curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > /etc/letsencrypt/ssl-dhparams.pem
    /usr/bin/certbot certonly --standalone $names --agree-tos "$email"
fi

nginx -g "daemon off;"
