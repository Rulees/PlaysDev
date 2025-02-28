#!/bin/sh
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

# Симуляция массива с разделителем `|`
MESSAGES="\
0|    Generating self-signed cert...
1|    Processing .template files...
2|    Checking cert...
3|    Certbot: New cert generated.
4|    Certbot: Cert renewed.
5|    Certbot: Replaced with Let's Encrypt cert."

# Функция поиска сообщений по индексу
x() {
    echo "$MESSAGES" | grep "^$1|" | cut -d'|' -f2-
}



# Generate self-signed cert, if it doeesn't exist
if [ ! -f $CERT_PATH/fullchain.pem ]; then
    x 0
    mkdir -p $CERT_PATH
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$CERT_PATH/privkey.pem" \
            -out "$CERT_PATH/fullchain.pem" \
        -subj "/CN=self-signed"
fi

# Generate file *.conf with vars from .env
x 1
for file in /etc/nginx/sites-enabled/*.template; do
    envsubst '${DOMAIN} ${EMAIL}' < "$file" > "${file%.template}" # remove text(.template)
    rm "$file"
done


nginx &


# Replace self-signed cert to certbot-certfificate
x 2
if [ ! -f $CERT_PATH/fullchain.pem ]; then
    certbot --nginx -d $DOMAIN --email $EMAIL --force-renewal --noninteractive --agree-tos --no-eff-email
    x 3
else
    issuer=$(openssl x509 -in $CERT_PATH/fullchain.pem -text -noout | grep "Issuer:")

    if [[ $issuer == *"Let's Encrypt"* ]]; then
        certbot renew --quiet
        x 4
    else
        certbot --nginx -d $DOMAIN --email $EMAIL --force-renewal --noninteractive --agree-tos --no-eff-email
        x 5
    fi
fi

# Keep the container running
tail -f /var/log/nginx/access.log /var/log/nginx/error.log
