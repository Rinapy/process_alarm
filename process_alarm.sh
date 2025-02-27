#!/bin/bash

LOG_FILE_PATH=$(grep 'LOG_FILE=' .env | cut -d'=' -f2)
API_URL=$(grep 'API_URL=' .env | cut -d'=' -f2)
PROCESS_NAME=$(grep 'PROCESS_NAME=' .env | cut -d'=' -f2)
ACCESS_TOKEN=$(grep 'ACCESS_TOKEN=' .env | cut -d'=' -f2)
TIMEOUT=$(grep 'TIMEOUT=' .env | cut -d'=' -f2)

# Создаем лог-файл если он не существует и устанавливаем права
if [ ! -f "$LOG_FILE_PATH" ]; then
    sudo touch "$LOG_FILE_PATH"
    sudo chmod 666 "$LOG_FILE_PATH"
fi

if pgrep -x "$PROCESS_NAME" > /dev/null; then
    # Проверка на перезапуск
    if [ -f /tmp/${PROCESS_NAME}_process_stopped ]; then
        echo "$(date): Процесс '$PROCESS_NAME' был перезапущен." >> "$LOG_FILE_PATH"
        rm /tmp/${PROCESS_NAME}_process_stopped
    fi
    
    if [ ! -f /tmp/${PROCESS_NAME}_process_running ]; then
        echo "$(date): Процесс '$PROCESS_NAME' был запущен." >> "$LOG_FILE_PATH"
        touch /tmp/"${PROCESS_NAME}_process_running"
    fi

    JSON_DATA=$(cat <<EOF
{   
    "server": "$(hostname -I | awk '{print $1}')",
    "timestamp": "$(date)",
    "process_name": "$PROCESS_NAME",
    "status": "running",
}
EOF
)

    RESPONSE=$(curl -s -o --max-time $TIMEOUT /dev/null -w "%{http_code}" -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d "$JSON_DATA")

    if [ "$RESPONSE" -ne 200 ]; then
        echo "$(date): Сервер мониторинга недоступен, код ответа: $RESPONSE" >> "$LOG_FILE_PATH"
    fi
else
    if [ -f /tmp/${PROCESS_NAME}_process_running ]; then
        echo "$(date): Процесс '$PROCESS_NAME' остановлен." >> "$LOG_FILE_PATH"
        rm /tmp/${PROCESS_NAME}_process_running
        touch /tmp/${PROCESS_NAME}_process_stopped
    fi
fi