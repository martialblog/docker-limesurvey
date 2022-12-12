FROM docker.io/php:8.0-apache
LABEL maintainer="markus@martialblog.de"

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
        curl \
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

ARG version="5.4.14+221205"
ARG sha256_checksum="60aa7134045ca5d2ba7e0872cc86a4ae17d30205ac6b3f8207591f83afd51171"
ARG archive_url="https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz"
ARG USER=www-data
ARG LISTEN_PORT=8080
ENV LIMESURVEY_VERSION=$version

# Download, unzip and chmod LimeSurvey from GitHub (defaults to the official LimeSurvey/LimeSurvey repository) 
RUN set -ex; \
        curl -sSL "${archive_url}" --output /tmp/limesurvey.tar.gz && \
        echo "${sha256_checksum}  /tmp/limesurvey.tar.gz" | sha256sum -c - && \
        \
        tar xzvf "/tmp/limesurvey.tar.gz" --strip-components=1 -C /var/www/html/ && \
        rm -f "/tmp/limesurvey.tar.gz" && \
        chown -R "$USER:$USER" /var/www/html /etc/apache2

EXPOSE $LISTEN_PORT

WORKDIR /var/www/html
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY vhosts-access-log.conf /etc/apache2/conf-enabled/other-vhosts-access-log.conf
USER $USER
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
