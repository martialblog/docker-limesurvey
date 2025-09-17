# LimeSurvey 6 Azure-friendly Dockerfile

This folder contains a self-contained Dockerfile that builds a LimeSurvey 6.0 image
which relies on a single mandatory environment variable: `DB_CONNECTION_STRING`.
The image targets automated deployments (e.g. Terraform on Azure) where the
container receives the full database connection string from platform secrets.

## Highlights

- Based on `php:8.2-apache-bookworm` and bundles LimeSurvey `6.15.11+250909`.
- Installs Microsoft's ODBC driver plus the `pdo_sqlsrv` PHP extension so Azure
  SQL Database connection strings work out-of-the-box.
- Generates `config.php` dynamically from the connection string and performs the
  CLI-driven LimeSurvey installation on first start.
- Auto-generates an admin password (logged once) when `ADMIN_PASSWORD` is not
  provided, keeping the connection string as the only required input.

## Usage

```bash
docker build -f azure/Dockerfile -t limesurvey-azure .

docker run -p 8080:8080 \
  -e "DB_CONNECTION_STRING=Server=tcp:myserver.database.windows.net,1433;Database=limesurvey;Uid=lsadmin@myserver;Pwd=S3cretPass!;Encrypt=yes;TrustServerCertificate=no;" \
  limesurvey-azure
```

When the container provisions LimeSurvey for the first time it will:

1. Wait until the target database endpoint is reachable (if host/port were
   present in the connection string).
2. Generate `/var/www/html/application/config/config.php` using the parsed
   credentials.
3. Execute the LimeSurvey CLI installer. If no admin password was provided, a
   strong random password is generated and printed to the logs.

Persist volumes as required for uploads, e.g. `-v limesurvey-upload:/var/www/html/upload`.

## Connection string formats

The parser accepts common styles:

- Standard Azure SQL style: `Server=tcp:...;Database=...;User ID=...;Password=...`.
- PDO DSN style: `sqlsrv:Server=...;Database=...;Uid=...;Pwd=...`.
- Generic URL style: `mysql://user:pass@host:3306/database?charset=utf8mb4`.

Username and password can be embedded in the string. If they are not present,
provide them separately via optional `ADMIN_*` variables or extend the string.

## Customisation knobs

While `DB_CONNECTION_STRING` is the only required variable, the entrypoint also
respects optional overrides:

- `LISTEN_PORT` – change Apache's internal listen port (defaults to 8080).
- `PUBLIC_URL`, `BASE_URL`, `URL_FORMAT`, `SHOW_SCRIPT_NAME`, `DEBUG`, `DEBUG_SQL`
  – forwarded to LimeSurvey configuration when present.
- `ADMIN_USER`, `ADMIN_PASSWORD`, `ADMIN_NAME`, `ADMIN_EMAIL` – optional initial
  admin credentials.

## Terraform & Azure deployment notes

- Store `DB_CONNECTION_STRING` in Azure Key Vault or as a Kubernetes secret and
  inject it into the container instance.
- Make sure the LimeSurvey upload directory is persisted (Azure Files, managed
  disk, or blobfuse) to keep themes and survey assets across restarts.
- Configure outbound firewall rules so the container can reach the Azure SQL
  endpoint port (typically 1433).
