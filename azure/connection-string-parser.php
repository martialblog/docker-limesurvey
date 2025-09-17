#!/usr/bin/env php
<?php
declare(strict_types=1);

final class ConnectionStringParser
{
    private string $raw;

    public function __construct(string $connectionString)
    {
        $this->raw = trim($connectionString);
        if ($this->raw === '') {
            throw new InvalidArgumentException('Empty connection string received.');
        }
    }

    /**
     * @return array<string,string>
     */
    public function parse(): array
    {
        if ($this->looksLikeUrlStyle()) {
            return $this->parseUrlStyle();
        }

        if ($this->looksLikeKeyValueStyle()) {
            return $this->parseKeyValueStyle();
        }

        if ($this->looksLikeDsnStyle()) {
            return $this->parseDsnStyle();
        }

        throw new InvalidArgumentException('Unsupported connection string format.');
    }

    private function looksLikeUrlStyle(): bool
    {
        return (bool)preg_match('/^[a-z][a-z0-9+.-]*:\/\//i', $this->raw);
    }

    private function looksLikeKeyValueStyle(): bool
    {
        return str_contains($this->raw, '=') && str_contains($this->raw, ';');
    }

    private function looksLikeDsnStyle(): bool
    {
        return (bool)preg_match('/^[a-z][a-z0-9+.-]*:/i', $this->raw);
    }

    /**
     * @return array<string,string>
     */
    private function parseUrlStyle(): array
    {
        $url = parse_url($this->raw);
        if ($url === false || empty($url['scheme'])) {
            throw new InvalidArgumentException('Malformed URL style connection string.');
        }

        $scheme = strtolower($url['scheme']);
        $driver = $this->normalizeDriver($scheme);

        $host = $url['host'] ?? '';
        $port = isset($url['port']) ? (string)$url['port'] : '';
        $db = isset($url['path']) ? ltrim($url['path'], '/') : '';
        $user = $url['user'] ?? '';
        $pass = $url['pass'] ?? '';

        $params = [];
        if (!empty($url['query'])) {
            parse_str($url['query'], $queryParams);
            foreach ($queryParams as $key => $value) {
                if ($value === '') {
                    continue;
                }
                $params[] = sprintf('%s=%s', $key, $value);
            }
        }

        $dsn = $this->buildDsn($driver, $host, $port, $db, $params);

        return [
            'DB_DRIVER' => $driver,
            'DB_DSN' => $dsn,
            'DB_HOST' => $host,
            'DB_PORT' => $port,
            'DB_DATABASE' => $db,
            'DB_USERNAME' => $user,
            'DB_PASSWORD' => $pass,
        ];
    }

    /**
     * @return array<string,string>
     */
    private function parseDsnStyle(): array
    {
        [$driverRaw] = explode(':', $this->raw, 2);
        $driver = $this->normalizeDriver($driverRaw);

        // Attempt to extract key pieces from DSN (best effort)
        $host = '';
        $port = '';
        $db = '';
        $dsn = $this->raw;

        $segments = explode(';', $dsn);
        foreach ($segments as $segment) {
            if (!str_contains($segment, '=')) {
                continue;
            }
            [$key, $value] = array_map('trim', explode('=', $segment, 2));
            $lowerKey = strtolower($key);
            if ($host === '' && in_array($lowerKey, ['host', 'server', 'servername'], true)) {
                $host = $value;
                if (str_contains($host, ',')) {
                    [$host, $possiblePort] = array_map('trim', explode(',', $host, 2));
                    if ($port === '') {
                        $port = $possiblePort;
                    }
                }
            }
            if ($port === '' && in_array($lowerKey, ['port'], true)) {
                $port = $value;
            }
            if ($db === '' && in_array($lowerKey, ['dbname', 'database', 'initial catalog'], true)) {
                $db = $value;
            }
        }

        return [
            'DB_DRIVER' => $driver,
            'DB_DSN' => $dsn,
            'DB_HOST' => $host,
            'DB_PORT' => $port,
            'DB_DATABASE' => $db,
            'DB_USERNAME' => '',
            'DB_PASSWORD' => '',
        ];
    }

    /**
     * @return array<string,string>
     */
    private function parseKeyValueStyle(): array
    {
        $tokens = [];
        foreach (explode(';', $this->raw) as $segment) {
            $segment = trim($segment);
            if ($segment === '') {
                continue;
            }
            [$key, $value] = array_map('trim', explode('=', $segment, 2));
            if ($key === '') {
                continue;
            }
            $value = trim($value, " \t\n\r\0\x0B\"");
            if (str_starts_with($value, '{') && str_ends_with($value, '}')) {
                $value = substr($value, 1, -1);
            }
            $tokens[] = [
                'key' => $key,
                'value' => $value,
                'lower' => strtolower($key),
            ];
        }

        $map = [];
        foreach ($tokens as $token) {
            $map[$token['lower']] = $token['value'];
        }

        $driverHint = $map['dbtype']
            ?? $map['provider']
            ?? $map['driver']
            ?? '';
        $driver = $this->normalizeDriver($driverHint ?: 'sqlsrv');

        $hostValue = $this->firstNonEmpty($map, ['server', 'data source', 'datasource', 'address', 'addr', 'network address', 'host']);
        $port = $this->firstNonEmpty($map, ['port']);
        if ($hostValue !== null) {
            $hostValue = $this->normalizeServer($hostValue, $port);
            [$hostValue, $derivedPort] = $hostValue;
            if ($port === null && $derivedPort !== '') {
                $port = $derivedPort;
            }
            $host = $hostValue;
        } else {
            $host = '';
        }
        $port = $port ?? '';

        $database = $this->firstNonEmpty($map, ['database', 'initial catalog', 'dbname', 'catalog']) ?? '';
        $username = $this->firstNonEmpty($map, ['uid', 'user id', 'userid', 'username', 'user']) ?? '';
        $password = $this->firstNonEmpty($map, ['pwd', 'password']) ?? '';

        $consumedKeys = [
            'dbtype', 'provider', 'driver',
            'server', 'data source', 'datasource', 'address', 'addr', 'network address', 'host',
            'port', 'database', 'initial catalog', 'dbname', 'catalog',
            'uid', 'user id', 'userid', 'username', 'user',
            'pwd', 'password',
        ];
        $extraParams = [];
        foreach ($tokens as $token) {
            if (!in_array($token['lower'], $consumedKeys, true) && $token['value'] !== '') {
                $extraParams[] = $token;
            }
        }

        $extraParts = [];
        foreach ($extraParams as $param) {
            $extraParts[] = sprintf('%s=%s', $param['key'], $param['value']);
        }

        $dsn = $this->buildDsn($driver, $host, $port, $database, $extraParts);

        return [
            'DB_DRIVER' => $driver,
            'DB_DSN' => $dsn,
            'DB_HOST' => $host,
            'DB_PORT' => $port,
            'DB_DATABASE' => $database,
            'DB_USERNAME' => $username,
            'DB_PASSWORD' => $password,
        ];
    }

    private function normalizeDriver(string $hint): string
    {
        $hint = strtolower(trim($hint));
        if ($hint === '') {
            return 'sqlsrv';
        }

        return match (true) {
            str_starts_with($hint, 'mysql'), str_contains($hint, 'mariadb') => 'mysql',
            str_starts_with($hint, 'pgsql'), str_contains($hint, 'postgres') => 'pgsql',
            str_starts_with($hint, 'sqlsrv'), str_contains($hint, 'sql server'), str_contains($hint, 'odbc driver') => 'sqlsrv',
            default => $hint,
        };
    }

    /**
     * @return array{0:string,1:string}
     */
    private function normalizeServer(string $value, ?string $portHint): array
    {
        $clean = trim($value);
        if (stripos($clean, 'tcp:') === 0) {
            $clean = substr($clean, 4);
        }

        $derivedPort = $portHint ?? '';
        if (str_contains($clean, ',')) {
            [$clean, $possiblePort] = array_map('trim', explode(',', $clean, 2));
            if ($derivedPort === '' && $possiblePort !== '') {
                $derivedPort = $possiblePort;
            }
        }

        return [$clean, $derivedPort];
    }

    /**
     * @param array<string,string> $map
     * @param array<int,string> $keys
     */
    private function firstNonEmpty(array $map, array $keys): ?string
    {
        foreach ($keys as $key) {
            if (!array_key_exists($key, $map)) {
                continue;
            }
            $value = trim((string)$map[$key]);
            if ($value !== '') {
                return $value;
            }
        }

        return null;
    }

    /**
     * @param list<string> $extraParts
     */
    private function buildDsn(string $driver, string $host, string $port, string $database, array $extraParts): string
    {
        $dsn = sprintf('%s:', $driver);
        $segments = [];

        if ($driver === 'sqlsrv') {
            if ($host !== '') {
                $server = $host;
                if ($port !== '') {
                    $server .= ',' . $port;
                }
                $segments[] = 'Server=' . $server;
            }
            if ($database !== '') {
                $segments[] = 'Database=' . $database;
            }
            $hasCharacterSet = false;
            foreach ($extraParts as $part) {
                if (str_starts_with(strtolower($part), 'characterset=')) {
                    $hasCharacterSet = true;
                    break;
                }
            }
            if (!$hasCharacterSet) {
                $extraParts[] = 'CharacterSet=UTF-8';
            }
        } else {
            if ($host !== '') {
                $segments[] = 'host=' . $host;
            }
            if ($port !== '') {
                $segments[] = 'port=' . $port;
            }
            if ($database !== '') {
                $segments[] = 'dbname=' . $database;
            }
        }

        if ($driver === 'mysql' && !self::containsKey($extraParts, 'charset')) {
            $extraParts[] = 'charset=utf8mb4';
        }

        $segments = array_filter($segments, fn($segment) => $segment !== '');
        $dsn .= implode(';', $segments);

        if (!empty($extraParts)) {
            if (!empty($segments)) {
                $dsn .= ';';
            }
            $dsn .= implode(';', $extraParts);
        }

        return $dsn;
    }

    /**
     * @param list<string> $extraParts
     */
    private static function containsKey(array $extraParts, string $key): bool
    {
        $needle = strtolower($key) . '=';
        foreach ($extraParts as $part) {
            if (str_starts_with(strtolower($part), $needle)) {
                return true;
            }
        }

        return false;
    }
}

try {
    $connectionString = getenv('DB_CONNECTION_STRING') ?: ($argv[1] ?? '');
    $parser = new ConnectionStringParser($connectionString);
    $result = $parser->parse();
    foreach ($result as $key => $value) {
        printf("%s=%s\n", $key, $value);
    }
} catch (Throwable $exception) {
    fwrite(STDERR, 'Unable to parse DB_CONNECTION_STRING: ' . $exception->getMessage() . PHP_EOL);
    exit(1);
}
