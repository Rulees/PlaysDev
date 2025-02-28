#!/bin/bash

# Устанавливаем заголовок ответа
echo "Content-Type: application/json"
echo

# Получаем загрузку CPU и формируем ответ
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
echo "{\"cpu\": $cpu_usage}"