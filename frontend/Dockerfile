FROM node:20-alpine AS builder
WORKDIR /app

RUN npm init -y \
 && npm install -D tailwindcss@latest postcss@latest autoprefixer@latest

COPY tailwind.config.js postcss.config.js ./
COPY src ./src

RUN npx tailwindcss -i ./src/input.css -o ./dist/output.css --minify

FROM nginx:stable-alpine

RUN sed -i 's/listen       80;/listen       8001;/' \
       /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist/output.css /usr/share/nginx/html/output.css
COPY src/index.html /usr/share/nginx/html/index.html

EXPOSE 8001

