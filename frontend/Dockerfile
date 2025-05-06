FROM nginx:stable-alpine

RUN sed -i 's/listen       80;/listen       8001;/' \
       /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 8001

