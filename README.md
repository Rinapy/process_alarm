# Process Alarm

## Описание

Программа предназначена для мониторинга процесса на серверах и отправки уведомлений на API.

## Установка

1. Склонируйте репозиторий:

```bash
git clone https://github.com/yourusername/process-alarm.git
```

2. Скопируйте файл .env-example в .env и заполните его:

```bash
cp .env-example .env 
```

3. Установите необходимые права и скопируйте файл:

```bash
chmod +x process_alarm.sh
sudo cp process_alarm.sh /usr/bin/
```

4. Скопируйте файл process_alarm.service в /etc/systemd/system/:

```bash
sudo cp process_alarm.service /etc/systemd/system/
```

5. Скопируйте файл process_alarm.timer в /etc/systemd/system/:

```bash
sudo cp process_alarm.timer /etc/systemd/system/
```

6. Перезагрузите сервисы:

```bash
sudo systemctl daemon-reload
sudo systemctl enable process_alarm.timer
```
