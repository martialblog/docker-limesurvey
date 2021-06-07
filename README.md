[![Build Status](https://travis-ci.com/martialblog/docker-limesurvey.svg?branch=master)](https://travis-ci.com/martialblog/docker-limesurvey)
[![](https://images.microbadger.com/badges/image/martialblog/limesurvey.svg)](https://microbadger.com/images/martialblog/limesurvey "Get your own image badge on microbadger.com")

# LimeSurvey Docker

Dockerfile to build a [LimeSurvey](https://limesurvey.org) Image for the Docker container platform.

## Quick reference

- **Maintained by:** https://github.com/martialblog/
- **Where to get help:** [GitHub Issues](https://github.com/martialblog/docker-limesurvey/issues)

## Supported tags and respective Dockerfile links

- [`5-apache`, `5.<BUILD-NUMBER>-apache`, `latest` ](https://github.com/martialblog/docker-limesurvey/blob/master/5.0/apache/Dockerfile)
- [`5-fpm`, `5.<BUILD-NUMBER>-fpm`](https://github.com/martialblog/docker-limesurvey/blob/master/5.0/fpm/Dockerfile)
- [`5-fpm-alpine`, `5.<BUILD-NUMBER>-fpm-alpine`](https://github.com/martialblog/docker-limesurvey/blob/master/5.0/fpm-alpine/Dockerfile)
- [`3-apache`, `3.<BUILD-NUMBER>-apache`](https://github.com/martialblog/docker-limesurvey/blob/master/3.0/apache/Dockerfile)
- [`3-fpm`, `3.<BUILD-NUMBER>-fpm`](https://github.com/martialblog/docker-limesurvey/blob/master/3.0/fpm/Dockerfile)
- [`3-fpm-alpine`, `3.<BUILD-NUMBER>-fpm-alpine`](https://github.com/martialblog/docker-limesurvey/blob/master/3.0/fpm-alpine/Dockerfile)

# Using the Apache Image

The `apache` image comes with an Apache Webserver and PHP installed.

This image is also available in a `rootless` variant with `www-data` as default user and Apache listening on 8080. Starting from 5.0, the `rootless` variant is the default for Apache images.

## Apache Configuration

To change to Apache Webserver configuration, mount a Volume into the Container at:

 - `/etc/apache2/sites-available/000-default.conf`

See the example configuration provided.

The Apache port can be specified by setting the environment variable `LISTEN_PORT` (e.g. `LISTEN_PORT=8080`). Starting from 5.0, Apache defaults to listening on a non-privilged port (8080) in inside the container.

# Using the fpm Image

To use the fpm image, you need an additional web server that can proxy http-request to the fpm-port of the container. See *docker-compose.fpm.yml* for example.

## Using the fpm Image with HTTPS

If you would like to run the fpm setup with https, you can get a free certificate from Letsencrypt. As an example, the configuration in *docker-compose.fpm-certbot.yml*
will take care of getting a certificate and installing it. Please note that you will have to adjust the domain name in the file *examples/nginx-certbot.conf* to match
the domain used in the *HOSTNAMES* variable in the docker-compose configuration file. If you added both the a domain and the hostname *www* within the domain,
*nginx-certbot.conf* needs to contain the domain without the hostname. E.g. if you set *"HOSTNAMES=example.org www.example.org"*, the path in *nginx-certbot.conf* needs
to contain *example.org*.

# Using an external database

LimeSurvey requires an external database (MySQL, PostgreSQL) to run. See *docker-compose.yml* for example.

# Persistent data

To preserve the uploaded files assign the upload folder into a volume. See *docker-compose.yml* for example.

Path: `/var/www/html/upload/surveys`

**Hint**: The mounted directory must be owned by the webserver user (e.g. www-data)

# LimeSurvey configuration

The entrypoint will create a new config.php if none is provided and run the LimeSurvey command line interface for installation.

**Hint**: Changing the *ADMIN_* configuration has no effect after the initial configuration. It's best to do this within the application.

To change to LimeSurvey configuration, you can mount a Volume into the Container at:

 - `/my-data/config.php:/var/www/html/application/config/config.php`

**Hint**: If this configuration is present before the installation, the LimeSurvey Web Installer will not run automatically.

## Data encryption

LimeSurvey version 4.0 and newer support data encryption, this image give you these options:

* Provide a security.php file directly (volume)
* Provide encryption keys for the `security.php` file (environment variables)
* Provide nothing and get a non-persistent `security.php` file

For further details on the settings see: https://manual.limesurvey.org/Data_encryption

# Reverse Proxy configuration

## Traefik example

```
# BASE_URL = /limesurvey
"traefik.http.routers.limesurvey.rule=PathPrefix(`/limesurvey`)",
"traefik.http.routers.limesurvey.middlewares=strip-limesurvey@docker",
"traefik.http.middlewares.strip-limesurvey.stripprefix.prefixes=/limesurvey",
```

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
| ADMIN_USER      | Initial LimeSurvey Admin User             |
| ADMIN_NAME      | Initial LimeSurvey Admin Username         |
| ADMIN_EMAIL     | Initial LimeSurvey Admin Email            |
| ADMIN_PASSWORD  | Initial LimeSurvey Admin Password         |
| PUBLIC_URL      | Public URL for public scripts             |
| BASE_URL        | Application Base URL                      |
| URL_FORMAT      | URL Format. path or get                   |
| SHOW_SCRIPT_NAME | Script name in URL (true|false). Default: true |
| DEBUG           | Debug level (0, 1, 2). Default: 0         |
| DEBUG_SQL       | SQL Debug level (0, 1, 2). Default 0      |
| ENCRYPT_KEYPAIR  | Data encryption keypair                  |
| ENCRYPT_PUBLIC_KEY | Data encryption public key             |
| ENCRYPT_SECRET_KEY | Data encryption secret key             |
| LISTEN_PORT     | Apache: Listen port. Default: 8080        |

For further details on the settings see: https://manual.limesurvey.org/Optional_settings#Advanced_Path_Settings

# Running this Image with docker-compose

The easiest way to get a fully featured and functional setup is using a docker-compose file. Several examples are provided in the [repository](https://github.com/martialblog/docker-limesurvey).

```
docker-compose up

# Frontend
http://localhost:8080/

# Backend
http://localhost:8080/index.php/admin
```

# Upgrade Guide

These guides are only referring to the Docker Image, for details on the application users should consult the [official LimeSurvey documentation](https://manual.limesurvey.org/Upgrading_from_a_previous_version) for details.

## Upgrading the FPM Images

If you are using docker-compose to run the FPM Images, you need to stop the application and webserver Containers and delete the application volume:

```
$ docker volume ls
DRIVER    VOLUME NAME
local     docker-limesurvey_lime

$ docker volume rm docker-limesurvey_lime
```

## Upgrading to 5.0 from 4.x

The default user in the Container will now be *www-data* (uid 33 in Debian, uid 82 in Alpine), any volumes mounted need the corresponding permissions:

```
# Debian
$ ls -ln upload/
total 4
drwxr-xr-x 3 33 33 4096 Jun  3 13:51 surveys
```

```
# Alpine
$ ls -ln upload/
total 4
drwxr-xr-x 3 82 82 4096 Jun  3 13:51 surveys
```

If you are using the Apache2 Images, the default port will now be **8080**. Depending on your setup the port configurations might need adjustment.

# References

- https://www.limesurvey.org/
- https://github.com/LimeSurvey/LimeSurvey/
