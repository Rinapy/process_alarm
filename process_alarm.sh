#!/bin/bash

LOG_FILE=$(grep 'LOG_FILE=' .env | cut -d'=' -f2)
API_URL=$(grep 'API_URL=' .env | cut -d'=' -f2)
PROCESS_NAME=$(grep 'PROCESS_NAME=' .env | cut -d'=' -f2)
ACCESS_TOKEN=$(grep 'ACCESS_TOKEN=' .env | cut -d'=' -f2)


if pgrep -x "$PROCESS_NAME" > /dev/null; then
    if [ ! -f /tmp/${PROCESS_NAME}_process_running ]; then
        echo "$(date): Процесс '$PROCESS_NAME' был запущен." >> "$LOG_FILE"
    fi

    touch /tmp/"${PROCESS_NAME}_process_running"

    JSON_DATA=$(cat <<EOF
{   
    "server": "$(hostname -I | awk '{print $1}')"
    "timestamp": "$(date)",
    "process_name": "$PROCESS_NAME",
    "status": "running",
}
EOF
)


    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d "$JSON_DATA")

    if [ "$RESPONSE" -ne 200 ]; then
        echo "$(date): Сервер мониторинга недоступен, код ответа: $RESPONSE" >> "$LOG_FILE"
    fi
else
    if [ -f /tmp/${PROCESS_NAME}_process_running ]; then
        echo "$(date): Процесс '$PROCESS_NAME' остановлен." >> "$LOG_FILE"
        rm /tmp/test_process_running
    fi
fi