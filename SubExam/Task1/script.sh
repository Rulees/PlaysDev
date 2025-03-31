#!/bin/bash

echo $(df -h)

LOG_FILE="/var/log/disk_usage.log"

size=$(df -h | grep '/$' | awk '{ print $5}' | sed 's/%//')
files=$(find /var -type f -size +100M 2>/dev/null)

if [[ $size -gt 90 ]]; then
    echo -e "\n\n"
    echo "Filesystem '/dev/sdc' is $size% full"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Filesystem '/dev/sdc' is $size% full" >> $LOG_FILE
    echo "${files}" >> $LOG_FILE
    echo -e "\n\n"
    echo -e "\n\n"
fi