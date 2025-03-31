FROM php:8.3-apache

RUN apt update && apt install --no-install-recommends -y \
    lnav \
    nano \
    curl \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN echo "ServerName 0.0.0.0" >> /etc/apache2/apache2.conf && \
    echo "Listen 0.0.0.0:80" > /etc/apache2/ports.conf && \
    sed -i "s/<VirtualHost .*>/<VirtualHost 0.0.0.0:80>/" /etc/apache2/sites-enabled/000-default.conf

COPY nginx_serv/ /var/www/html/