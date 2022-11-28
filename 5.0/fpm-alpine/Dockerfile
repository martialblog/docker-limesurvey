FROM docker.io/php:8.0-fpm-alpine
LABEL maintainer="markus@martialblog.de"

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

ARG version="5.4.12+221121"
ARG sha256_checksum="dad21c2512579a9ebca78bb5a1fd3d83e0ebfaf3a6204797491a481c63bc2471"
ARG archive_url="https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz"
ARG USER=www-data
ENV LIMESURVEY_VERSION=$version

# Download, unzip and chmod LimeSurvey from GitHub (defaults to the official LimeSurvey/LimeSurvey repository) 
RUN set -ex; \
        curl -sSL "${archive_url}" --output /tmp/limesurvey.tar.gz && \
        echo "${sha256_checksum}  /tmp/limesurvey.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/limesurvey.tar.gz" --strip-components=1 -C /var/www/html/ && \
        \
        rm -rf "/tmp/limesurvey.tar.gz" \
        /var/www/html/docs \
        /var/www/html/tests \
        /var/www/html/*.md && \
        chown -R "${USER}:root" /var/www/ ; \
        chmod -R g=u /var/www

EXPOSE 9000

WORKDIR /var/www/html
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER $USER
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
