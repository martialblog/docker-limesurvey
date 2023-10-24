#!/bin/bash
# Entrypoint for Docker Container

file_env() {
        local v="$1"
        local fv="${v}_FILE"
        local default="${2:-}"
        if [ "${!v:-}" ] && [ "${!fv:-}" ]; then
            echo >&2 "$v and $fv are exclusive"
            exit 1
        fi
        local val="$default"
        if [ "${!v:-}" ]; then
                val="${!v}"
        elif [ "${!fv:-}" ]; then
                val="$(< "${!fv}")"
        fi
        export "$v"="$val"
        unset "$fv"
}

DB_TYPE=${DB_TYPE:-'mysql'}
DB_HOST=${DB_HOST:-'mysql'}
DB_PORT=${DB_PORT:-'3306'}
DB_SOCK=${DB_SOCK:-}
DB_NAME=${DB_NAME:-'limesurvey'}
DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-'lime_'}
DB_USERNAME=${DB_USERNAME:-'limesurvey'}
DB_MYSQL_ENGINE=${DB_MYSQL_ENGINE:-'MyISAM'}
file_env 'DB_PASSWORD'

file_env 'ENCRYPT_KEYPAIR'
file_env 'ENCRYPT_PUBLIC_KEY'
file_env 'ENCRYPT_SECRET_KEY'
file_env 'ENCRYPT_NONCE'
file_env 'ENCRYPT_SECRET_BOX_KEY'

ADMIN_USER=${ADMIN_USER:-'admin'}
ADMIN_NAME=${ADMIN_NAME:-'admin'}
ADMIN_EMAIL=${ADMIN_EMAIL:-'foobar@example.com'}
file_env 'ADMIN_PASSWORD'

BASE_URL=${BASE_URL:-}
PUBLIC_URL=${PUBLIC_URL:-}
URL_FORMAT=${URL_FORMAT:-'path'}
SHOW_SCRIPT_NAME=${SHOW_SCRIPT_NAME:-'true'}
TABLE_SESSION=${TABLE_SESSION:-}

DEBUG=${DEBUG:-0}
DEBUG_SQL=${DEBUG_SQL:-0}

LISTEN_PORT=${LISTEN_PORT:-"8080"}

if [ -z "$DB_PASSWORD" ]; then
    echo >&2 'Error: Missing DB_PASSWORD or DB_PASSWORD_FILE'
    exit 1
fi

if [ -z "$ADMIN_PASSWORD" ]; then
    echo >&2 'Error: Missing ADMIN_PASSWORD or ADMIN_PASSWORD_FILE'
    exit 1
fi

if [ "$LISTEN_PORT" != "80" ]; then
    echo "Info: Customizing Apache Listen port to $LISTEN_PORT"
    sed -i "s/Listen 80\$/Listen $LISTEN_PORT/" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf
fi

# Check if database is available
if [ -z "$DB_SOCK" ]; then
    until nc -z -v -w30 "$DB_HOST" "$DB_PORT"
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

    if [ -n "$DB_SOCK" ]; then
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
      'tablePrefix' => '${DB_TABLE_PREFIX//[[:space:]]/}',
    ),
    //'session' => array (
    //   'class' => 'application.core.web.DbHttpSession',
    //   'connectionID' => 'db',
    //   'sessionTableName' => '{{sessions}}',
    //),
    'urlManager' => array(
      'urlFormat' => '$URL_FORMAT',
      'rules' => array(),
      'showScriptName' => $SHOW_SCRIPT_NAME,
    ),
    'request' => array(
      'baseUrl' => '$BASE_URL',
     ),
  ),
  'config'=>array(
    'publicurl'=>'$PUBLIC_URL',
    'debug'=>$DEBUG,
    'debugsql'=>$DEBUG_SQL,
    'mysqlEngine' => '$DB_MYSQL_ENGINE',
  )
);

EOF

fi

# Enable Table Sessions if required
if [ -n "$TABLE_SESSION" ]; then
    echo 'Info: Setting Table Session'
    # Remove the comments in the config
    sed -i "s/\/\///g" application/config/config.php
fi

# Check if security config already provisioned
if [ -f application/config/security.php ]; then
    echo 'Info: security.php already provisioned'
else
    echo 'Info: Creating security.php'
    if [ -n "$ENCRYPT_KEYPAIR" ] || [ -n "$ENCRYPT_SECRET_BOX_KEY" ]; then

        cat <<EOF > application/config/security.php
<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
\$config = array();
\$config['encryptionkeypair'] = '$ENCRYPT_KEYPAIR';
\$config['encryptionpublickey'] = '$ENCRYPT_PUBLIC_KEY';
\$config['encryptionsecretkey'] = '$ENCRYPT_SECRET_KEY';
\$config['encryptionnonce'] = '$ENCRYPT_NONCE';
\$config['encryptionsecretboxkey'] = '$ENCRYPT_SECRET_BOX_KEY';
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

PHP_UPDATEDB_EXIT_CODE=$?

if [ $PHP_UPDATEDB_EXIT_CODE -eq 0 ]; then
    echo 'Info: Database already provisioned'
else
    echo ''
    echo 'Running console.php install'
    php application/commands/console.php install "$ADMIN_USER" "$ADMIN_PASSWORD" "$ADMIN_NAME" "$ADMIN_EMAIL"
fi

exec "$@"
