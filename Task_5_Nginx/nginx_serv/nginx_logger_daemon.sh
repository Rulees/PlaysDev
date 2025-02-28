#!/bin/bash

ACCESS_LOG="/var/log/nginx/access.log"
ERROR_LOG="/var/log/nginx/error.log"
REDBLUE_LOG="/var/log/nginx/redblue_access.log"

FILE_1="/var/log/nginx/task5_file1.log" # nginx_logs
FILE_2="/var/log/nginx/task5_file2.log" # nginx_erase_logs
FILE_3="/var/log/nginx/task5_file3.log" # 5xx_logs
FILE_4="/var/log/nginx/task5_file4.log" # 4xx_logs

MAX_SIZE=300000  # 300 КБ


while true; do

    # Check if FILE_1 exceeds size limit
    if [ -f "$FILE_1" ] && [ $(stat -c%s "$FILE_1") -gt $MAX_SIZE ]; then
        LINES_REMOVED=$(wc -l < "$FILE_1") > "$FILE_1"

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleared $FILE_1 Removed $LINES_REMOVED lines." >> "$FILE_2"
    fi

    # Log last 10 entries from each log file
    {
        echo "Access Logs:"
        tail -n 10 "$ACCESS_LOG"
        echo "-----------------------------------"
        echo "Error Logs:"
        tail -n 10 "$ERROR_LOG"
        echo "-----------------------------------"
        echo "Redblue Access Logs:"
        tail -n 10 "$REDBLUE_LOG"
        echo "-----------------------------------"
        echo "-----------------------------------"
        echo "-----------------------------------"

    } >> "$FILE_1"

    # Parse logs for 5xx and 4xx errors
    awk '$9 ~ /^5[0-9]{2}$/' "$ACCESS_LOG" | sed 's/^/5xx Log: /' >> "$FILE_3"
    awk '$9 ~ /^4[0-9]{2}$/' "$ACCESS_LOG" | sed 's/^/4xx Log: /' >> "$FILE_4"

    sleep 5
done
