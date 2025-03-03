FROM nginx:1.27.4-alpine

ENV DOMAIN=""

RUN apk add --no-cache python3 openssl lnav nano curl jq

COPY nginx_serv/ /sites/starter/                
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sites-enabled/ /etc/nginx/sites-enabled/
COPY entrypoint-serverless.sh /entrypoint-serverless.sh


RUN if ! getent group www-data; then addgroup -S www-data; fi && \
    if ! getent passwd www-data; then adduser -S www-data -G www-data; fi


RUN chmod +x /entrypoint-serverless.sh


ENTRYPOINT ["/entrypoint-serverless.sh"]
