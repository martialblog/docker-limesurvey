FROM php:7.2-fpm

# Install OS dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    libldap2-dev \
    libmagickwand-dev \
    imagemagick-common \
    libmagickcore-dev \
    imagemagick \
    libc-client-dev \
    libkrb5-dev \
    libpq-dev \
    && apt-get autoclean; apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Link LDAP library for PHP ldap extension
RUN ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Install PHP Plugins
RUN docker-php-ext-install -j5 \
    ldap \
    imap \
    mbstring \
    zip \
    gd \
    pdo \
    pdo_mysql \
    pgsql \
    pdo_pgsql

# Download, unzip and chmod of LimeSurvey
RUN curl -L https://github.com/LimeSurvey/LimeSurvey/archive/3.0.2+180110.tar.gz -o lime.tar.gz && \
    tar xzf lime.tar.gz && \
    mv -t /var/www/html LimeSurvey*/* && \
    rm -rf LimeSurvey-* lime.tar.gz && \
    chown www-data:www-data -R /var/www/html
