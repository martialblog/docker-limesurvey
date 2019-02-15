FROM php:7.2-fpm
LABEL maintainer="markus@martialblog.de"
ARG version='3.15.8+190130'

# Install OS dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    libldap2-dev \
    zlib1g-dev \
    libc-client-dev \
    libkrb5-dev \
    libpng-dev \
    libpq-dev \
    netcat \
    && apt-get autoclean; apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Link LDAP library for PHP ldap extension
RUN ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Install PHP Plugins
RUN docker-php-ext-install -j5 \
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

RUN tar xzvf "/tmp/${version}.tar.gz" --strip-components=1 -C /var/www/html/ && \
    rm "/tmp/${version}.tar.gz" && \
    chown -R www-data:www-data /var/www/html

EXPOSE 9000

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
