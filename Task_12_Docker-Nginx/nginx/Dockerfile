FROM nginx:1.27.4-alpine

EXPOSE 80 443


ARG EMAIL
ARG DOMAIN
ARG CERT_TYPE
ARG PROJECT_DIR
ARG CERTIFICATE_ID
ARG IAM_TOKEN

ENV EMAIL=$EMAIL
ENV DOMAIN=$DOMAIN
ENV PROJECT_DIR=$PROJECT_DIR
ENV CERT_TYPE=$CERT_TYPE
ENV CERTIFICATE_ID=$CERTIFICATE_ID
ENV IAM_TOKEN=$IAM_TOKEN

RUN apk add --no-cache certbot certbot-nginx python3 openssl lnav nano curl jq


COPY nginx_serv/ /sites/starter/                
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sites-enabled/ /etc/nginx/sites-enabled/
COPY entrypoint-letsencrypt.sh /entrypoint-letsencrypt.sh
COPY entrypoint-yandex.sh /entrypoint-yandex.sh



RUN if ! getent group www-data; then addgroup -S www-data; fi && \
    if ! getent passwd www-data; then adduser -S www-data -G www-data; fi


VOLUME ["/etc/letsencrypt", "/certbot/www"]


RUN chmod +x /entrypoint-letsencrypt.sh \
             /entrypoint-yandex.sh


ENTRYPOINT ["/bin/sh", "-c", "if [ \"$CERT_TYPE\" = 'yandex' ]; then exec /entrypoint-yandex.sh; else exec /entrypoint-letsencrypt.sh; fi"]
