FROM php:7.2-fpm-alpine
LABEL maintainer="markus@martialblog.de"
ARG version='3.15.8+190130'

# Install OS dependencies
RUN apk add --no-cache --virtual .build-deps \
    libpng-dev \
    openldap-dev \
    imap-dev \
    postgresql-dev && \
    apk add --no-cache netcat-openbsd bash

# Install PHP Plugins
RUN docker-php-ext-configure imap --with-imap-ssl && \
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
ADD "https://github.com/LimeSurvey/LimeSurvey/archive/${version}.tar.gz" /tmp

RUN tar xzvf "/tmp/${version}.tar.gz" --strip-components=1 -C /var/www/html/ && \
    rm -rf "/tmp/${version}.tar.gz" \
    /var/www/html/docs \
    /var/www/html/tests \
    /var/www/html/*.md && \
    chown -R www-data:root /var/www/ ; \
    chmod -R g=u /var/www

EXPOSE 9000

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
CMD ["php-fpm"]
