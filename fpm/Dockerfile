FROM php:7.2-apache

# Install PHP Plugins
RUN docker-php-ext-install ldap \
    && docker-php-ext-install imap \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \

# Download, unzip and chmod of LimeSurvey
RUN wget https://github.com/LimeSurvey/LimeSurvey/archive/3.0.0+171222.tar.gz -o lime.tar.gz && \
    tar xzf lime.tar.gz && \
    mv -t /var/www/html LimeSurvey*/* && \
    chmod -R /var/www/html
