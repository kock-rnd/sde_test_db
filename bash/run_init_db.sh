#!/bin/bash
# Останавливаем и удаляем все запущенные контейнеры
sudo docker stop $(docker ps -a -q)
sudo docker rm $(docker ps -a -q)

# Скачиваем образ
sudo docker pull postgres

# Запускаем контейнер postgres
sudo docker run --name postgres \
-p 5432:5432 \
-e POSTGRES_DB="demo" \
-e POSTGRES_USER="test_sde" \
-e POSTGRES_PASSWORD="@sde_password012" \
-v $HOME/sde_test_db:$HOME/sde_test_db \
-d postgres

# Ожидаем, пока postgres запустится
sleep 10

# Выводим информацию о запущенном контейнере
sudo docker ps

# Выводим информацию о статусе postgres
sudo docker exec postgres pg_isready

#   Вапускаем скрипт для заполнения БД
sudo docker exec postgres psql -U test_sde -d demo -f $HOME/sde_test_db/sql/init_db/demo.sql

# Выводим сообщение об успешном завершении скрипта
echo "Инициализация БД выполнена успешно."
