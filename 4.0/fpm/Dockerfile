FROM php:7.4-fpm
LABEL maintainer="markus@martialblog.de"
ARG version='4.5.2+210426'
ARG sha256_checksum='001c3e416e319d1b64e502620fa2a9a32e69d9b4db2f6376f4a6293b43a063ea'

# Install OS dependencies
RUN set -ex; \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive \
        apt-get install --no-install-recommends -y \
        \
        libldap2-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libonig-dev \
        zlib1g-dev \
        libc-client-dev \
        libkrb5-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        libtidy-dev \
        libsodium-dev \
        netcat \
        \
        && apt-get -y autoclean; apt-get -y autoremove; \
        rm -rf /var/lib/apt/lists/*

# Link LDAP library for PHP ldap extension
RUN set -ex; \
        ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

# Install PHP Plugins and Configure PHP imap plugin
RUN set -ex; \
        docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr && \
        docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
        docker-php-ext-install -j5 \
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

ENV LIMESURVEY_VERSION=$version

# Download, unzip and chmod LimeSurvey from official GitHub repository
RUN curl -sSL "https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz" --output /tmp/limesurvey.tar.gz

RUN set -ex; \
        echo "${sha256_checksum}  /tmp/limesurvey.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/limesurvey.tar.gz" --strip-components=1 -C /var/www/html/ && \
        rm -f "/tmp/limesurvey.tar.gz" && \
        chown -R www-data:www-data /var/www/html

EXPOSE 9000

WORKDIR /var/www/html
COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
