#!/bin/sh
set -xe

sed -i "s/%DOMAIN_NAME%/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf