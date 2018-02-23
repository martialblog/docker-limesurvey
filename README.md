[![Build Status](https://travis-ci.org/martialblog/docker-limesurvey.svg?branch=master)](https://travis-ci.org/martialblog/docker-limesurvey)
[![](https://images.microbadger.com/badges/image/martialblog/limesurvey.svg)](https://microbadger.com/images/martialblog/limesurvey "Get your own image badge on microbadger.com")

# LimeSurvey Docker

Dockerfile to build a [LimeSurvey](https://limesurvey.org) image for the Docker container platform.

# Uploads Persistence

To preserve the uploaded files assign the upload folder into a volume. See *docker-compose.yml* for details.

# LimeSurvey Configuration

To change to LimeSuvey configuration simply mount a Volume into the Container at:

 - /var/www/html/application/config/config.php

**Hint**: If this configuration is present, the LimeSuvery Installer will not run.

# Apache Configuration

To change to Apache Webserver configuration mount a Volume into the Container at:

 - /etc/apache2/sites-available/000-default.conf

See the example configuration provided.
