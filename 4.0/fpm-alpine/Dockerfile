FROM php:7.4-fpm-alpine
LABEL maintainer="markus@martialblog.de"
ARG version='4.5.2+210426'
ARG sha256_checksum='001c3e416e319d1b64e502620fa2a9a32e69d9b4db2f6376f4a6293b43a063ea'

# Install OS dependencies
RUN set -ex; \
        apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libpng-dev \
        libzip-dev \
        libjpeg-turbo-dev \
        tidyhtml-dev \
        libsodium-dev \
        openldap-dev \
        oniguruma-dev \
        imap-dev \
        postgresql-dev && \
        apk add --no-cache netcat-openbsd bash

# Install PHP Plugins
RUN set -ex; \
        docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr && \
        docker-php-ext-configure imap --with-imap-ssl && \
        docker-php-ext-install \
        exif \
        gd \
        imap \
        ldap \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        sodium \
        tidy \
        zip

# Download, unzip and chmod of LimeSurvey
RUN curl -sSL "https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz" --output /tmp/limesurvey.tar.gz

RUN set -ex; \
        echo "${sha256_checksum}  /tmp/limesurvey.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/limesurvey.tar.gz" --strip-components=1 -C /var/www/html/ && \
        \
        rm -rf "/tmp/limesurvey.tar.gz" \
        /var/www/html/docs \
        /var/www/html/tests \
        /var/www/html/*.md && \
        chown -R www-data:root /var/www/ ; \
        chmod -R g=u /var/www

EXPOSE 9000

WORKDIR /var/www/html
COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
