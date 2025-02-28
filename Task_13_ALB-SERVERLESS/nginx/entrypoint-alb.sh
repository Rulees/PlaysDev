#!/bin/sh

# Generate file *.conf with vars from .env
for file in /etc/nginx/sites-enabled/*.template; do
    envsubst '${DOMAIN} ${EMAIL}' < "$file" > "${file%.template}"
    rm "$file"
done


nginx -g "daemon off;"