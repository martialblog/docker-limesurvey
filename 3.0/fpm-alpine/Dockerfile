FROM php:7.2-fpm-alpine
LABEL maintainer="markus@martialblog.de"
ARG version='3.22.27+200720'
ARG sha256_checksum='52b977f58a422dbb0d9284e362c86dc8e1b9c3d4035975c144b5256b27d55af5'

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

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
