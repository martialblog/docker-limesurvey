[![Build Status](https://travis-ci.org/martialblog/docker-limesurvey.svg?branch=master)](https://travis-ci.org/martialblog/docker-limesurvey)
[![](https://images.microbadger.com/badges/image/martialblog/limesurvey.svg)](https://microbadger.com/images/martialblog/limesurvey "Get your own image badge on microbadger.com")

# LimeSurvey Docker

Dockerfile to build a [LimeSurvey](https://limesurvey.org) Image for the Docker container platform.

# Using the apache image

The apache image comes with an Apache Webserver and PHP installed.

# Apache Configuration

To change to Apache Webserver configuration, mount a Volume into the Container at:

 - /etc/apache2/sites-available/000-default.conf

See the example configuration provided.

# Using the fpm image

To use the fpm image, you need an additional web server that can proxy http-request to the fpm-port of the container. See *docker-compose.fpm.yml* for example

# Using an external database

LimeSurvey requires an external database (MySQL, PostgreSQL) to run. See *docker-compose.yml* for example.

# Persistent data

To preserve the uploaded files assign the upload folder into a volume. See *docker-compose.yml* for example.

Path: */var/www/html/upload/*

# LimeSurvey Configuration

The entrypoint will create a new config.php if none is provided and run the LimeSurvey command line interface for installation.

To change to LimeSurvey configuration, you can mount a Volume into the Container at:

 - /my-data/config.php:/var/www/html/application/config/config.php

**Hint**: If this configuration is present before the installation, the LimeSurvey Web Installer will not run automatically.

# Environment Variables

| Parameter       | Description                               |
| ---------       | -----------                               |
| DB_TYPE         | Database Type to use. mysql or pgsql      |
| DB_HOST         | Database server hostname                  |
| DB_PORT         | Database server port                      |
| DB_SOCK         | Database unix socket instead of host/port |
| DB_NAME         | Database name                             |
| DB_TABLE_PREFIX | Database table prefix                     |
| DB_USERNAME     | Database user                             |
| DB_PASSWORD     | Database user's password                  |
| ADMIN_USER      | LimeSurvey Admin User                     |
| ADMIN_NAME      | LimeSurvey Admin Username                 |
| ADMIN_EMAIL     | LimeSurvey Admin Email                    |
| ADMIN_PASSWORD  | LimeSurvey Admin Password                 |
| PUBLIC_URL      | Public URL for public scripts             |
| URL_FORMAT      | URL Format. path or get                   |

For further details on the settings see: https://manual.limesurvey.org/Optional_settings#Advanced_Path_Settings

# References

- https://www.limesurvey.org/
- https://github.com/LimeSurvey/LimeSurvey/
