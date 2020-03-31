FROM php:7.2-fpm-alpine
LABEL maintainer="markus@martialblog.de"
ARG version='3.22.10+200323'
ARG sha256_checksum='0a36ab7dd50e8654d7582bea507edcfc8bc2e42d2366cdeb1b66ea7d74855cb1'

# Install OS dependencies
RUN set -ex; \
        apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        openldap-dev \
        imap-dev \
        postgresql-dev && \
        apk add --no-cache netcat-openbsd bash

# Install PHP Plugins
RUN set -ex; \
        docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr ; \
        docker-php-ext-configure imap --with-imap-ssl && \
        docker-php-ext-install \
        gd \
        imap \
        ldap \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        zip

# Download, unzip and chmod of LimeSurvey
ADD "https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz" /tmp

RUN set -ex; \
        echo "${sha256_checksum}  /tmp/${version}.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/${version}.tar.gz" --strip-components=1 -C /var/www/html/ && \
        \
        rm -rf "/tmp/${version}.tar.gz" \
        /var/www/html/docs \
        /var/www/html/tests \
        /var/www/html/*.md && \
        chown -R www-data:root /var/www/ ; \
        chmod -R g=u /var/www

EXPOSE 9000

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
