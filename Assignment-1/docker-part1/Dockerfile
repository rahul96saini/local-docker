FROM nginx:alpine

COPY app.sh /app.sh

RUN chmod +x /app.sh

CMD ["/bin/sh", "-c", "/app.sh & nginx -g 'daemon off;'"]