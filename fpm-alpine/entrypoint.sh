#!/bin/sh
# Entrypoint for Docker Container


DB_TYPE=${DB_TYPE:-'mysql'}
DB_HOST=${DB_HOST:-'mysql'}
DB_PORT=${DB_PORT:-'3306'}
DB_NAME=${DB_NAME:-'limesurvey'}
DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-'lime_'}
DB_USERNAME=${DB_USERNAME:-'limesurvey'}
DB_PASSWORD=${DB_PASSWORD:-}

ADMIN_USER=${ADMIN_USER:-'admin'}
ADMIN_NAME=${ADMIN_NAME:-'admin'}
ADMIN_EMAIL=${ADMIN_EMAIL:-'foobar@example.com'}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-'-'}

PUBLIC_URL=${PUBLIC_URL:-}
URL_FORMAT=${URL_FORMAT:-'path'}


# Check if database is available
until nc -z -v -w30 $DB_HOST $DB_PORT
do
    echo "Info: Waiting for database connection..."
    sleep 5
done


# Check if already provisioned
if [ -f application/config/config.php ]; then
    echo 'Info: config.php already provisioned'
else
    echo 'Info: Generating config.php'

    if [ "$DB_TYPE" = 'mysql' ]; then
        echo 'Info: Using MySQL configuration'
        DB_CHARSET=${DB_CHARSET:-'utf8mb4'}
        cp application/config/config-sample-mysql.php application/config/config.php
    fi

    if [ "$DB_TYPE" = 'pgsql' ]; then
        echo 'Info: Using PostgreSQL configuration'
        DB_CHARSET=${DB_CHARSET:-'utf8'}
        cp application/config/config-sample-pgsql.php application/config/config.php
    fi

    # Set Database config
    if [ ! -z "$DB_SOCK" ]; then
        echo 'Info: Using unix socket'
        sed -i "s#\('connectionString' => \).*,\$#\\1'${DB_TYPE}:unix_socket=${DB_SOCK};dbname=${DB_NAME};',#g" application/config/config.php
    else
        echo 'Info: Using TCP connection'
        sed -i "s#\('connectionString' => \).*,\$#\\1'${DB_TYPE}:host=${DB_HOST};port=${DB_PORT};dbname=${DB_NAME};',#g" application/config/config.php
    fi

    sed -i "s#\('username' => \).*,\$#\\1'${DB_USERNAME}',#g" application/config/config.php
    sed -i "s#\('password' => \).*,\$#\\1'${DB_PASSWORD}',#g" application/config/config.php
    sed -i "s#\('charset' => \).*,\$#\\1'${DB_CHARSET}',#g" application/config/config.php
    sed -i "s#\('tablePrefix' => \).*,\$#\\1'${DB_TABLE_PREFIX}',#g" application/config/config.php

    # Set URL config
    sed -i "s#\('urlFormat' => \).*,\$#\\1'${URL_FORMAT}',#g" application/config/config.php

    # Set Public URL
    if [ -z "$PUBLIC_URL" ]; then
        echo 'Info: Setting PublicURL'
        sed -i "s#\('debug'=>0,\)\$#'publicurl'=>'${PUBLIC_URL}',\n\t\t\\1 #g" application/config/config.php
    fi
fi


# Check if LimeSurvey database is provisioned
echo 'Info: Check if database already provisioned. Nevermind the Stack trace.'
php application/commands/console.php updatedb


if [ $? -eq 0 ]; then
    echo 'Info: Database already provisioned'
else
    # Check if DB_PASSWORD is set
    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'Error: Missing DB_PASSWORD'
        exit 1
    fi

    # Check if DB_PASSWORD is set
    if [ -z "$ADMIN_PASSWORD" ]; then
        echo >&2 'Error: Missing ADMIN_PASSWORD'
        exit 1
    fi

    echo ''
    echo 'Running console.php install'
    php application/commands/console.php install $ADMIN_USER $ADMIN_PASSWORD $ADMIN_NAME $ADMIN_EMAIL
fi

exec "$@"
