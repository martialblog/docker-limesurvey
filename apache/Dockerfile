FROM php:7.2-apache

# Install PHP Plugins
RUN docker-php-ext-install ldap \
    && docker-php-ext-install imap \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \

# Download, unzip and chmod of LimeSurvey
RUN curl -L https://github.com/LimeSurvey/LimeSurvey/archive/3.0.2+180110.tar.gz -o lime.tar.gz && \
    tar xzf lime.tar.gz && \
    mv -t /var/www/html LimeSurvey*/* && \
    rm -rf LimeSurvey-* lime.tar.gz && \
    chown www-data:www-data -R /var/www/html
