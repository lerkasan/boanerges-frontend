FROM node:18.16-alpine@sha256:bf6c61feabc1a1bd565065016abe77fa378500ec75efa67f5b04e5e5c4d447cd AS builder

ARG ENVIRONMENT=production

RUN mkdir /app

WORKDIR /app

COPY package*.json jsconfig.json babel.config.js vue.config.js ./
COPY .env.${ENVIRONMENT} ./.env
COPY ./src ./src

RUN npm ci && \
    npm run build



FROM nginx:1.24.0-alpine-slim@sha256:da86ecb516d88a5b0579cec8687a75f974712cb5091560c06ef6c393ea4936ee

ARG DOMAIN_NAME=lerkasan.net
#ENV DOMAIN_NAME=$DOMAIN_NAME

COPY --from=builder /app/dist /var/www
COPY nginx_config/nginx-default.conf /etc/nginx/conf.d/default.conf

# Using ARG during build-time
RUN sed -i "s/%DOMAIN_NAME%/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

# Using ENV variable during runtime
#COPY nginx_config/insert_domain_name_in_config.sh /docker-entrypoint.d/insert_domain_name_in_config.sh
#RUN chown nginx:nginx /docker-entrypoint.d/insert_domain_name_in_config.sh && \
#    chmod +x /docker-entrypoint.d/insert_domain_name_in_config.sh

EXPOSE 80
