FROM php:7.2-fpm
LABEL maintainer="markus@martialblog.de"
ARG version='3.15.8+190130'
ARG sha256_checksum='0eb46c81c8fce8eb40625a899ed3a32a2f63a4dd9158da7ee2df2d78a67d4c0b'

# Install OS dependencies
RUN set -ex; \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive \
        apt-get install --no-install-recommends -y \
        \
        libldap2-dev \
        zlib1g-dev \
        libc-client-dev \
        libkrb5-dev \
        libpng-dev \
        libpq-dev \
        netcat \
        \
        && apt-get autoclean; apt-get autoremove; \
        rm -rf /var/lib/apt/lists/*

# Link LDAP library for PHP ldap extension
RUN set -ex; \
        ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

# Install PHP Plugins and Configure PHP imap plugin
RUN set -ex; \
        docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
        docker-php-ext-install -j5 \
        gd \
        imap \
        ldap \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        zip

ENV LIMESURVEY_VERSION=$version

# Download, unzip and chmod LimeSurvey from official GitHub repository
ADD "https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz" /tmp

RUN set -ex; \
        echo "${sha256_checksum} /tmp/${version}.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/${version}.tar.gz" --strip-components=1 -C /var/www/html/ && \
        rm -f "/tmp/${version}.tar.gz" && \
        chown -R www-data:www-data /var/www/html

EXPOSE 9000

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
