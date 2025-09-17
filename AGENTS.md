# Repository Notes for Agents

## Purpose
This repository houses Docker assets for building and operating LimeSurvey across multiple deployment flavours (Apache, FPM, Alpine) and helper tooling (docker-compose examples, tests, upgrade scripts).

## Key Areas
- `6.0/` / `5.0/`: Official Dockerfiles and entrypoints per version and runtime flavour.
- `docker-compose*.yml`: Ready-to-use stacks covering MySQL/PostgreSQL, Traefik, certbot and FPM scenarios.
- `examples/`, `nginx-certbot/`, `surveys/`: Sample configs, HTTPS helpers, and survey fixtures for local testing.
- `tests/`: GitHub Actions playbooks verifying LTS/latest images.
- `Makefile`, `upgrade.sh`: Utilities for building, linting and upgrading containers.

## Recent Change
Created an Azure-oriented build in `azure/`:
- `azure/Dockerfile` bundles LimeSurvey 6.15.11, Microsoft's SQL Server ODBC driver and PHP `pdo_sqlsrv` support.
- `azure/entrypoint.sh` provisions LimeSurvey from a single `DB_CONNECTION_STRING`, waits for the database and runs CLI installs/migrations.
- `azure/connection-string-parser.php` normalises Azure SQL/Azure DSN/URL strings into PDO-compatible DSNs.
- `azure/README.md` documents build, run and Terraform/Azure deployment guidance.

This change enables automated Azure deployments (e.g. via Terraform) that only need to pass a database connection string at runtime.
