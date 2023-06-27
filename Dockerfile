FROM node:18.16-alpine@sha256:bf6c61feabc1a1bd565065016abe77fa378500ec75efa67f5b04e5e5c4d447cd AS builder

RUN mkdir /app

WORKDIR /app

COPY package*.json jsconfig.json babel.config.js vue.config.js ./
COPY ./src ./src

RUN npm ci && \
    npm run build



FROM nginx:1.24.0-alpine-slim@sha256:da86ecb516d88a5b0579cec8687a75f974712cb5091560c06ef6c393ea4936ee

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
