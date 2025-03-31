#!/bin/sh

echo "---------Start entrypoint-apache.sh"

if [ -z "$PORT" ]; then
  echo "-----------ERROR: PORT environment variable is not set!"
  exit 1
fi

echo "---------Using PORT: $PORT"

echo "ServerName 0.0.0.0" >> /etc/apache2/apache2.conf
# Убеждаемся, что Apache слушает на всех интерфейсах
echo "Listen 0.0.0.0:$PORT" > /etc/apache2/ports.conf
sed -i "s/<VirtualHost .*>/<VirtualHost 0.0.0.0:$PORT>/" /etc/apache2/sites-enabled/000-default.conf


# Запускаем Apache в foreground-режиме (иначе контейнер завершится)
exec apache2-foreground

# tail -f /var/log/apache2/access.log