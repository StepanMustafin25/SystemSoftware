# Используем официальный образ nginx для статического контента
FROM nginx:alpine

# Удаляем дефолтную конфигурацию nginx
RUN rm -rf /usr/share/nginx/html/*

# Копируем файлы приложения в контейнер
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
COPY components/ /usr/share/nginx/html/components/

# Копируем кастомную конфигурацию nginx (опционально)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт 80
EXPOSE 80

# Nginx запускается автоматически при старте контейнера
CMD ["nginx", "-g", "daemon off;"]



