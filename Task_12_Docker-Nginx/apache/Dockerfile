FROM php:8.3-apache

EXPOSE 80

RUN apt update && apt install --no-install-recommends -y \
    lnav \
    nano \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf


COPY nginx_serv/ /var/www/html/


ENTRYPOINT ["apache2-foreground"]