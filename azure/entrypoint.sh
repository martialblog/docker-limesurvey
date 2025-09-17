#!/bin/bash
set -euo pipefail

log() {
    printf '%s %s\n' "[entrypoint]" "$*"
}

if [[ -z "${DB_CONNECTION_STRING:-}" ]]; then
    echo "Error: DB_CONNECTION_STRING environment variable is required." >&2
    exit 1
fi

LISTEN_PORT=${LISTEN_PORT:-8080}
if [[ "$LISTEN_PORT" != "80" ]]; then
    log "Configuring Apache listen port to $LISTEN_PORT"
    sed -i "s/Listen 80\$/Listen $LISTEN_PORT/" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:80>/<VirtualHost *:$LISTEN_PORT>/" /etc/apache2/sites-available/000-default.conf
fi

parse_output=()
while IFS= read -r line; do
    parse_output+=("$line")
done < <(DB_CONNECTION_STRING="$DB_CONNECTION_STRING" /usr/local/bin/connection-string-parser.php)

declare -A DB_PROPS
for entry in "${parse_output[@]}"; do
    key=${entry%%=*}
    value=${entry#*=}
    DB_PROPS["$key"]=$value
    case "$key" in
        DB_PASSWORD)
            log "$key=******"
            ;;
        DB_DSN)
            log "$key=<hidden>"
            ;;
        *)
            log "$key=${value}"
            ;;
    esac
done

DB_DSN=${DB_PROPS[DB_DSN]:-}
DB_USERNAME=${DB_PROPS[DB_USERNAME]:-}
DB_PASSWORD=${DB_PROPS[DB_PASSWORD]:-}
DB_DRIVER=${DB_PROPS[DB_DRIVER]:-}
DB_HOST=${DB_PROPS[DB_HOST]:-}
DB_PORT=${DB_PROPS[DB_PORT]:-}
DB_DATABASE=${DB_PROPS[DB_DATABASE]:-}

if [[ -z "$DB_DSN" ]]; then
    echo "Error: Unable to compute PDO DSN from DB_CONNECTION_STRING" >&2
    exit 1
fi

DB_CHARSET="utf8"
if [[ "$DB_DRIVER" == "mysql" ]]; then
    DB_CHARSET="utf8mb4"
fi

DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-lime_}
PUBLIC_URL=${PUBLIC_URL:-}
BASE_URL=${BASE_URL:-}
URL_FORMAT=${URL_FORMAT:-path}
SHOW_SCRIPT_NAME=${SHOW_SCRIPT_NAME:-false}
DEBUG_LEVEL=${DEBUG:-0}
DEBUG_SQL_LEVEL=${DEBUG_SQL:-0}

export LS_DB_DSN="$DB_DSN"
export LS_DB_USERNAME="$DB_USERNAME"
export LS_DB_PASSWORD="$DB_PASSWORD"
export LS_DB_CHARSET="$DB_CHARSET"
export LS_DB_TABLE_PREFIX="$DB_TABLE_PREFIX"
export LS_DB_DRIVER="$DB_DRIVER"
export LS_PUBLIC_URL="$PUBLIC_URL"
export LS_BASE_URL="$BASE_URL"
export LS_URL_FORMAT="$URL_FORMAT"
export LS_SHOW_SCRIPT_NAME="$SHOW_SCRIPT_NAME"
export LS_DEBUG_LEVEL="$DEBUG_LEVEL"
export LS_DEBUG_SQL_LEVEL="$DEBUG_SQL_LEVEL"

if [[ -n "$DB_HOST" && -n "$DB_PORT" ]]; then
    log "Waiting for database ${DB_HOST}:${DB_PORT}"
    until nc -z -w5 "$DB_HOST" "$DB_PORT"; do
        log "Database not reachable yet..."
        sleep 5
    done
fi

CONFIG_PATH="application/config/config.php"
if [[ ! -f "$CONFIG_PATH" ]]; then
    log "Generating LimeSurvey config.php"
    php <<'PHP'
<?php
$configPath = 'application/config/config.php';
$configDir = dirname($configPath);
if (!is_dir($configDir) && !mkdir($configDir, 0775, true) && !is_dir($configDir)) {
    fwrite(STDERR, "Unable to create config directory\n");
    exit(1);
}

$getenvOrDefault = static function (string $key, string $default = ''): string {
    $value = getenv($key);
    if ($value === false) {
        return $default;
    }
    return $value;
};

$dbConfig = [
    'connectionString' => $getenvOrDefault('LS_DB_DSN'),
    'emulatePrepare' => true,
    'username' => $getenvOrDefault('LS_DB_USERNAME'),
    'password' => $getenvOrDefault('LS_DB_PASSWORD'),
    'charset' => $getenvOrDefault('LS_DB_CHARSET'),
    'tablePrefix' => $getenvOrDefault('LS_DB_TABLE_PREFIX'),
];

$config = [
    'components' => [
        'db' => $dbConfig,
        'urlManager' => [
            'urlFormat' => $getenvOrDefault('LS_URL_FORMAT', 'path'),
            'rules' => [],
            'showScriptName' => filter_var($getenvOrDefault('LS_SHOW_SCRIPT_NAME', 'false'), FILTER_VALIDATE_BOOLEAN),
        ],
        'request' => [
            'baseUrl' => $getenvOrDefault('LS_BASE_URL'),
        ],
    ],
    'config' => [
        'publicurl' => $getenvOrDefault('LS_PUBLIC_URL'),
        'debug' => (int)$getenvOrDefault('LS_DEBUG_LEVEL', '0'),
        'debugsql' => (int)$getenvOrDefault('LS_DEBUG_SQL_LEVEL', '0'),
        'mysqlEngine' => $getenvOrDefault('LS_DB_DRIVER') === 'mysql' ? 'InnoDB' : '',
    ],
];

$content = "<?php if (!defined('BASEPATH')) exit('No direct script access allowed');\nreturn " . var_export($config, true) . ";\n";
if (file_put_contents($configPath, $content) === false) {
    fwrite(STDERR, "Failed to write LimeSurvey configuration\n");
    exit(1);
}
PHP
else
    log "config.php already present"
fi

ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_NAME=${ADMIN_NAME:-LimeSurvey Admin}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-}
ADMIN_PASSWORD_GENERATED=false
if [[ -z "$ADMIN_PASSWORD" ]]; then
    ADMIN_PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)
    ADMIN_PASSWORD_GENERATED=true
fi

# Run database migrations / install
log "Ensuring LimeSurvey database schema is up to date"
if php application/commands/console.php updatedb; then
    log "Database already provisioned"
else
    log "Running initial LimeSurvey installation"
    php application/commands/console.php install "$ADMIN_USER" "$ADMIN_PASSWORD" "$ADMIN_NAME" "$ADMIN_EMAIL"
    if [[ "$ADMIN_PASSWORD_GENERATED" == "true" ]]; then
        cat <<MSG
====================================================================
LimeSurvey admin credentials
    Username: $ADMIN_USER
    Password: $ADMIN_PASSWORD
Please store these securely. You can change them after first login.
====================================================================
MSG
    fi
fi

exec "$@"
