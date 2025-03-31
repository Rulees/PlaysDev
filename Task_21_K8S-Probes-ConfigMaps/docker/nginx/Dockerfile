FROM nginx:1.27.4-alpine

ENV DOMAIN=""

RUN apk add --no-cache python3 lnav nano curl jq

COPY nginx_serv/ /sites/starter/         


RUN if ! getent group www-data; then addgroup -S www-data; fi && \
    if ! getent passwd www-data; then adduser -S www-data -G www-data; fi