[![Build Status](https://travis-ci.org/martialblog/docker-limesurvey.svg?branch=master)](https://travis-ci.org/martialblog/docker-limesurvey)
[![](https://images.microbadger.com/badges/image/martialblog/limesurvey.svg)](https://microbadger.com/images/martialblog/limesurvey "Get your own image badge on microbadger.com")

# LimeSurvey Docker

Dockerfile to build a [LimeSurvey](https://limesurvey.org) Image for the Docker container platform.

# Using the apache image

The apache image comes with an Apache Webserver and PHP installed.

# Apache Configuration

To change to Apache Webserver configuration mount a Volume into the Container at:

 - /etc/apache2/sites-available/000-default.conf

See the example configuration provided.

# Using the fpm image

To use the fpm image you need an additional web server that can proxy http-request to the fpm-port of the container.

# Using an external database

LimeSurvey requires an external database (MySQL, PostgreSQL) to run. See *docker-compose.yml* for example.

# Persistent data

To preserve the uploaded files assign the upload folder into a volume. See *docker-compose.yml* for details.

# LimeSurvey Configuration

To change to LimeSurvey configuration simply mount a Volume into the Container at:

 - /my-data/config.php:/var/www/html/application/config/config.php

**Hint**: If this configuration is present, the LimeSurvey Installer will not run.

# References

- https://www.limesurvey.org/
- https://github.com/LimeSurvey/LimeSurvey/
