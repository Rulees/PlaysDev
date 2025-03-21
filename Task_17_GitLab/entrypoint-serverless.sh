#!/bin/sh

echo "---------Start entrypoint-serverless.sh"


# Проверяем, что переменные окружения заданы
if [ -z "$PORT" ]; then
  echo "----------ERROR: PORT env_var is not set!"
  exit 1
fi
if [ -z "$DOMAIN" ]; then
  echo "----------ERROR: DOMAIN env_var is not set!"
  exit 1
fi

echo "----------Use PORT: $PORT"
echo "----------Use DOMAIN: $DOMAIN"


# Generate file *.conf with vars from .env
for file in /etc/nginx/sites-enabled/*.template; do
    envsubst '${DOMAIN} ${PORT}' < "$file" > "${file%.template}"
    rm "$file"
done
echo "---------Conf files generated from .template"


nginx &


echo "---------Nginx launched"
# cat /etc/nginx/sites-enabled/*

tail -f /var/log/nginx/access.log /var/log/nginx/error.log