FROM php:7.2-apache
LABEL maintainer="markus@martialblog.de"
ARG version='3.17.8+190722'
ARG sha256_checksum='1bed7812431d3fb268821dd9a40a8d9b2924f06f7b16e5f02a6cc2162c78476d'

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
        && apt-get -y autoclean; apt-get -y autoremove; \
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

# Apache configuration
RUN a2enmod headers rewrite remoteip; \
        {\
        echo RemoteIPHeader X-Real-IP ;\
        echo RemoteIPTrustedProxy 10.0.0.0/8 ;\
        echo RemoteIPTrustedProxy 172.16.0.0/12 ;\
        echo RemoteIPTrustedProxy 192.168.0.0/16 ;\
        } > /etc/apache2/conf-available/remoteip.conf;\
        a2enconf remoteip

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Download, unzip and chmod LimeSurvey from official GitHub repository
ADD "https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz" /tmp

RUN set -ex; \
        echo "${sha256_checksum}  /tmp/${version}.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/${version}.tar.gz" --strip-components=1 -C /var/www/html/ && \
        rm -f "/tmp/${version}.tar.gz" && \
        chown -R www-data:www-data /var/www/html

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["apache2-foreground"]
