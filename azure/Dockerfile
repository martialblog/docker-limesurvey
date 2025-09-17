# Single LimeSurvey 6.0 image configured via a DB connection string
FROM php:8.2-apache-bookworm

LABEL maintainer="Codex Automation <codex@example.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Install base OS dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        netcat-openbsd \
        unzip \
        libldap-common \
        libsasl2-modules; \
    rm -rf /var/lib/apt/lists/*

# Add Microsoft package repository for the SQL Server ODBC driver
RUN set -eux; \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg; \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/microsoft-prod.list

# Install PHP extensions and SQL Server ODBC driver
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        unixodbc \
        unixodbc-dev \
        msodbcsql18 \
        libldap2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libonig-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        libtidy-dev \
        libsodium-dev; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
    docker-php-ext-install -j"$(nproc)" \
        exif \
        gd \
        ldap \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        sodium \
        tidy \
        zip; \
    pecl install sqlsrv pdo_sqlsrv; \
    docker-php-ext-enable sqlsrv pdo_sqlsrv; \
    apt-mark manual msodbcsql18 unixodbc; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark msodbcsql18 unixodbc; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '$3 ~ /^\/lib/ { print "/usr"$3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Apache configuration adjustments
RUN set -eux; \
    a2enmod headers rewrite remoteip; \
    { \
        echo 'RemoteIPHeader X-Forwarded-For'; \
        echo 'RemoteIPTrustedProxy 10.0.0.0/8'; \
        echo 'RemoteIPTrustedProxy 172.16.0.0/12'; \
        echo 'RemoteIPTrustedProxy 192.168.0.0/16'; \
    } > /etc/apache2/conf-available/remoteip.conf; \
    a2enconf remoteip; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

ARG LS_VERSION="6.15.11+250909"
ARG LS_SHA256="02f2f3125c20a5ebee1e6ec8beebf2e722cdf933d6c7e9ef8578484073b5fa94"
ARG LS_ARCHIVE_URL="https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/${LS_VERSION}.tar.gz"
ENV LIMESURVEY_VERSION=${LS_VERSION}

# Download LimeSurvey and prepare filesystem
RUN set -eux; \
    curl -sSL "${LS_ARCHIVE_URL}" --output /tmp/limesurvey.tar.gz; \
    echo "${LS_SHA256}  /tmp/limesurvey.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/limesurvey.tar.gz --strip-components=1 -C /var/www/html/; \
    rm -f /tmp/limesurvey.tar.gz; \
    chown -R www-data:www-data /var/www/html /etc/apache2

WORKDIR /var/www/html

COPY azure/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY azure/connection-string-parser.php /usr/local/bin/connection-string-parser.php
COPY azure/vhosts-access-log.conf /etc/apache2/conf-enabled/other-vhosts-access-log.conf

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/connection-string-parser.php

USER www-data

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
