#!/bin/bash

PRIVATE_SERVER="10.10.2.30"
LOG_FILE="/var/log/update.log"

# Log the start of the update
echo "--$(date): Начало обновления на $PRIVATE_SERVER" >> $LOG_FILE

# Check if private server has internet connectivity by pinging a known external host
PING_RESULT=$(ssh -i /home/melnikov/.ssh/YC -o StrictHostKeyChecking=no melnikov@$PRIVATE_SERVER "ping -c 1 8.8.8.8")

if [ $? -ne 0 ]; then
    # Log network failure if no internet
    echo "--$(date): Ошибка! Не удалось подключиться или Нет интернета на сервере $PRIVATE_SERVER." >> $LOG_FILE
    echo -e "--------------------------------------------------\n\n" >> $LOG_FILE
    exit 1
fi

# Run the update, capture output
OUTPUT=$(ssh -i /home/melnikov/.ssh/YC -o StrictHostKeyChecking=no melnikov@$PRIVATE_SERVER "sudo apt update")

# Log the update output
echo "$OUTPUT" >> $LOG_FILE

# Check if the apt command succeeded
if [ $? -eq 0 ]; then
    echo "--$(date): Обновление прошло успешно." >> $LOG_FILE
else
    echo "--$(date): Ошибка при обновлении." >> $LOG_FILE
fi

echo -e "--------------------------------------------------\n\n" >> $LOG_FILE