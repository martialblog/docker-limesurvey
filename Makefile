# .PHONY: apache fpm fpm-alpine

RUNTIME = podman

apache-lts:
	$(RUNTIME) build --pull -t docker.io/martialblog/limesurvey:3-apache 3.0/apache
apache-latest:
	$(RUNTIME) build --pull -t docker.io/martialblog/limesurvey:5-apache 5.0/apache
fpm-alpine-lts:
	$(RUNTIME) build --pull -t docker.io/martialblog/limesurvey:3-fpm-alpine 3.0/fpm-alpine
fpm-alpine-latest:
	$(RUNTIME) build --pull -t docker.io/martialblog/limesurvey:5-fpm-alpine 5.0/fpm-alpine
fpm-lts:
	$(RUNTIME) build --pull -t docker.io/martialblog/limesurvey:3-fpm 3.0/fpm
fpm-latest:
	$(RUNTIME) build --pull -t docker.io/martialblog/limesurvey:5-fpm 5.0/fpm
