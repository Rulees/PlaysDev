#!/bin/sh

CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
YC_API_URL="https://data.certificate-manager.api.cloud.yandex.net/certificate-manager/v1/certificates/${CERTIFICATE_ID}:getContent"


if [ ! -f $CERT_PATH/fullchain.pem ] || [ ! -f $CERT_PATH/privkey.pem ]; then
    echo "🔄 Certificates missing. Downloading new ones..."

    mkdir -p $CERT_PATH

    # Запрашиваем сертификаты из Yandex Cloud
    CERT_RESPONSE=$(curl -s -H "Authorization: Bearer $IAM_TOKEN" -H "Content-Type: application/json" "$YC_API_URL")


    # Записываем сертификат
    echo "$CERT_RESPONSE" | jq -r '.certificateChain[]' > "$CERT_PATH/fullchain.pem"
    echo "$CERT_RESPONSE" | jq -r '.privateKey // empty' > "$CERT_PATH/privkey.pem"
    echo "✅ Certificates downloaded."
else
    echo "✅ Certificates already exist. Using them."
fi


# Generate file *.conf with vars from .env
for file in /etc/nginx/sites-enabled/*.template; do
    envsubst '${DOMAIN} ${EMAIL}' < "$file" > "${file%.template}"
    rm "$file"
done


nginx &
tail -f /var/log/nginx/access.log /var/log/nginx/error.log