#!/bin/bash
# Entrypoint for Docker Container


DB_TYPE=${DB_TYPE:-'mysql'}
DB_HOST=${DB_HOST:-'mysql'}
DB_PORT=${DB_PORT:-'3306'}
DB_SOCK=${DB_SOCK:-}
DB_NAME=${DB_NAME:-'limesurvey'}
DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-'lime_'}
DB_USERNAME=${DB_USERNAME:-'limesurvey'}
DB_PASSWORD=${DB_PASSWORD:-}

ENCRYPT_KEYPAIR=${ENCRYPT_KEYPAIR:-}
ENCRYPT_PUBLIC_KEY=${ENCRYPT_PUBLIC_KEY:-}
ENCRYPT_SECRET_KEY=${ENCRYPT_SECRET_KEY:-}

ADMIN_USER=${ADMIN_USER:-'admin'}
ADMIN_NAME=${ADMIN_NAME:-'admin'}
ADMIN_EMAIL=${ADMIN_EMAIL:-'foobar@example.com'}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-}

BASE_URL=${BASE_URL:-}
PUBLIC_URL=${PUBLIC_URL:-}
URL_FORMAT=${URL_FORMAT:-'path'}

DEBUG=${DEBUG:-0}
DEBUG_SQL=${DEBUG_SQL:-0}

if [ -z "$DB_PASSWORD" ]; then
    echo >&2 'Error: Missing DB_PASSWORD'
    exit 1
fi

if [ -z "$ADMIN_PASSWORD" ]; then
    echo >&2 'Error: Missing ADMIN_PASSWORD'
    exit 1
fi

# Check if database is available
if [ -z "$DB_SOCK" ]; then
    until nc -z -v -w30 $DB_HOST $DB_PORT
    do
        echo "Info: Waiting for database connection..."
        sleep 5
    done
fi

# Check if config already provisioned
if [ -f application/config/config.php ]; then
    echo 'Info: config.php already provisioned'
else
    echo 'Info: Generating config.php'

    if [ "$DB_TYPE" = 'mysql' ]; then
        echo 'Info: Using MySQL configuration'
        DB_CHARSET=${DB_CHARSET:-'utf8mb4'}
    fi

    if [ "$DB_TYPE" = 'pgsql' ]; then
        echo 'Info: Using PostgreSQL configuration'
        DB_CHARSET=${DB_CHARSET:-'utf8'}
    fi

    if [ ! -z "$DB_SOCK" ]; then
        echo 'Info: Using unix socket'
        DB_CONNECT='unix_socket'
    else
        echo 'Info: Using TCP connection'
        DB_CONNECT='host'
    fi

    if [ -z "$PUBLIC_URL" ]; then
        echo 'Info: Setting PublicURL'
    fi

    cat <<EOF > application/config/config.php
<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
return array(
  'components' => array(
    'db' => array(
      'connectionString' => '$DB_TYPE:$DB_CONNECT=$DB_HOST;port=$DB_PORT;dbname=$DB_NAME;',
      'emulatePrepare' => true,
      'username' => '$DB_USERNAME',
      'password' => '$DB_PASSWORD',
      'charset' => '$DB_CHARSET',
      'tablePrefix' => '$DB_TABLE_PREFIX',
    ),
    'urlManager' => array(
      'urlFormat' => '$URL_FORMAT',
      'rules' => array(),
      'showScriptName' => true,
    ),
    'request' => array(
      'baseUrl' => '$BASE_URL',
     ),
  ),
  'config'=>array(
    'publicurl'=>'$PUBLIC_URL',
    'debug'=>$DEBUG,
    'debugsql'=>$DEBUG_SQL,
  )
);

EOF

fi

# Check if security config already provisioned
if [ -f application/config/security.php ]; then
    echo 'Info: security.php already provisioned'
else
    echo 'Info: Creating security.php'
    if [ ! -z "$ENCRYPT_KEYPAIR" ]; then

        cat <<EOF > application/config/security.php
<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
\$config = array();
\$config['encryptionkeypair'] = '$ENCRYPT_KEYPAIR';
\$config['encryptionpublickey'] = '$ENCRYPT_PUBLIC_KEY';
\$config['encryptionsecretkey'] = '$ENCRYPT_SECRET_KEY';
return \$config;
EOF
    else
        echo >&2 'Warning: No encryption keys were provided'
        echo >&2 'Warning: A security.php config will be created by the application'
        echo >&2 'Warning: THIS FILE NEEDS TO BE PERSISTENT'
    fi
fi

# Check if LimeSurvey database is provisioned
echo 'Info: Check if database already provisioned. Nevermind the Stack trace.'
php application/commands/console.php updatedb

if [ $? -eq 0 ]; then
    echo 'Info: Database already provisioned'
else
    echo ''
    echo 'Running console.php install'
    php application/commands/console.php install $ADMIN_USER $ADMIN_PASSWORD $ADMIN_NAME $ADMIN_EMAIL
fi

exec "$@"
