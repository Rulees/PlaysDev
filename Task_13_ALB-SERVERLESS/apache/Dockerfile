FROM php:8.3-apache

RUN apt update && apt install --no-install-recommends -y \
    lnav \
    nano \
    curl \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint-apache.sh /entrypoint-apache.sh
COPY nginx_serv/ /var/www/html/


RUN chmod +x /entrypoint-apache.sh

ENTRYPOINT ["/entrypoint-apache.sh"]