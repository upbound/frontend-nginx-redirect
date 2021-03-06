#!/bin/bash

# Check for variables
export WORKER_CONNECTIONS=${WORKER_CONNECTIONS:-1024}
export HTTP_PORT=${HTTP_PORT:-8080}
export REDIRECT=${REDIRECT:-https\:\/\/\$host}
export REDIRECT_TYPE=${REDIRECT_TYPE:-permanent}
export NGINX_CONF=/etc/nginx/mushed.conf
export HSTS=${HSTS:-0}
export HSTS_MAX_AGE=${HSTS_MAX_AGE:-31536000}
export HSTS_INCLUDE_SUBDOMAINS=${HSTS_INCLUDE_SUBDOMAINS:-0}

# Build config
cat <<EOF > $NGINX_CONF
user nginx;
daemon off;

events {
    worker_connections $WORKER_CONNECTIONS;
}

http {
    server {
        listen $HTTP_PORT;
        server_tokens off;
        location / {
        $([ "${HSTS}" != "0" ] && echo "
        add_header Strict-Transport-Security \"max-age=${HSTS_MAX_AGE};$([ "${HSTS_INCLUDE_SUBDOMAINS}" != "0" ] && echo "includeSubDomains")\";
        ")
            rewrite ^(.*) $REDIRECT\$1 $REDIRECT_TYPE;
        }
        location /pingz {
            return 200 'pong z';
        }
        location /doc {
            rewrite ^(.*) $REDIRECT/404 302; 
        }
    }
}

EOF

cat $NGINX_CONF;
mkdir -p /run/nginx;
addgroup nginx --gid 1099
adduser nginx --disabled-password --uid 1099 --ingroup nginx --no-create-home --home /run/nginx 

chown -R nginx:nginx /var/lib/nginx /run/nginx ;

exec nginx -c $NGINX_CONF
